//
//  CourseGeometryEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import XCTest
@testable import GolfCore

final class CourseGeometryEngineTests:
    XCTestCase {

    private let engine =
        HoleGeometryEngine()

    func testPointInsideFairwayReturnsFairway() {
        let geometry = HoleGeometry(
            areas: [
                makeSquareArea(
                    type: .fairway
                )
            ]
        )

        let result = engine.evaluate(
            location: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            geometry: geometry
        )

        XCTAssertEqual(
            result.primaryArea,
            .fairway
        )

        XCTAssertFalse(
            result.requiresConfirmation
        )

        XCTAssertEqual(
            result.confidence,
            0.90,
            accuracy: 0.0001
        )
    }

    func testPointOutsideAllAreasReturnsUnknown() {
        let geometry = HoleGeometry(
            areas: [
                makeSquareArea(
                    type: .fairway
                )
            ]
        )

        let result = engine.evaluate(
            location: GeoCoordinate(
                latitude: -39.9400,
                longitude: 175.0600
            ),
            geometry: geometry
        )

        XCTAssertEqual(
            result.primaryArea,
            .unknown
        )

        XCTAssertTrue(
            result.requiresConfirmation
        )
    }

    func testBunkerOverridesFairwayWhenAreasOverlap() {
        let fairway =
            makeSquareArea(
                type: .fairway,
                offset: 0,
                size: 0.002
            )

        let bunker =
            makeSquareArea(
                type: .bunker,
                offset: 0.0004,
                size: 0.0004
            )

        let geometry = HoleGeometry(
            areas: [
                fairway,
                bunker
            ]
        )

        let result = engine.evaluate(
            location: GeoCoordinate(
                latitude: -39.9304,
                longitude: 175.0496
            ),
            geometry: geometry
        )

        XCTAssertEqual(
            result.primaryArea,
            .bunker
        )
    }

    func testPointNearBoundaryRequiresConfirmation() {
        let engine = HoleGeometryEngine(
            configuration:
                HoleGeometryConfiguration(
                    boundaryConfirmationDistanceMeters:
                        10
                )
        )

        let area =
            makeSquareArea(
                type: .fairway
            )

        let result = engine.evaluate(
            location: GeoCoordinate(
                latitude: -39.92901,
                longitude: 175.0500
            ),
            geometry:
                HoleGeometry(
                    areas: [area]
                )
        )

        XCTAssertEqual(
            result.primaryArea,
            .fairway
        )

        XCTAssertTrue(
            result.requiresConfirmation
        )

        XCTAssertEqual(
            result.confidence,
            0.65,
            accuracy: 0.0001
        )
    }

    func testDistanceToBoundaryIsAvailable() throws {
        let area =
            makeSquareArea(
                type: .green
            )

        let distance =
            try XCTUnwrap(
                engine.distanceToBoundary(
                    from: GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    ),
                    of: area
                )
            )

        XCTAssertGreaterThan(
            distance,
            0
        )
    }

    private func makeSquareArea(
        type: HoleAreaType,
        offset: Double = 0,
        size: Double = 0.002
    ) -> HoleArea {
        let south =
            -39.931 + offset

        let north =
            south + size

        let west =
            175.049 + offset

        let east =
            west + size

        return HoleArea(
            type: type,
            boundary: [
                GeoCoordinate(
                    latitude: south,
                    longitude: west
                ),
                GeoCoordinate(
                    latitude: south,
                    longitude: east
                ),
                GeoCoordinate(
                    latitude: north,
                    longitude: east
                ),
                GeoCoordinate(
                    latitude: north,
                    longitude: west
                )
            ]
        )
    }
}
