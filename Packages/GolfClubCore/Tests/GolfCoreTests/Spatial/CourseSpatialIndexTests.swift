//
//  CourseSpatialIndexTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import XCTest
@testable import GolfCore

final class CourseSpatialIndexTests:
    XCTestCase {

    func testReturnsHoleByID() {
        let hole =
            makeHole()

        let index =
            CourseSpatialIndex(
                holes: [hole]
            )

        XCTAssertEqual(
            index.hole(id: hole.id),
            hole
        )
    }

    func testReturnsNilForUnknownHoleID() {
        let index =
            CourseSpatialIndex(
                holes: []
            )

        XCTAssertNil(
            index.hole(
                id: HoleID()
            )
        )
    }

    func testReturnsStoredLocations() {
        let hole =
            makeHole()

        let index =
            CourseSpatialIndex(
                holes: [hole]
            )

        XCTAssertEqual(
            index.teeLocation(
                for: hole.id
            ),
            hole.teeLocation
        )

        XCTAssertEqual(
            index.greenLocation(
                for: hole.id
            ),
            hole.greenLocation
        )
    }

    func testCalculatesDistanceWithoutSearchingHoleArray()
        throws {

        let hole =
            makeHole()

        let index =
            CourseSpatialIndex(
                holes: [hole]
            )

        let distance =
            try XCTUnwrap(
                index.distanceToTeeMeters(
                    from:
                        hole.teeLocation!,
                    holeID:
                        hole.id
                )
            )

        XCTAssertEqual(
            distance,
            0,
            accuracy: 0.0001
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
}
