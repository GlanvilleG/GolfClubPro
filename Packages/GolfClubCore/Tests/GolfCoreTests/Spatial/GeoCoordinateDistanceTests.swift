//
//  GeoCoordinateDistanceTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

//
//  GeoCoordinateDistanceTests.swift
//  GolfCoreTests
//

import XCTest
@testable import GolfCore

final class GeoCoordinateDistanceTests:
    XCTestCase {

    func testSameCoordinateReturnsZero() {
        let coordinate =
            GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )

        let distance =
            DistanceCalculator.distanceMeters(
                from: coordinate,
                to: coordinate
            )

        XCTAssertEqual(
            distance,
            0,
            accuracy: 0.0001
        )
    }

    func testDistanceIsSymmetrical() {
        let first =
            GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )

        let second =
            GeoCoordinate(
                latitude: -39.9275,
                longitude: 175.0520
            )

        let forward =
            DistanceCalculator.distanceMeters(
                from: first,
                to: second
            )

        let reverse =
            DistanceCalculator.distanceMeters(
                from: second,
                to: first
            )

        XCTAssertEqual(
            forward,
            reverse,
            accuracy: 0.0001
        )
    }

    func testNearbyCoordinatesReturnReasonableDistance() {
        let tee =
            GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )

        let green =
            GeoCoordinate(
                latitude: -39.9275,
                longitude: 175.0520
            )

        let distance =
            DistanceCalculator.distanceMeters(
                from: tee,
                to: green
            )

        XCTAssertGreaterThan(
            distance,
            250
        )

        XCTAssertLessThan(
            distance,
            400
        )
    }

    func testOneDegreeOfLatitudeIsApproximately111Kilometres() {
        let first =
            GeoCoordinate(
                latitude: 0,
                longitude: 0
            )

        let second =
            GeoCoordinate(
                latitude: 1,
                longitude: 0
            )

        let distance =
            DistanceCalculator.distanceMeters(
                from: first,
                to: second
            )

        XCTAssertEqual(
            distance,
            111_195,
            accuracy: 250
        )
    }

    func testCrossingLongitudeBoundaryUsesShortestDistance() {
        let first =
            GeoCoordinate(
                latitude: 0,
                longitude: 179.9
            )

        let second =
            GeoCoordinate(
                latitude: 0,
                longitude: -179.9
            )

        let distance =
            DistanceCalculator.distanceMeters(
                from: first,
                to: second
            )

        XCTAssertLessThan(
            distance,
            25_000
        )
    }
}
