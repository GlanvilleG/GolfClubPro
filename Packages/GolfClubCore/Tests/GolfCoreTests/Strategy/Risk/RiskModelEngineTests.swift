//
//  RiskModelEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore


final class RiskModelEngineTests:
    XCTestCase {


    func testLowRiskLandingZone()
    {

        let zone =
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
                    4.2
            )


        let result =
            RiskModelEngine()
                .evaluate(
                    landingZone:
                        zone
                )


        XCTAssertEqual(
            result.riskLevel,
            .low
        )


        XCTAssertEqual(
            result.penaltyProbability,
            0.1
        )
    }



    func testExtremeRiskLandingZone()
    {

        let zone =
            LandingZoneEvaluation(
                location:
                    GeoCoordinate(
                        latitude:
                            -39.9300,
                        longitude:
                            175.0500
                    ),
                lieQuality:
                    .unknown,
                hazardExposure:
                    0.8,
                nextShotDistance:
                    120,
                scoreExpectation:
                    6
            )


        let result =
            RiskModelEngine()
                .evaluate(
                    landingZone:
                        zone
                )


        XCTAssertEqual(
            result.riskLevel,
            .extreme
        )


        XCTAssertEqual(
            result.penaltyProbability,
            0.8
        )
    }
}

