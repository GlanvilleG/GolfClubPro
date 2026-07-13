//
//  RoundSession.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation
import Observation
import GolfCore
import GolfPlatformApple

@MainActor
@Observable
final class RoundSession {

    // MARK: - Dependencies

    private let roundCoordinator:
        PersistentOfflineRoundCoordinator

    private let orchestratorSnapshotStore:
        any RoundOrchestratorSnapshotStore

    private let locationProvider:
        AppleLocationProvider

    private let golfClubSource:
        () -> [GolfClub]

    private let holeSource:
        () -> [Hole]

    // MARK: - Runtime Components

    private var orchestrator:
        RoundOrchestrator?

    private var locationCoordinator:
        GolfClubLocationCoordinator?

    // MARK: - Observable State

    private(set) var activeSnapshot:
        ActiveRoundSnapshot?

    private(set) var orchestratorState:
        OrchestratorState = .idle

    private(set) var latestOutput:
        RoundOrchestratorOutput?

    private(set) var pendingGolfClubID:
        GolfClubID?

    private(set) var pendingHoleID:
        HoleID?

    private(set) var isLoading = false
    private(set) var isLocationActive = false
    private(set) var errorMessage: String?

    // MARK: - Initialisation

    init(
        roundCoordinator:
            PersistentOfflineRoundCoordinator,
        orchestratorSnapshotStore:
            any RoundOrchestratorSnapshotStore,
        locationProvider:
            AppleLocationProvider,
        golfClubSource:
            @escaping () -> [GolfClub],
        holeSource:
            @escaping () -> [Hole]
    ) {
        self.roundCoordinator =
            roundCoordinator

        self.orchestratorSnapshotStore =
            orchestratorSnapshotStore

        self.locationProvider =
            locationProvider

        self.golfClubSource =
            golfClubSource

        self.holeSource =
            holeSource
    }

    // MARK: - Derived State

    var activeRound: Round? {
        activeSnapshot?.round
    }

    var hasActiveRound: Bool {
        guard let round = activeRound else {
            return false
        }

        return round.state != .roundCompleted
    }

    var roundState: RoundState? {
        activeRound?.state
    }

    var currentHoleSession: HoleSession? {
        activeRound?.currentHoleSession
    }

    var pendingEventCount: Int {
        activeSnapshot?.pendingEvents.count ?? 0
    }

    // MARK: - Round Lifecycle

    func restoreActiveRound() async {
        await perform {
            guard let snapshot =
                    try await self.roundCoordinator
                        .restoreMostRecentActiveRound()
            else {
                self.activeSnapshot = nil
                self.orchestratorState = .idle
                return
            }

            self.activeSnapshot = snapshot

            try await self.installRuntime(
                for: snapshot
            )
        }
    }

    func startRound(
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID,
        deviceID: DeviceID
    ) async {
        await perform {
            self.stopRuntime()

            let snapshot =
                try await self.roundCoordinator
                    .startRound(
                        playerID: playerID,
                        golfClubID: golfClubID,
                        courseID: courseID,
                        deviceID: deviceID
                    )

            self.activeSnapshot = snapshot

            try await self.installRuntime(
                for: snapshot
            )
        }
    }

    func finishRound() async {
        guard let snapshot = activeSnapshot else {
            setNoActiveRoundError()
            return
        }

        let roundID = snapshot.round.id

        await perform {
            let updated =
                try await self.roundCoordinator
                    .finishRound(
                        in: snapshot
                    )

            try await self.orchestratorSnapshotStore
                .delete(
                    roundID: roundID
                )

            self.activeSnapshot = updated
            self.stopRuntime()
            self.orchestratorState = .idle
        }
    }

    // MARK: - Round Setup

    func confirmTeeSet(
        _ teeSetID: TeeSetID
    ) async {
        guard let snapshot = activeSnapshot else {
            setNoActiveRoundError()
            return
        }

        await perform {
            let updated =
                try await self.roundCoordinator
                    .confirmTeeSet(
                        teeSetID,
                        in: snapshot
                    )

            self.activeSnapshot = updated

            try await self.installRuntime(
                for: updated
            )
        }
    }

    // MARK: - Location Decisions

    func confirmGolfClub(
        _ golfClubID: GolfClubID
    ) async {
        guard let locationCoordinator else {
            errorMessage =
                "Location coordination is unavailable."
            return
        }

        await locationCoordinator.confirmGolfClub(
            golfClubID
        )

        await refreshRuntimeState()
    }

    func rejectGolfClub() async {
        guard let locationCoordinator else {
            return
        }

        await locationCoordinator.rejectGolfClub()
        await refreshRuntimeState()
    }

    func confirmHole(
        _ holeID: HoleID
    ) async {
        guard let locationCoordinator else {
            errorMessage =
                "Location coordination is unavailable."
            return
        }

        await locationCoordinator.confirmHole(
            holeID
        )

        await refreshRuntimeState()
    }

