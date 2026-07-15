//
//  ShotOutcomeAssessmentTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotOutcomeAssessmentTests:
    XCTestCase {

    func testCreatesAssessment() {

        let assessment =
            ShotOutcomeAssessment(
                decisionQuality:
                    .excellent,
                executionQuality:
                    .good,
                feedback:
                    [
                        "Target strategy achieved."
                    ]
            )

        XCTAssertEqual(
            assessment.decisionQuality,
            .excellent
        )

        XCTAssertEqual(
            assessment.executionQuality,
            .good
        )
    }
    func testSuccessfulAssessment() {

        let assessment =
            ShotOutcomeAssessment.successful(
                feedback:
                    [
                        "Excellent execution."
                    ]
            )

        XCTAssertEqual(
            assessment.decisionQuality,
            .excellent
        )

        XCTAssertEqual(
            assessment.executionQuality,
            .excellent
        )
    }
    func testSupportsCodable()
    throws {

        let original =
            ShotOutcomeAssessment(
                decisionQuality:
                    .good,
                executionQuality:
                    .needsImprovement,
                feedback:
                    [
                        "Strategy was correct."
                    ]
            )

        let data =
            try JSONEncoder()
                .encode(original)

        let decoded =
            try JSONDecoder()
                .decode(
                    ShotOutcomeAssessment.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }
}
