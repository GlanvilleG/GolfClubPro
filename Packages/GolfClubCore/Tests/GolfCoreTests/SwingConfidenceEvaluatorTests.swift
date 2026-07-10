//
//  SwingConfidenceEvaluatorTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class SwingConfidenceEvaluatorTests:
    XCTestCase {

    private let evaluator =
        SwingConfidenceEvaluator()

    func testHighConfidenceCandidateIsConfirmed() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1.2,
                returnedToAddress: false,
                confidence: 1
            ),
            impactDetected: true,
            impactConfidence: 1,
            golferDepartedOrigin: true,
            feedbackReceived: true,
            nextClubSelectedElsewhere: true
        )

        let result = evaluator.evaluate(candidate)

        XCTAssertEqual(
            result.decision,
            .confirmPlayedShot
        )

        XCTAssertEqual(
            result.candidate.classification,
            .playedShot
        )

        XCTAssertGreaterThanOrEqual(
            result.candidate.computedConfidence,
            0.70
        )
    }

    func testMediumConfidenceRequestsConfirmation() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: false,
                confidence: 0.8
            ),
            impactDetected: true,
            impactConfidence: 0.8
        )

        let result = evaluator.evaluate(candidate)

        XCTAssertEqual(
            result.decision,
            .requestGolferConfirmation
        )

        XCTAssertEqual(
            result.candidate.classification,
            .uncertain
        )
    }

    func testLowConfidenceCandidateIsPracticeSwing() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 0.8,
                returnedToAddress: true,
                confidence: 0.5
            )
        )

        let result = evaluator.evaluate(candidate)

        XCTAssertEqual(
            result.decision,
            .treatAsPracticeSwing
        )

        XCTAssertEqual(
            result.candidate.classification,
            .practice
        )
    }

    func testReturningToAddressReducesConfidence() {
        let withoutReturn = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: false,
                confidence: 0.8
            ),
            impactDetected: true,
            impactConfidence: 0.8
        )

        let withReturn = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: true,
                confidence: 0.8
            ),
            impactDetected: true,
            impactConfidence: 0.8
        )

        let first =
            evaluator.evaluate(withoutReturn)

        let second =
            evaluator.evaluate(withReturn)

        XCTAssertGreaterThan(
            first.candidate.computedConfidence,
            second.candidate.computedConfidence
        )
    }

    func testConfidenceIsClampedToValidRange() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: false,
                confidence: 10
            ),
            impactDetected: true,
            impactConfidence: 10,
            golferDepartedOrigin: true,
            feedbackReceived: true,
            nextClubSelectedElsewhere: true
        )

        let result = evaluator.evaluate(candidate)

        XCTAssertLessThanOrEqual(
            result.candidate.computedConfidence,
            1
        )
    }

    func testCustomThresholdsCanBeApplied() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: false,
                confidence: 0.8
            ),
            impactDetected: true,
            impactConfidence: 0.8
        )

        let thresholds =
            SwingConfidenceThresholds(
                automaticConfirmation: 0.40,
                confirmationRequired: 0.20
            )

        let result = evaluator.evaluate(
            candidate,
            thresholds: thresholds
        )

        XCTAssertEqual(
            result.decision,
            .confirmPlayedShot
        )
    }
}
