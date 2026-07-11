//
//  RoundOrchestrator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum RoundOrchestratorOutput:
    Equatable,
    Sendable {

    case noAction

    case stateChanged(
        OrchestratorState
    )

    case practiceSwingIgnored(
        confidence: Double
    )

    case requestShotConfirmation(
        confidence: Double
    )

    case shotConfirmed

    case shotFeedbackRecorded
}

public enum RoundOrchestratorError:
    Error,
    Equatable,
    Sendable {

    case roundIdentifierMismatch
}
public actor RoundOrchestrator {

    private let coordinator:
        PersistentOfflineRoundCoordinator

    private let confidenceEvaluator:
        SwingConfidenceEvaluator

    private let thresholds:
        SwingConfidenceThresholds

    private var activeSnapshot:
        ActiveRoundSnapshot

    private var state:
        OrchestratorState

    private var candidateSwing:
        CandidateSwing?

    private var lastLocation:
        LocationObservation?
    
    private let snapshotStore:
        (any RoundOrchestratorSnapshotStore)?

    public init(
        snapshot: ActiveRoundSnapshot,
        coordinator:
            PersistentOfflineRoundCoordinator,
        snapshotStore:
            (any RoundOrchestratorSnapshotStore)? = nil,
        confidenceEvaluator:
            SwingConfidenceEvaluator =
                SwingConfidenceEvaluator(),
        thresholds:
            SwingConfidenceThresholds =
                SwingConfidenceThresholds()
    ) {
        self.activeSnapshot = snapshot
        self.coordinator = coordinator
        self.snapshotStore = snapshotStore
        self.confidenceEvaluator = confidenceEvaluator
        self.thresholds = thresholds
        self.state = Self.initialState(
            for: snapshot.round
        )
    }

    public func makeSnapshot()
        -> RoundOrchestratorSnapshot {

        RoundOrchestratorSnapshot(
            roundID: activeSnapshot.round.id,
            state: state,
            candidateSwing: candidateSwing,
            lastLocation: lastLocation
        )
    }
    public func restore(
        from snapshot: RoundOrchestratorSnapshot
    ) throws {
        guard snapshot.roundID ==
                activeSnapshot.round.id else {
            throw RoundOrchestratorError
                .roundIdentifierMismatch
        }

        state = snapshot.state
        candidateSwing = snapshot.candidateSwing
        lastLocation = snapshot.lastLocation
    }
    
    public func currentSnapshot()
        -> ActiveRoundSnapshot {
        activeSnapshot
    }

    public func currentState()
        -> OrchestratorState {
        state
    }

    public func currentCandidateSwing()
        -> CandidateSwing? {
        candidateSwing
    }
    public static func restoring(
        activeSnapshot: ActiveRoundSnapshot,
        coordinator:
            PersistentOfflineRoundCoordinator,
        snapshotStore:
            any RoundOrchestratorSnapshotStore,
        confidenceEvaluator:
            SwingConfidenceEvaluator =
                SwingConfidenceEvaluator(),
        thresholds:
            SwingConfidenceThresholds =
                SwingConfidenceThresholds()
    ) async throws -> RoundOrchestrator {

        let orchestrator = RoundOrchestrator(
            snapshot: activeSnapshot,
            coordinator: coordinator,
            snapshotStore: snapshotStore,
            confidenceEvaluator:
                confidenceEvaluator,
            thresholds: thresholds
        )

        if let storedSnapshot =
            try await snapshotStore.load(
                roundID: activeSnapshot.round.id
            ) {
            try await orchestrator.restore(
                from: storedSnapshot
            )
        }

        return orchestrator
    }
    
    @discardableResult
    public func process(
        _ event: RoundOrchestratorEvent
    ) async throws -> RoundOrchestratorOutput {

        let output = try await processEvent(event)

        try await persistOrchestratorState()

        return output
    }
    
    @discardableResult
    private func processEvent(
        _ event: RoundOrchestratorEvent
    ) async throws -> RoundOrchestratorOutput {

        switch event {

        case let .locationUpdated(observation):
            lastLocation = observation
            return .noAction

        case let .clubSelected(clubID):
            activeSnapshot =
                try await coordinator.announceClub(
                    clubID,
                    currentLocation:
                        lastLocation?.coordinate,
                    courseGeometry:
                        activeSnapshot
                            .cachedCourseGeometry,
                    in: activeSnapshot
                )

            candidateSwing = nil
            state = .clubSelected

            return .stateChanged(state)

        case let .clubChanged(clubID):
            activeSnapshot =
                try await coordinator.changeClub(
                    to: clubID,
                    in: activeSnapshot
                )

            candidateSwing = nil
            state = .clubSelected

            return .stateChanged(state)

        case .addressDetected:
            guard canAcceptSwingObservation else {
                return .noAction
            }

            state = .addressDetected
            return .stateChanged(state)

        case let .swingDetected(observation):
            guard canAcceptSwingObservation else {
                return .noAction
            }

            candidateSwing = CandidateSwing(
                observation: observation,
                origin:
                    lastLocation?.coordinate
            )

            state = .validatingCandidateSwing

            return try await evaluateCandidate()

        case let .impactDetected(observation):
            guard var candidate =
                    candidateSwing else {
                return .noAction
            }

            candidate.impactDetected = true
            candidate.impactConfidence =
                observation.confidence

            candidateSwing = candidate
            state = .validatingCandidateSwing

            return try await evaluateCandidate()

        case .golferDepartedShotOrigin:
            guard var candidate =
                    candidateSwing else {
                return .noAction
            }

            candidate.golferDepartedOrigin = true
            candidateSwing = candidate

            return try await evaluateCandidate()

        case .candidateSwingTimeout:
            return rejectCandidateAsPracticeSwing()

        case .practiceSwingConfirmedByGolfer,
             .candidateSwingRejected:
            return rejectCandidateAsPracticeSwing()

        case .shotConfirmedByGolfer:
            guard var candidate =
                    candidateSwing else {
                return .noAction
            }

            candidate.classification =
                .golferCorrected

            candidate.computedConfidence =
                max(
                    candidate.computedConfidence,
                    thresholds
                        .automaticConfirmation
                )

            candidateSwing = candidate

            return try await confirmCandidateAsShot()

        case let .voiceFeedbackReceived(
            transcript
        ):
            return try await processVoiceFeedback(
                transcript
            )

        default:
            return .noAction
        }
    }

    private var canAcceptSwingObservation:
        Bool {

        switch state {
        case .clubSelected,
             .preparingForShot,
             .addressDetected,
             .practiceSwingDetected,
             .awaitingCommittedSwing,
             .validatingCandidateSwing,
             .awaitingShotConfirmation:
            return true

        default:
            return false
        }
    }

    private func persistOrchestratorState()
        async throws {

        guard let snapshotStore else {
            return
        }

        let existing = try await snapshotStore.load(
            roundID: activeSnapshot.round.id
        )

        let nextRevision =
            (existing?.localRevision ?? 0) + 1

        let snapshot = RoundOrchestratorSnapshot(
            roundID: activeSnapshot.round.id,
            state: state,
            candidateSwing: candidateSwing,
            lastLocation: lastLocation,
            localRevision: nextRevision
        )

        try await snapshotStore.save(snapshot)
    }
    
    private func evaluateCandidate()
        async throws -> RoundOrchestratorOutput {

        guard let candidate =
                candidateSwing else {
            return .noAction
        }

        let evaluation =
            confidenceEvaluator.evaluate(
                candidate,
                thresholds: thresholds
            )

        candidateSwing =
            evaluation.candidate

        switch evaluation.decision {

        case .confirmPlayedShot:
            return try await
                confirmCandidateAsShot()

        case .requestGolferConfirmation:
            state =
                .awaitingShotConfirmation

            return .requestShotConfirmation(
                confidence:
                    evaluation.candidate
                        .computedConfidence
            )

        case .treatAsPracticeSwing:
            return rejectCandidateAsPracticeSwing(
                confidence:
                    evaluation.candidate
                        .computedConfidence
            )
        }
    }

    private func confirmCandidateAsShot()
        async throws -> RoundOrchestratorOutput {

        if activeSnapshot.round.state ==
            .clubSelected {

            activeSnapshot =
                try await coordinator.markShotHit(
                    in: activeSnapshot
                )
        }

        guard activeSnapshot.round.state ==
                .awaitingShotFeedback else {
            return .noAction
        }

        if var candidate = candidateSwing,
           candidate.classification ==
            .uncertain {

            candidate.classification =
                .playedShot

            candidateSwing = candidate
        }

        state = .awaitingShotFeedback

        return .shotConfirmed
    }

    private func rejectCandidateAsPracticeSwing(
        confidence: Double? = nil
    ) -> RoundOrchestratorOutput {

        let resolvedConfidence =
            confidence ??
            candidateSwing?
                .computedConfidence ??
            0

        if var candidate = candidateSwing {
            candidate.classification =
                .practice
            candidateSwing = candidate
        }

        candidateSwing = nil
        state = .awaitingCommittedSwing

        return .practiceSwingIgnored(
            confidence:
                resolvedConfidence
        )
    }

    private func processVoiceFeedback(
        _ transcript: String
    ) async throws -> RoundOrchestratorOutput {

        if state == .awaitingShotFeedback {
            activeSnapshot =
                try await coordinator
                    .recordShotFeedback(
                        transcript: transcript,
                        in: activeSnapshot
                    )

            candidateSwing = nil
            state = .walkingToBall

            return .shotFeedbackRecorded
        }

        guard var candidate =
                candidateSwing else {
            return .noAction
        }

        candidate.feedbackReceived = true
        candidateSwing = candidate

        let evaluationOutput =
            try await evaluateCandidate()

        switch evaluationOutput {
        case .shotConfirmed:
            activeSnapshot =
                try await coordinator
                    .recordShotFeedback(
                        transcript: transcript,
                        in: activeSnapshot
                    )

            candidateSwing = nil
            state = .walkingToBall

            return .shotFeedbackRecorded

        default:
            return evaluationOutput
        }
    }

    private static func initialState(
        for round: Round
    ) -> OrchestratorState {

        switch round.state {
        case .roundActive:
            return .awaitingTeeConfirmation

        case .awaitingHoleConfirmation:
            return .awaitingHoleConfirmation

        case .awaitingClub:
            return .awaitingClubSelection

        case .clubSelected:
            return .clubSelected

        case .awaitingShotFeedback:
            return .awaitingShotFeedback

        case .awaitingBallPosition:
            return .walkingToBall

        case .putting:
            return .putting

        case .holePendingCompletion:
            return .holePendingCompletion

        case .roundCompleted:
            return .idle

        default:
            return .recovering
        }
    }
}
