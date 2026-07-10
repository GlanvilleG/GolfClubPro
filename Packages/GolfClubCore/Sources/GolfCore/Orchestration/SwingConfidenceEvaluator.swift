//
//  SwingConfidenceEvaluator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct SwingConfidenceThresholds:
    Codable,
    Equatable,
    Sendable {

    public var automaticConfirmation: Double
    public var confirmationRequired: Double

    public init(
        automaticConfirmation: Double = 0.70,
        confirmationRequired: Double = 0.40
    ) {
        self.automaticConfirmation =
            min(1, max(0, automaticConfirmation))

        self.confirmationRequired =
            min(
                self.automaticConfirmation,
                max(0, confirmationRequired)
            )
    }
}

public enum CandidateSwingDecision:
    Codable,
    Equatable,
    Sendable {

    case confirmPlayedShot
    case requestGolferConfirmation
    case treatAsPracticeSwing
}

public struct SwingConfidenceEvaluator:
    Sendable {

    public init() {}

    public func evaluate(
        _ candidate: CandidateSwing,
        thresholds: SwingConfidenceThresholds =
            SwingConfidenceThresholds()
    ) -> (
        candidate: CandidateSwing,
        decision: CandidateSwingDecision
    ) {
        var updated = candidate

        var confidence =
            candidate.observation.confidence * 0.30

        if candidate.impactDetected {
            confidence +=
                (candidate.impactConfidence ?? 1) * 0.25
        }

        if candidate.golferDepartedOrigin {
            confidence += 0.20
        }

        if candidate.feedbackReceived {
            confidence += 0.15
        }

        if candidate.nextClubSelectedElsewhere {
            confidence += 0.10
        }

        if candidate.observation.returnedToAddress {
            confidence -= 0.25
        }

        confidence = min(1, max(0, confidence))
        updated.computedConfidence = confidence

        let decision: CandidateSwingDecision

        if confidence >=
            thresholds.automaticConfirmation {
            updated.classification = .playedShot
            decision = .confirmPlayedShot

        } else if confidence >=
                    thresholds.confirmationRequired {
            updated.classification = .uncertain
            decision = .requestGolferConfirmation

        } else {
            updated.classification = .practice
            decision = .treatAsPracticeSwing
        }

        return (updated, decision)
    }
}
