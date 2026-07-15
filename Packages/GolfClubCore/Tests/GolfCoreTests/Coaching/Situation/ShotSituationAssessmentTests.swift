//
//  ShotSituationAssessmentTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class ShotSituationAssessmentTests:
    XCTestCase {

    func testStoresSituationAndRationale() {
        let assessment =
            ShotSituationAssessment(
                situation:
                    .driverTeeShot,
                confidence:
                    0.90,
                rationale:
                    "Driver selected from the tee."
            )

        XCTAssertEqual(
            assessment.situation,
            .driverTeeShot
        )

        XCTAssertEqual(
            assessment.rationale,
            "Driver selected from the tee."
        )
    }

    func testClampsConfidenceAboveOne() {
        let assessment =
            ShotSituationAssessment(
                situation:
                    .driverTeeShot,
                confidence:
                    1.50,
                rationale:
                    "Test"
            )

        XCTAssertEqual(
            assessment.confidence,
            1
        )
    }

    func testClampsNegativeConfidence() {
        let assessment =
            ShotSituationAssessment(
                situation:
                    .unknown,
                confidence:
                    -0.50,
                rationale:
                    "Test"
            )

        XCTAssertEqual(
            assessment.confidence,
            0
        )
    }

    func testUnknownAssessmentHasZeroConfidence() {
        XCTAssertEqual(
            ShotSituationAssessment
                .unknown
                .situation,
            .unknown
        )

        XCTAssertEqual(
            ShotSituationAssessment
                .unknown
                .confidence,
            0
        )
    }

    func testSupportsCodableRoundTrip()
        throws {

        let original =
            ShotSituationAssessment(
                situation:
                    .fairwayBunker,
                confidence:
                    0.85,
                rationale:
                    "The ball is in a fairway bunker."
            )

        let data =
            try JSONEncoder()
                .encode(original)

        let decoded =
            try JSONDecoder()
                .decode(
                    ShotSituationAssessment.self,
                    from: data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }
}
