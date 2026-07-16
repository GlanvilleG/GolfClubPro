//
//  CaddyInstructionEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore


final class CaddyInstructionEngineTests:
    XCTestCase {


    func testCreatesWatchInstruction()
    {


        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let adjusted =
            GeoCoordinate(
                latitude:
                    -39.9301,
                longitude:
                    175.0500
            )


        let recommendation =
            CaddyRecommendation(
                clubID:
                    ClubID(),
                target:
                    target,
                adjustedTarget:
                    adjusted,
                reasons:
                    [
                        .playerPattern
                    ],
                explanation:
                    "Adjusted",
                confidence:
                    0.85
            )


        let explanation =
            CaddyExplanation(
                summary:
                    "Target adjusted using your shot pattern.",
                items:
                    [
                        ExplanationItem(
                            title:
                                "Player pattern",
                            detail:
                                "Fade adjustment",
                            severity:
                                .information
                        )
                    ],
                confidence:
                    0.85
            )


        let result =
            CaddyInstructionEngine()
                .create(
                    recommendation:
                        recommendation,
                    explanation:
                        explanation
                )


        XCTAssertEqual(
            result.clubID,
            recommendation.clubID
        )


        XCTAssertGreaterThan(
            result.confidence,
            0
        )


        XCTAssertEqual(
            result.priority,
            .normal
        )
    }
}
