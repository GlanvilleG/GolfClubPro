//
//  WeatherAdjustmentTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore


final class WeatherAdjustmentTests:
    XCTestCase {
    
    func testHeadwindReducesCarry()
    {
        
        let weather =
        WeatherCondition(
            windSpeedKph:
                20,
            windDirectionDegrees:
                0,
            temperatureCelsius:
                15,
            precipitation:
                0
        )
        
        
        let result =
        WeatherAdjustmentEngine()
            .calculate(
                clubDistanceMeters:
                    150,
                shotBearingDegrees:
                    0,
                weather:
                    weather
            )
        
        
        XCTAssertLessThan(
            result.distanceAdjustmentMeters,
            0
        )
        
        
        XCTAssertTrue(
            result.explanation.contains(
                "Headwind"
            )
        )
    }
    
    func testTailwindIncreasesCarry()
    {

        let weather =
            WeatherCondition(
                windSpeedKph:
                    20,
                windDirectionDegrees:
                    180,
                temperatureCelsius:
                    15,
                precipitation:
                    0
            )


        let result =
            WeatherAdjustmentEngine()
                .calculate(
                    clubDistanceMeters:
                        150,
                    shotBearingDegrees:
                        0,
                    weather:
                        weather
                )


        XCTAssertGreaterThan(
            result.distanceAdjustmentMeters,
            0
        )
    }
}
