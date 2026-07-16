//
//  CaddyExplanationEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore


final class CaddyExplanationEngineTests:
    XCTestCase {


    func testCreatesCombinedExplanation()
    {


        let recommendation =
            CaddyRecommendation(
                clubID:
                    ClubID(),
                target:
                    GeoCoordinate(
                        latitude:
                            -39.9300,
                        longitude:
                            175.0500
                    ),
                adjustedTarget:
                    GeoCoordinate(
                        latitude:
                            -39.9301,
                        longitude:
                            175.0500
                    ),
                reasons:
                    [
                        .playerPattern,
                        .hazardAvoidance
                    ],
                explanation:
                    "Adjusted target.",
                confidence:
                    0.8
            )


        let result =
            CaddyExplanationEngine()
                .explain(
                    recommendation:
                        recommendation
                )


        XCTAssertTrue(
            result.summary.contains(
                "shot pattern"
            )
        )


        XCTAssertEqual(
            result.items.count,
            2
        )


        XCTAssertEqual(
            result.confidence,
            0.8
        )
    }
}
