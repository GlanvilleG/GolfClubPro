//
//  HazardZoneTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class HazardZoneTests:
    XCTestCase {

    func testCreatesHazardZone() {

        let hazard =
            HazardZone(
                name:
                    "Right Fairway Bunker",
                location:
                    GeoCoordinate(
                        latitude: -39.9,
                        longitude: 175.0
                    ),
                radiusMeters:
                    20
            )

        XCTAssertEqual(
            hazard.name,
            "Right Fairway Bunker"
        )

        XCTAssertEqual(
            hazard.radiusMeters,
            20
        )
    }

    func testNegativeRadiusIsClampedToZero() {

        let hazard =
            HazardZone(
                name:
                    "Bunker",
                location:
                    GeoCoordinate(
                        latitude: 0,
                        longitude: 0
                    ),
                radiusMeters:
                    -10
            )

        XCTAssertEqual(
            hazard.radiusMeters,
            0
        )
    }

    func testDetectsLocationInsideHazard() {

        let centre =
            GeoCoordinate(
                latitude: 0,
                longitude: 0
            )

        let hazard =
            HazardZone(
                name:
                    "Hazard",
                location:
                    centre,
                radiusMeters:
                    100
            )

        XCTAssertTrue(
            hazard.contains(
                centre
            )
        )
    }
}
