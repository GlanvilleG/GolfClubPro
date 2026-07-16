
//
//  AdaptiveCoachingEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore

final class AdaptiveCoachingEngineTests:
    XCTestCase {


    func testNoAdjustmentWithoutConfidence()
    {

        let engine =
            AdaptiveCoachingEngine()


        let clubID =
            ClubID()


        let profile =
            ShotDispersionProfile(
                clubID:
                    clubID,
                sampleCount:
                    5,
                averageCarryMeters:
                    180,
                lateralBiasMeters:
                    8,
                shotShape:
                    .fade,
                confidence:
                    0.2
            )


        let performance =
            PlayerPerformanceModel(
                playerID:
                    PlayerID(),
                dispersionProfiles:
                    [
                        profile
                    ]
            )


        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let adjustment =
            engine.adjustTarget(
                plannedTarget:
                    target,
                bearingDegrees:
                    0,
                clubID:
                    clubID,
                performance:
                    performance
            )


        XCTAssertEqual(
            adjustment.adjustmentMeters,
            0
        )
    }
    
    func testAdjustsForLearnedRightBias()
    {

        let engine =
            AdaptiveCoachingEngine()


        let clubID =
            ClubID()


        let profile =
            ShotDispersionProfile(
                clubID:
                    clubID,
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


        let performance =
            PlayerPerformanceModel(
                playerID:
                    PlayerID(),
                dispersionProfiles:
                    [
                        profile
                    ]
            )


        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let adjustment =
            engine.adjustTarget(
                plannedTarget:
                    target,
                bearingDegrees:
                    0,
                clubID:
                    clubID,
                performance:
                    performance
            )


        XCTAssertEqual(
            adjustment.adjustmentMeters,
            -8
        )


        XCTAssertEqual(
            adjustment.confidence,
            0.8
        )
    }
    func testAdjustedTargetMovesBasedOnPlayerBias()
    {

        let engine =
            AdaptiveCoachingEngine()


        let clubID =
            ClubID()


        let profile =
            ShotDispersionProfile(
                clubID:
                    clubID,
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


        let performance =
            PlayerPerformanceModel(
                playerID:
                    PlayerID(),
                dispersionProfiles:
                    [
                        profile
                    ]
            )


        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let result =
            engine.adjustTarget(
                plannedTarget:
                    target,
                bearingDegrees:
                    0,
                clubID:
                    clubID,
                performance:
                    performance
            )


        XCTAssertNotEqual(
            result.adjustedTarget,
            target
        )
    }
}

