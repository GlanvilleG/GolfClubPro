//
//  RoundSpatialContextBuilderGeometryTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import XCTest
@testable import GolfCore

final class RoundSpatialContextBuilderGeometryTests:
    XCTestCase {

    func testFairwayGeometryProducesFairwayLie() {

        var hole = makeHole()

        hole.geometry =
            HoleGeometry(
                areas: [
                    makeSquareArea(
                        type: .fairway
                    )
                ]
            )

        let context =
            makeContext(
                hole: hole,
                position:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    )
            )

        XCTAssertEqual(
            context.holeArea,
            .fairway
        )

        XCTAssertEqual(
            context.playableLie,
            .fairway
        )
    }

    func testGreenGeometryProducesGreenLie() {

        var hole = makeHole()

        hole.geometry =
            HoleGeometry(
                areas: [
                    makeSquareArea(
                        type: .green
                    )
                ]
            )

        let context =
            makeContext(
                hole: hole,
                position:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    )
            )

        XCTAssertEqual(
            context.holeArea,
            .green
        )

        XCTAssertEqual(
            context.playableLie,
            .green
        )
    }

    func testUnknownPositionProducesUnknownLie() {

        var hole = makeHole()

        hole.geometry =
            HoleGeometry(
                areas: [
                    makeSquareArea(
                        type: .fairway
                    )
                ]
            )

        let context =
            makeContext(
                hole: hole,
                position:
                    GeoCoordinate(
                        latitude: -39.9500,
                        longitude: 175.0800
                    )
            )

        XCTAssertEqual(
            context.holeArea,
            .unknown
        )

        XCTAssertEqual(
            context.playableLie,
            .unknown
        )
    }

    // MARK: Helpers

    private func makeContext(
        hole: Hole,
        position: GeoCoordinate
    ) -> RoundSpatialContext {

        let builder =
            RoundSpatialContextBuilder()

        let input =
            RoundSpatialContextInput(
                currentHoleID:
                    hole.id,
                golferPosition:
                    position,
                observedAt:
                    Date(),
                courseIndex:
                    CourseSpatialIndex(
                        holes: [hole]
                    )
            )

        return builder.build(
            input: input
        )
    }

    private func makeHole()
        -> Hole {

        Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation:
                GeoCoordinate(
                    latitude: -39.9300,
                    longitude: 175.0500
                ),
            greenLocation:
                GeoCoordinate(
                    latitude: -39.9275,
                    longitude: 175.0520
                )
        )
    }

    private func makeSquareArea(
        type: HoleAreaType
    ) -> HoleArea {

        HoleArea(
            type: type,
            boundary: [
                GeoCoordinate(
                    latitude: -39.9310,
                    longitude: 175.0490
                ),
                GeoCoordinate(
                    latitude: -39.9310,
                    longitude: 175.0510
                ),
                GeoCoordinate(
                    latitude: -39.9290,
                    longitude: 175.0510
                ),
                GeoCoordinate(
                    latitude: -39.9290,
                    longitude: 175.0490
                )
            ]
        )
    }
}
