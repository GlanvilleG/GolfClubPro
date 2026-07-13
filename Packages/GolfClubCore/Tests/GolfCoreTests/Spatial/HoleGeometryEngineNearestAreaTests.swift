//
//  HoleGeometryEngineNearestAreaTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import XCTest
@testable import GolfCore

final class HoleGeometryEngineNearestAreaTests:
    XCTestCase {

    private let engine =
        HoleGeometryEngine()

    func testReturnsNearestFairway() throws {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway,
                centre:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    )
            )

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                centre:
                    GeoCoordinate(
                        latitude: -39.9250,
                        longitude: 175.0550
                    )
            )

        let geometry =
            GeometryTestFactory.makeGeometry(
                areas: [
                    fairway,
                    bunker
                ]
            )

        let nearest =
            try XCTUnwrap(
                engine.nearestArea(
                    to:
                        GeoCoordinate(
                            latitude: -39.9301,
                            longitude: 175.0501
                        ),
                    geometry:
                        geometry
                )
            )

        XCTAssertEqual(
            nearest.area.type,
            .fairway
        )
    }

    func testReturnsNearestBunker() throws {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway,
                centre:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    )
            )

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                centre:
                    GeoCoordinate(
                        latitude: -39.9250,
                        longitude: 175.0550
                    )
            )

        let geometry =
            GeometryTestFactory.makeGeometry(
                areas: [
                    fairway,
                    bunker
                ]
            )

        let nearest =
            try XCTUnwrap(
                engine.nearestArea(
                    to:
                        GeoCoordinate(
                            latitude: -39.9251,
                            longitude: 175.0551
                        ),
                    geometry:
                        geometry
                )
            )

        XCTAssertEqual(
            nearest.area.type,
            .bunker
        )
    }

    func testEvaluatePrefersBunkerWhenFairwayAndBunkerOverlap() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway,
                size: 0.0020
            )

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                size: 0.0006
            )

        let geometry =
            GeometryTestFactory.makeGeometry(
                areas: [
                    fairway,
                    bunker
                ]
            )

        let result =
            engine.evaluate(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    geometry
            )

        XCTAssertEqual(
            result.primaryArea,
            .bunker
        )
    }

    func testEvaluatePrecedenceIsIndependentOfPolygonOrder() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway,
                size: 0.0020
            )

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                size: 0.0006
            )

        let firstResult =
            engine.evaluate(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [
                            fairway,
                            bunker
                        ]
                    )
            )

        let secondResult =
            engine.evaluate(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [
                            bunker,
                            fairway
                        ]
                    )
            )

        XCTAssertEqual(
            firstResult.primaryArea,
            .bunker
        )

        XCTAssertEqual(
            secondResult.primaryArea,
            .bunker
        )
    }

    func testNearestAreaReturnsMinimumBoundaryDistance()
        throws {

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                size: 0.0006
            )

        let geometry =
            HoleGeometry(
                areas: [bunker]
            )

        let position =
            GeometryTestFactory.defaultCentre

        let expectedDistance =
            try XCTUnwrap(
                engine.distanceToBoundary(
                    from: position,
                    of: bunker
                )
            )

        let nearest =
            try XCTUnwrap(
                engine.nearestArea(
                    to: position,
                    geometry: geometry
                )
            )

        XCTAssertEqual(
            nearest.area.type,
            .bunker
        )

        XCTAssertEqual(
            nearest.distanceMeters,
            expectedDistance,
            accuracy: 0.0001
        )

        XCTAssertGreaterThan(
            nearest.distanceMeters,
            0
        )
    }

    func testDistanceFromInteriorPointToBoundaryIsPositive()
        throws {

        let area =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let distance =
            try XCTUnwrap(
                engine.distanceToBoundary(
                    from:
                        GeometryTestFactory
                            .defaultCentre,
                    of:
                        area
                )
            )

        XCTAssertGreaterThan(
            distance,
            0
        )
    }

    func testDistanceOutsidePolygonIsPositive()
        throws {

        let area =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let distance =
            try XCTUnwrap(
                engine.distanceToBoundary(
                    from:
                        GeoCoordinate(
                            latitude: -39.9350,
                            longitude: 175.0550
                        ),
                    of:
                        area
                )
            )

        XCTAssertGreaterThan(
            distance,
            0
        )
    }

    func testReturnsNilForEmptyGeometry() {
        XCTAssertNil(
            engine.nearestArea(
                to:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry()
            )
        )
    }

    func testIgnoresInvalidPolygon() {
        let invalidArea =
            HoleArea(
                type: .fairway,
                boundary: [
                    GeometryTestFactory
                        .defaultCentre
                ]
            )

        XCTAssertNil(
            engine.nearestArea(
                to:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [
                            invalidArea
                        ]
                    )
            )
        )
    }
}
