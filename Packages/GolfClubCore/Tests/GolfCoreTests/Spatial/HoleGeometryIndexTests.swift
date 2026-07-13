//
//  HoleGeometryIndexTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import XCTest
@testable import GolfCore

final class HoleGeometryIndexTests:
    XCTestCase {

    func testEmptyIndexReturnsNoHole() {
        let index =
            HoleGeometryIndex(
                holes: []
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset: 0,
                longitudeOffset: 0
            )
        )

        XCTAssertNil(result.hole)
        XCTAssertEqual(
            result.confidence,
            .none
        )
        XCTAssertTrue(
            result.requiresConfirmation
        )
    }

    func testGolferNearTeeReturnsHighConfidence() {
        let hole = makeHole(
            number: 1,
            teeLatitudeOffset: 0,
            greenLatitudeOffset:
                0.003
        )

        let index =
            HoleGeometryIndex(
                holes: [hole]
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset:
                    0.00005,
                longitudeOffset: 0
            )
        )

        XCTAssertEqual(
            result.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            result.confidence,
            .high
        )

        XCTAssertFalse(
            result.requiresConfirmation
        )
    }

    func testGolferNearGreenReturnsHighConfidence() {
        let hole = makeHole(
            number: 1,
            teeLatitudeOffset: 0,
            greenLatitudeOffset:
                0.003
        )

        let index =
            HoleGeometryIndex(
                holes: [hole]
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset:
                    0.00305,
                longitudeOffset: 0
            )
        )

        XCTAssertEqual(
            result.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            result.confidence,
            .high
        )
    }

    func testNearestHoleIsSelected() {
        let hole1 = makeHole(
            number: 1,
            teeLatitudeOffset: 0,
            greenLatitudeOffset:
                0.003
        )

        let hole2 = makeHole(
            number: 2,
            teeLatitudeOffset:
                0.010,
            greenLatitudeOffset:
                0.013
        )

        let index =
            HoleGeometryIndex(
                holes: [
                    hole1,
                    hole2
                ]
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset:
                    0.01005,
                longitudeOffset: 0
            )
        )

        XCTAssertEqual(
            result.hole?.id,
            hole2.id
        )
    }

    func testDistantGolferReturnsNoHole() {
        let hole = makeHole(
            number: 1,
            teeLatitudeOffset: 0,
            greenLatitudeOffset:
                0.003
        )

        let index =
            HoleGeometryIndex(
                holes: [hole]
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset:
                    0.100,
                longitudeOffset:
                    0.100
            )
        )

        XCTAssertNil(result.hole)

        XCTAssertEqual(
            result.confidence,
            .none
        )
    }

    func testGolferAtTeeReturnsHighConfidence() {
        let hole = makeHole(
            number: 1,
            teeLatitudeOffset: 0,
            greenLatitudeOffset: 0.003
        )

        let index =
            HoleGeometryIndex(
                holes: [hole]
            )

        let result = index.locate(
            golfer: coordinate(
                latitudeOffset: 0,
                longitudeOffset: 0
            )
        )

        XCTAssertEqual(
            result.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            result.confidence,
            .high
        )

        XCTAssertNil(
            result.nearestArea
        )

        XCTAssertFalse(
            result.requiresConfirmation
        )
    }
    private func makeHole(
        number: Int,
        teeLatitudeOffset: Double,
        greenLatitudeOffset: Double
    ) -> Hole {

        Hole(
            number: number,
            par: 4,
            lengthMeters: 350,
            teeLocation:
                coordinate(
                    latitudeOffset:
                        teeLatitudeOffset,
                    longitudeOffset: 0
                ),
            greenLocation:
                coordinate(
                    latitudeOffset:
                        greenLatitudeOffset,
                    longitudeOffset: 0
                )
        )
    }

    private func coordinate(
        latitudeOffset: Double,
        longitudeOffset: Double
    ) -> GeoCoordinate {

        GeoCoordinate(
            latitude:
                -39.9300 +
                latitudeOffset,
            longitude:
                175.0500 +
                longitudeOffset
        )
    }
}
