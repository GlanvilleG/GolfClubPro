//
//  RoundSession.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation
import Observation
import GolfCore

@MainActor
@Observable
final class RoundSession {

    private let coordinator:
        PersistentOfflineRoundCoordinator

    private(set) var activeSnapshot:
        ActiveRoundSnapshot?

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        coordinator:
            PersistentOfflineRoundCoordinator
    ) {
        self.coordinator = coordinator
    }

    var activeRound: Round? {
        activeSnapshot?.round
    }

    var hasActiveRound: Bool {
        guard let round = activeRound else {
            return false
        }

        return round.state != .roundCompleted
    }

    var currentState: RoundState? {
        activeRound?.state
    }

    var currentHoleSession: HoleSession? {
        activeRound?.currentHoleSession
    }

    func restoreActiveRound() async {
        await perform {
            self.activeSnapshot =
                try await self.coordinator
                    .restoreMostRecentActiveRound()
        }
    }

    func startRound(
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID,
        deviceID: DeviceID
    ) async {
        await perform {
            self.activeSnapshot =
                try await self.coordinator.startRound(
                    playerID: playerID,
                    golfClubID: golfClubID,
                    courseID: courseID,
                    deviceID: deviceID
                )
        }
    }

    func confirmTeeSet(
        _ teeSetID: TeeSetID
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.confirmTeeSet(
                teeSetID,
                in: snapshot
            )
        }
    }

    func confirmHole(
        _ holeID: HoleID
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.confirmHole(
                holeID,
                in: snapshot
            )
        }
    }

    func announceClub(
        _ clubID: ClubID,
        currentLocation: GeoCoordinate? = nil,
        courseGeometry: CourseGeometry? = nil
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.announceClub(
                clubID,
                currentLocation: currentLocation,
                courseGeometry: courseGeometry,
                in: snapshot
            )
        }
    }

    func changeClub(
        to clubID: ClubID
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.changeClub(
                to: clubID,
                in: snapshot
            )
        }
    }

    func markShotHit() async {
        await updateSnapshot { snapshot in
            try await self.coordinator.markShotHit(
                in: snapshot
            )
        }
    }

    func recordShotFeedback(
        transcript: String
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator
                .recordShotFeedback(
                    transcript: transcript,
                    in: snapshot
                )
        }
    }

    func confirmLie(
        _ playableLie: PlayableLie
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.confirmLie(
                playableLie,
                in: snapshot
            )
        }
    }

    func correctLie(
        _ playableLie: PlayableLie
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.correctLie(
                playableLie,
                in: snapshot
            )
        }
    }

    func recordPutts(
        _ putts: Int
    ) async {
        await updateSnapshot { snapshot in
            try await self.coordinator.recordPutts(
                putts,
                in: snapshot
            )
        }
    }

    func leaveHolePending() async {
        await updateSnapshot { snapshot in
            try await self.coordinator
                .leaveHolePending(
                    in: snapshot
                )
        }
    }

    func completeCurrentHole() async {
        await updateSnapshot { snapshot in
            try await self.coordinator
                .completeCurrentHole(
                    in: snapshot
                )
        }
    }

    func finishRound() async {
        await updateSnapshot { snapshot in
            try await self.coordinator.finishRound(
                in: snapshot
            )
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func updateSnapshot(
        operation: @escaping (
            ActiveRoundSnapshot
        ) async throws -> ActiveRoundSnapshot
    ) async {
        guard let snapshot = activeSnapshot else {
            errorMessage = "No active round is available."
            return
        }

        await perform {
            self.activeSnapshot =
                try await operation(snapshot)
        }
    }

    private func perform(
        operation: @escaping () async throws -> Void
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
}
