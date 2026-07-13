//
//  GolfClubLocationCoordinator.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation
import GolfCore

@MainActor
final class GolfClubLocationCoordinator {

    typealias ObservationStream =
        () -> AsyncStream<LocationObservation>

    typealias GolfClubSource =
        () -> [GolfClub]

    typealias HoleSource =
        () -> [Hole]

    private let observationStream: ObservationStream
    private let golfClubSource: GolfClubSource
    private let holeSource: HoleSource

    private let golfClubDetectionService:
        GolfClubDetectionService

    private let holeDetectionService:
        HoleDetectionService

    private let orchestrator:
        RoundOrchestrator

    private var observationTask:
        Task<Void, Never>?

    private var golfClubResolved = false
    private var lastPublishedOutput:
        RoundOrchestratorOutput?

    var onOutput:
        (@MainActor (RoundOrchestratorOutput) -> Void)?

    var onError:
        (@MainActor (Error) -> Void)?

    init(
        observationStream:
            @escaping ObservationStream,
        golfClubSource:
            @escaping GolfClubSource,
        holeSource:
            @escaping HoleSource,
        orchestrator: RoundOrchestrator,
        golfClubDetectionService:
            GolfClubDetectionService =
                GolfClubDetectionService(),
        holeDetectionService:
            HoleDetectionService =
                HoleDetectionService()
    ) {
        self.observationStream =
            observationStream

        self.golfClubSource =
            golfClubSource

        self.holeSource =
            holeSource

        self.orchestrator =
            orchestrator

        self.golfClubDetectionService =
            golfClubDetectionService

        self.holeDetectionService =
            holeDetectionService
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - Streaming

    func start() {
        guard observationTask == nil else {
            return
        }

        let stream = observationStream()

        observationTask = Task {
            @MainActor [weak self] in

            for await observation in stream {
                guard let self,
                      !Task.isCancelled else {
                    return
                }

                let outputs =
                    await self.processLocation(
                        observation
                    )

                for output in outputs {
                    self.publish(output)
                }
            }
        }
    }

    func stop() {
        observationTask?.cancel()
        observationTask = nil
    }

    // MARK: - Location Processing

    @discardableResult
    func processLocation(
        _ observation: LocationObservation
    ) async -> [RoundOrchestratorOutput] {
        var outputs:
            [RoundOrchestratorOutput] = []

        do {
            _ = try await orchestrator.process(
                .locationUpdated(observation)
            )

            if !golfClubResolved {
                let clubResult =
                    golfClubDetectionService
                        .detectGolfClub(
                            from: observation,
                            among: golfClubSource()
                        )

                let clubOutput =
                    try await orchestrator.process(
                        .golfClubDetectionCompleted(
                            clubResult
                        )
                    )

                appendIfMeaningful(
                    clubOutput,
                    to: &outputs
                )

                switch clubOutput {
                case .golfClubDetected:
                    golfClubResolved = true

                case .requestGolfClubConfirmation,
                     .golfClubDetectionAmbiguous,
                     .locationAccuracyInsufficient,
                     .locationNotMatched:
                    return outputs

                default:
                    break
                }
            }

            guard golfClubResolved else {
                return outputs
            }

            let pendingHoleID =
                await orchestrator
                    .currentPendingHoleID()

            guard pendingHoleID == nil else {
                return outputs
            }

            let state =
                await orchestrator.currentState()

            guard state == .awaitingHoleDetection ||
                    state == .awaitingHoleConfirmation
            else {
                return outputs
            }

            let holes = holeSource()

            let previousHoleNumber =
                await previouslyCompletedHoleNumber(
                    among: holes
                )

            let holeResult =
                holeDetectionService.detectHole(
                    from: observation,
                    among: holes,
                    previouslyCompletedHoleNumber:
                        previousHoleNumber
                )

            let holeOutput =
                try await orchestrator.process(
                    .holeDetectionCompleted(
                        holeResult
                    )
                )

            appendIfMeaningful(
                holeOutput,
                to: &outputs
            )
        } catch {
            onError?(error)
        }

        return outputs
    }

    // MARK: - Golfer Decisions

    func confirmGolfClub(
        _ golfClubID: GolfClubID
    ) async {
        do {
            let output =
                try await orchestrator.process(
                    .golfClubConfirmedByGolfer(
                        golfClubID
                    )
                )

            if case .golfClubDetected = output {
                golfClubResolved = true
            }

            publish(output)
        } catch {
            onError?(error)
        }
    }

    func rejectGolfClub() async {
        do {
            let output =
                try await orchestrator.process(
                    .golfClubDetectionRejected
                )

            golfClubResolved = false
            publish(output)
        } catch {
            onError?(error)
        }
    }

    func confirmHole(
        _ holeID: HoleID
    ) async {
        do {
            let output =
                try await orchestrator.process(
                    .holeConfirmedByGolfer(
                        holeID
                    )
                )

            publish(output)
        } catch {
            onError?(error)
        }
    }

    func rejectHole() async {
        do {
            let output =
                try await orchestrator.process(
                    .holeDetectionRejected
                )

            publish(output)
        } catch {
            onError?(error)
        }
    }

    // MARK: - Helpers

    private func previouslyCompletedHoleNumber(
        among holes: [Hole]
    ) async -> Int? {
        let snapshot =
            await orchestrator.currentSnapshot()

        guard let completedSession =
                snapshot.round.holeSessions
                    .last(where: {
                        $0.status == .completed
                    })
        else {
            return nil
        }

        return holes.first {
            $0.id == completedSession.holeID
        }?.number
    }

    private func appendIfMeaningful(
        _ output: RoundOrchestratorOutput,
        to outputs:
            inout [RoundOrchestratorOutput]
    ) {
        guard output != .noAction else {
            return
        }

        outputs.append(output)
    }

    private func publish(
        _ output: RoundOrchestratorOutput
    ) {
        guard output != .noAction,
              output != lastPublishedOutput
        else {
            return
        }

        lastPublishedOutput = output
        onOutput?(output)
    }
}
