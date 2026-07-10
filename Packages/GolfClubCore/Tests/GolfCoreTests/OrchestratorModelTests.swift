//
//  OrchestratorModelTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class OrchestratorModelTests:
    XCTestCase {

    func testSwingObservationClampsConfidence() {
        let observation = SwingObservation(
            durationSeconds: 1,
            returnedToAddress: false,
            confidence: 2
        )

        XCTAssertEqual(
            observation.confidence,
            1
        )
    }

    func testNegativeSwingDurationIsClamped() {
        let observation = SwingObservation(
            durationSeconds: -1,
            returnedToAddress: false,
            confidence: 0.5
        )

        XCTAssertEqual(
            observation.durationSeconds,
            0
        )
    }

    func testCandidateDefaultsToUncertain() {
        let candidate = CandidateSwing(
            observation: SwingObservation(
                durationSeconds: 1,
                returnedToAddress: false,
                confidence: 0.5
            )
        )

        XCTAssertEqual(
            candidate.classification,
            .uncertain
        )
    }

    func testLocationAccuracyIsClamped() {
        let observation = LocationObservation(
            coordinate: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            horizontalAccuracyMeters: -10
        )

        XCTAssertEqual(
            observation.horizontalAccuracyMeters,
            0
        )
    }

    func testOrchestratorEventsAreCodable()
        throws {

        let event =
            RoundOrchestratorEvent.swingDetected(
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                )
            )

        let data = try JSONEncoder().encode(event)

        let decoded = try JSONDecoder().decode(
            RoundOrchestratorEvent.self,
            from: data
        )

        XCTAssertEqual(decoded, event)
    }
}
