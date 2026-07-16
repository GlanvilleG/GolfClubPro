//
//  CaddyRecommendationEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore


final class CaddyRecommendationEngineTests:
XCTestCase {
    func testCreatesAdaptiveRecommendation()
    {
        
        let club =
        ClubID()
        
        
        let option =
        StrategicOption(
            target:
                GeoCoordinate(
                    latitude:
                        -39.9300,
                    longitude:
                        175.0500
                ),
            clubID:
                club,
            landingZone:
                LandingZoneEvaluation(
                    location:
                        GeoCoordinate(
                            latitude:
                                -39.9300,
                            longitude:
                                175.0500
                        ),
                    lieQuality:
                            .fairway,
                    hazardExposure:
                        0.1,
                    nextShotDistance:
                        120,
                    scoreExpectation:
                        4.5
                ),
            risk:
                RiskAssessment(
                    riskLevel:
                            .low,
                    hazardExposure:
                        0.1,
                    penaltyProbability:
                        0.1,
                    recommendation:
                        "Safe",
                    confidence:
                        0.8
                )
        )
        
        
        let adjustment =
        AdaptiveTargetAdjustment(
            originalTarget:
                option.target,
            adjustedTarget:
                option.target,
            adjustmentMeters:
                -8,
            reason:
                "Player bias",
            confidence:
                0.8
        )
        
        
        let result =
        CaddyRecommendationEngine()
            .create(
                option:
                    option,
                adaptiveAdjustment:
                    adjustment
            )
        
        
        XCTAssertTrue(
            result.reasons.contains(
                .playerPattern
            )
        )
    }
}
