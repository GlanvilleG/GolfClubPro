//
//  HazardAwareCoachingEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class HazardAwareCoachingEngineTests:
    XCTestCase {
    
    
    func testHazardOnMissSideAddsMargin()
    {
        
        let engine =
        HazardAwareCoachingEngine()
        
       let start =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )

        let target =
            GeoCoordinate(
                latitude:
                    -39.9285,
                longitude:
                    175.0500
            )

        let hazard =
            HazardZone(
                name:
                    "Right Side Fairway Bunker",
                location:
                    GeoCoordinate(
                        latitude:
                            -39.9285,
                        longitude:
                            175.05050
                    ),
                radiusMeters:
                    20
            )
        
               
        let result =
            engine.evaluate(
                shotStart:
                    start,
                target:
                    target,
                expectedDistanceMeters:
                    180,
                playerBiasMeters:
                    8,
                hazard:
                    hazard
            )
        
        
        XCTAssertEqual(
            result.additionalAdjustmentMeters,
            5
        )
        
        
        XCTAssertGreaterThan(
            result.confidence,
            0
        )
    }
    func testHazardOppositeMissSideIgnored()
    {
        
        let engine =
        HazardAwareCoachingEngine()
        
        
        let start =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )

        let target =
            GeoCoordinate(
                latitude:
                    -39.9280,
                longitude:
                    175.0500
            )

        let hazard =
           makeLeftHazard()
        
        let result =
        engine.evaluate(
            shotStart:
                start,
            target:
                target,
            expectedDistanceMeters:
                180,
            playerBiasMeters:
                8,
            hazard:
                hazard
        )
        
        
        XCTAssertEqual(
            result.additionalAdjustmentMeters,
            0
        )
    }
    func testDistantHazardIgnored()
    {

        let engine =
            HazardAwareCoachingEngine()


       let start =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )

        let target =
            GeoCoordinate(
                latitude:
                    -39.9280,
                longitude:
                    175.0500
            )

        let hazard =
        makeDistantRightHazard()

        let result =
        engine.evaluate(
            shotStart:
                start,
            target:
                target,
            expectedDistanceMeters:
                180,
            playerBiasMeters:
                8,
            hazard:
                hazard
        )


        XCTAssertEqual(
            result.additionalAdjustmentMeters,
            0
        )
    }
    
    func testHazardWithinMissCorridorTriggersAdjustment()
    {

        let engine =
            HazardAwareCoachingEngine()


        let start =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let target =
            GeoCoordinate(
                latitude:
                    -39.9285,
                longitude:
                    175.0500
            )


        /*
         Hazard sits slightly right of the target line
         and within the expected dispersion area.
         
         Player bias:
         +8m right
        */
        
        let hazard =
            HazardZone(
                name:
                    "Right Side Fairway Bunker",
                location:
                    GeoCoordinate(
                        latitude:
                            -39.9285,
                        longitude:
                            175.05050
                    ),
                radiusMeters:
                    20
            )


        let result =
            engine.evaluate(
                shotStart:
                    start,
                target:
                    target,
                expectedDistanceMeters:
                    180,
                playerBiasMeters:
                    8,
                hazard:
                    hazard
            )


        XCTAssertEqual(
            result.additionalAdjustmentMeters,
            5
        )


        XCTAssertEqual(
            result.reason,
            "Additional margin applied because hazard overlaps player's normal miss pattern."
        )


        XCTAssertGreaterThan(
            result.confidence,
            0
        )
    }
}
private func makeRightHazard() -> HazardZone {

    HazardZone(
        name:
            "Right Fairway Bunker",
        location:
            GeoCoordinate(
                latitude:
                    -39.9295,
                longitude:
                    175.0510
            ),
        radiusMeters:
            15
    )
}
private func makeLeftHazard() -> HazardZone {

    HazardZone(
        name:
            "Left Fairway Bunker",
        location:
            GeoCoordinate(
                latitude:
                    -39.9295,
                longitude:
                    175.0490
            ),
        radiusMeters:
            15
    )
}
private func makeDistantRightHazard() -> HazardZone {

    HazardZone(
        name:
            "Distant Right Bunker",
        location:
            GeoCoordinate(
                latitude:
                    -39.9200,
                longitude:
                    175.0600
            ),
        radiusMeters:
            15
    )
}
