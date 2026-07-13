//
//  RoundSpatialContextBuilderTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import XCTest
@testable import GolfCore

final class RoundSpatialContextBuilderTests:
    XCTestCase {

    func testBuildsUnknownContextWhenNoHoleIsActive() {

        let builder =
            RoundSpatialContextBuilder()

        let input =
            RoundSpatialContextInput(
                currentHoleID: nil,
                golferPosition:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    ),
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
                    ),
                courseIndex:
                    CourseSpatialIndex(
                        holes: []
                    )
            )

        let context =
            builder.build(
                input: input
            )

        XCTAssertNil(
            context.hole
        )

        XCTAssertEqual(
            context.holeLocationConfidence,
            .none
        )

        XCTAssertTrue(
            context.requiresConfirmation
        )

        XCTAssertNil(
            context.distanceToTeeMeters
        )

        XCTAssertNil(
            context.distanceToGreenMeters
        )
    }

    func testBuildsContextForActiveHoleWithoutGeometry()
        throws {

        let hole =
            makeHole()

        let builder =
            RoundSpatialContextBuilder()

        let input =
            RoundSpatialContextInput(
                currentHoleID:
                    hole.id,
                golferPosition:
                    hole.teeLocation!,
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
                    ),
                courseIndex:
                    CourseSpatialIndex(
                        holes: [hole]
                    )
            )

        let context =
            builder.build(
                input: input
            )

        XCTAssertEqual(
            context.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            context.holeLocationConfidence,
            .certain
        )

        let teeDistance =
            try XCTUnwrap(
                context.distanceToTeeMeters
            )

        XCTAssertEqual(
            teeDistance,
            0,
            accuracy: 0.001
        )

        XCTAssertNotNil(
            context.distanceToGreenMeters
        )

        XCTAssertNil(
            context.holeArea
        )

        XCTAssertNil(
            context.playableLie
        )

        XCTAssertFalse(
            context.requiresConfirmation
        )
    }

    func testBuildsContextWithGeometry()
        throws {

        var hole =
            makeHole()

        hole.geometry =
            HoleGeometry(
                areas: [
                    HoleArea(
                        type: .fairway,
                        boundary: [
                            GeoCoordinate(
                                latitude: -39.9305,
                                longitude: 175.0495
                            ),
                            GeoCoordinate(
                                latitude: -39.9305,
                                longitude: 175.0505
                            ),
                            GeoCoordinate(
                                latitude: -39.9295,
                                longitude: 175.0505
                            ),
                            GeoCoordinate(
                                latitude: -39.9295,
                                longitude: 175.0495
                            )
                        ]
                    )
                ]
            )

        let builder =
            RoundSpatialContextBuilder()

        let input =
            RoundSpatialContextInput(
                currentHoleID:
                    hole.id,
                golferPosition:
                    GeoCoordinate(
                        latitude: -39.9300,
                        longitude: 175.0500
                    ),
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
                    ),
                courseIndex:
                    CourseSpatialIndex(
                        holes: [hole]
                    )
            )

        let context =
            builder.build(
                input: input
            )

        XCTAssertEqual(
            context.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            context.holeArea,
            .fairway
        )

        XCTAssertEqual(
            context.playableLie,
            .fairway
        )

        XCTAssertNotNil(
            context.nearestBoundaryDistanceMeters
        )
    }

    func testUnknownHoleIDReturnsUnknownContext() {

        let hole =
            makeHole()

        let builder =
            RoundSpatialContextBuilder()

        let input =
            RoundSpatialContextInput(
                currentHoleID:
                    HoleID(),
                golferPosition:
                    hole.teeLocation!,
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
                    ),
                courseIndex:
                    CourseSpatialIndex(
                        holes: [hole]
                    )
            )

        let context =
            builder.build(
                input: input
            )

        XCTAssertNil(
            context.hole
        )

        XCTAssertEqual(
            context.holeLocationConfidence,
            .none
        )

        XCTAssertTrue(
            context.requiresConfirmation
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
