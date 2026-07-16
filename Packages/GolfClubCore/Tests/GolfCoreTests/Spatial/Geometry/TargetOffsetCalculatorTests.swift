//
//  TargetOffsetCalculatorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class TargetOffsetCalculatorTests:
    XCTestCase {


    func testZeroOffsetReturnsOriginalTarget()
    {

        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let result =
            TargetOffsetCalculator.offset(
                target:
                    target,
                bearingDegrees:
                    0,
                offsetMeters:
                    0
            )


        XCTAssertEqual(
            result,
            target
        )
    }
    
    func testOffsetNorthChangesLatitude()
    {

        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let result =
            TargetOffsetCalculator.offset(
                target:
                    target,
                bearingDegrees:
                    0,
                offsetMeters:
                    100
            )


        XCTAssertGreaterThan(
            result.latitude,
            target.latitude
        )


        XCTAssertEqual(
            result.longitude,
            target.longitude,
            accuracy:
                0.000001
        )
    }
    func testOffsetEastChangesLongitude()
    {

        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let result =
            TargetOffsetCalculator.offset(
                target:
                    target,
                bearingDegrees:
                    90,
                offsetMeters:
                    100
            )


        XCTAssertGreaterThan(
            result.longitude,
            target.longitude
        )
    }
    
    func testGolfTargetAdjustment()
    {

        let target =
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            )


        let adjusted =
            TargetOffsetCalculator.offset(
                target:
                    target,
                bearingDegrees:
                    0,
                offsetMeters:
                    -8
            )


        XCTAssertLessThan(
            adjusted.latitude,
            target.latitude
        )
    }
}
