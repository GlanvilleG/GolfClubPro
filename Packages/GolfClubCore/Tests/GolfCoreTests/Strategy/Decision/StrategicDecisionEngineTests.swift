//
//  StrategicDecisionEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore


final class StrategicDecisionEngineTests:
    XCTestCase {
    
    
    func testSelectsLowestRiskOption()
    {
        
        let lowRisk =
        StrategicOption(
            target:
                GeoCoordinate(
                    latitude:
                        -39.9300,
                    longitude:
                        175.0500
                ),
            clubID:
                ClubID(),
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
                        130,
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
        
        
        let highRisk =
        StrategicOption(
            target:
                lowRisk.target,
            clubID:
                ClubID(),
            landingZone:
                lowRisk.landingZone,
            risk:
                RiskAssessment(
                    riskLevel:
                            .high,
                    hazardExposure:
                        0.8,
                    penaltyProbability:
                        0.8,
                    recommendation:
                        "Avoid",
                    confidence:
                        0.8
                )
        )
        
        
        let result =
        StrategicDecisionEngine()
            .select(
                options:
                    [
                        highRisk,
                        lowRisk
                    ]
            )
        
        
        XCTAssertEqual(
            result.selectedOption.risk.riskLevel,
            .low
        )
    }
}