    func rejectHole() async {
        guard let locationCoordinator else {
            return
        }

        await locationCoordinator.rejectHole()
        await refreshRuntimeState()
    }

    // MARK: - Club Selection

    func announceClub(
        _ clubID: ClubID
    ) async {
        await process(
            .clubSelected(clubID)
        )
    }

    func changeClub(
        to clubID: ClubID
    ) async {
        await process(
            .clubChanged(clubID)
        )
    }

    // MARK: - Swing Workflow

    func addressDetected() async {
        await process(
            .addressDetected
        )
    }

    func swingDetected(
        _ observation: SwingObservation
    ) async {
        await process(
            .swingDetected(observation)
        )
    }

    func impactDetected(
        _ observation: ImpactObservation
    ) async {
        await process(
            .impactDetected(observation)
        )
    }

    func golferDepartedShotOrigin() async {
        await process(
            .golferDepartedShotOrigin
        )
    }

    func confirmShot() async {
        await process(
            .shotConfirmedByGolfer
        )
    }

    func rejectAsPracticeSwing() async {
        await process(
            .practiceSwingConfirmedByGolfer
        )
    }

    func candidateSwingTimedOut() async {
        await process(
            .candidateSwingTimeout
        )
    }

    // MARK: - Shot Feedback

    func recordShotFeedback(
        transcript: String
    ) async {
        await process(
            .voiceFeedbackReceived(
                transcript
            )
        )
    }

    // MARK: - Lie

    func confirmLie(
        _ playableLie: PlayableLie
    ) async {
        await process(
            .lieConfirmed(playableLie)
        )
    }

    func correctLie(
        _ playableLie: PlayableLie
    ) async {
        await process(
            .lieCorrected(playableLie)
        )
    }

    // MARK: - Putting

    func recordPutts(
        _ putts: Int
    ) async {
        await process(
            .puttsRecorded(putts)
        )
    }

    // MARK: - Location Lifecycle

    func startLocationUpdates() {
        locationProvider.requestAuthorization()
        locationProvider.startUpdates()
        locationCoordinator?.start()

        isLocationActive = true
    }

    func stopLocationUpdates() {
        locationCoordinator?.stop()
        locationProvider.stopUpdates()

        isLocationActive = false
    }

    // MARK: - Errors

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Runtime Installation

    private func installRuntime(
        for snapshot: ActiveRoundSnapshot
    ) async throws {
        stopRuntime()

        let orchestrator =
            try await RoundOrchestrator.restoring(
                activeSnapshot: snapshot,
                coordinator: roundCoordinator,
                snapshotStore:
                    orchestratorSnapshotStore
            )

        let locationCoordinator =
            GolfClubLocationCoordinator(
                observationStream: {
                    self.locationProvider
                        .observations()
                },
                golfClubSource:
                    golfClubSource,
                holeSource:
                    holeSource,
                orchestrator:
                    orchestrator
            )

        locationCoordinator.onOutput = {
            [weak self] output in

            guard let self else {
                return
            }

            self.latestOutput = output

            Task { @MainActor in
                await self.refreshRuntimeState()
            }
        }

        locationCoordinator.onError = {
            [weak self] error in

            self?.errorMessage =
                String(describing: error)
        }

        self.orchestrator = orchestrator
        self.locationCoordinator =
            locationCoordinator

        await refreshRuntimeState()

        startLocationUpdates()
    }

    private func stopRuntime() {
        locationCoordinator?.stop()
        locationCoordinator = nil

        locationProvider.stopUpdates()
        isLocationActive = false

        orchestrator = nil

        pendingGolfClubID = nil
        pendingHoleID = nil
    }

    // MARK: - Event Processing

    private func process(
        _ event: RoundOrchestratorEvent
    ) async {
        guard let orchestrator else {
            errorMessage =
                "The round runtime is unavailable."
            return
        }

        await perform {
            let output =
                try await orchestrator.process(
                    event
                )

            self.latestOutput = output

            await self.refreshRuntimeState()
        }
    }

    private func refreshRuntimeState()
        async {
        guard let orchestrator else {
            return
        }

        activeSnapshot =
            await orchestrator.currentSnapshot()

        orchestratorState =
            await orchestrator.currentState()

        pendingGolfClubID =
            await orchestrator
                .currentPendingGolfClubID()

        pendingHoleID =
            await orchestrator
                .currentPendingHoleID()
    }

    // MARK: - Operation Handling

    private func perform(
        _ operation:
            @escaping () async throws -> Void
    ) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await operation()
        } catch {
            errorMessage =
                String(describing: error)
        }
    }

    private func setNoActiveRoundError() {
        errorMessage =
            "No active round is available."
    }
}
