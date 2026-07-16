//
//  DispersionRiskCalculatorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore


final class DispersionRiskCalculatorTests:
    XCTestCase {


    func testRightMissWithRightHazardCreatesRisk()
    {

        let profile =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    40,
                averageCarryMeters:
                    180,
                lateralBiasMeters:
                    8,
                shotShape:
                    .fade,
                confidence:
                    0.8
            )


        let result =
            DispersionRiskCalculator()
                .evaluate(
                    profile:
                        profile,
                    target:
                        GeoCoordinate(
                            latitude:
                                -39.9285,
                            longitude:
                                175.0500
                        ),
                    shotStart:
                        GeoCoordinate(
                            latitude:
                                -39.9300,
                            longitude:
                                175.0500
                        ),
                    hazard:
                        HazardZone(
                            name:
                                "Right Bunker",
                            location:
                                GeoCoordinate(
                                    latitude:
                                        -39.9285,
                                    longitude:
                                        175.05020
                                ),
                            radiusMeters:
                                15
                        )
                )


        XCTAssertGreaterThan(
            result.riskProbability,
            0
        )
    }
    func testOppositeSideHazardCreatesNoRisk()
    {

        let profile =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    40,
                averageCarryMeters:
                    180,
                lateralBiasMeters:
                    8,
                shotShape:
                    .fade,
                confidence:
                    0.8
            )


        let result =
            DispersionRiskCalculator()
                .evaluate(
                    profile:
                        profile,
                    target:
                        GeoCoordinate(
                            latitude:
                                -39.9285,
                            longitude:
                                175.0500
                        ),
                    shotStart:
                        GeoCoordinate(
                            latitude:
                                -39.9300,
                            longitude:
                                175.0500
                        ),
                    hazard:
                        HazardZone(
                            name:
                                "Left Bunker",
                            location:
                                GeoCoordinate(
                                    latitude:
                                        -39.9285,
                                    longitude:
                                        175.0485
                                ),
                            radiusMeters:
                                15
                        )
                )


        XCTAssertEqual(
            result.riskProbability,
            0
        )
    }
}
