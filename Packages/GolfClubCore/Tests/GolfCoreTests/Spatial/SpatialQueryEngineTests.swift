//
//  SpatialQueryEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import XCTest
@testable import GolfCore

final class SpatialQueryEngineTests:
    XCTestCase {

    private let engine =
        SpatialQueryEngine()

    func testAnalyseReturnsNearestArea() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let analysis =
            engine.analyse(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [fairway]
                    )
            )

        XCTAssertEqual(
            analysis.nearestArea?.type,
            .fairway
        )

        XCTAssertNotNil(
            analysis
                .nearestAreaDistanceMeters
        )
    }

    func testAnalyseDetectsInsideMappedArea() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let analysis =
            engine.analyse(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [fairway]
                    )
            )

        XCTAssertTrue(
            analysis.insideMappedArea
        )
    }

    func testAnalyseReturnsOutsideMappedArea() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let analysis =
            engine.analyse(
                location:
                    GeoCoordinate(
                        latitude: -39.9500,
                        longitude: 175.0800
                    ),
                geometry:
                    HoleGeometry(
                        areas: [fairway]
                    )
            )

        XCTAssertFalse(
            analysis.insideMappedArea
        )
    }

    func testAnalyseReturnsNearestHazard() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway,
                centre:
                    GeometryTestFactory
                        .defaultCentre
            )

        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker,
                centre:
                    GeoCoordinate(
                        latitude: -39.9290,
                        longitude: 175.0510
                    ),
                size: 0.0004
            )

        let analysis =
            engine.analyse(
                location:
                    GeoCoordinate(
                        latitude: -39.9291,
                        longitude: 175.0511
                    ),
                geometry:
                    HoleGeometry(
                        areas: [
                            fairway,
                            bunker
                        ]
                    )
            )

        XCTAssertEqual(
            analysis.nearestHazard?.type,
            .bunker
        )

        XCTAssertNotNil(
            analysis
                .nearestHazardDistanceMeters
        )
    }

    func testPlayingSurfaceIsNotReturnedAsHazard() {
        let fairway =
            GeometryTestFactory.makeSquareArea(
                type: .fairway
            )

        let analysis =
            engine.analyse(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry(
                        areas: [fairway]
                    )
            )

        XCTAssertNil(
            analysis.nearestHazard
        )

        XCTAssertNil(
            analysis
                .nearestHazardDistanceMeters
        )
    }

    func testAnalyseReturnsEmptyResultForEmptyGeometry() {
        let analysis =
            engine.analyse(
                location:
                    GeometryTestFactory
                        .defaultCentre,
                geometry:
                    HoleGeometry()
            )

        XCTAssertNil(
            analysis.nearestArea
        )

        XCTAssertNil(
            analysis.nearestHazard
        )

        XCTAssertFalse(
            analysis.insideMappedArea
        )
    }
}
