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

    func testBuildsUnknownContextWhenNoHoleMatches() {
        let builder =
            RoundSpatialContextBuilder(
                holes: []
            )

        let position =
            GeoCoordinate(
                latitude: -39.93,
                longitude: 175.05
            )

        let observedAt =
            Date(
                timeIntervalSince1970:
                    1_700_000_000
            )

        let context =
            builder.build(
                golferPosition:
                    position,
                observedAt:
                    observedAt
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

    func testBuildsContextForGolferNearTee() {
        let hole =
            Hole(
                number: 1,
                par: 4,
                lengthMeters: 350,
                teeLocation:
                    GeoCoordinate(
                        latitude: -39.93,
                        longitude: 175.05
                    ),
                greenLocation:
                    GeoCoordinate(
                        latitude: -39.9275,
                        longitude: 175.052
                    )
            )

        let builder =
            RoundSpatialContextBuilder(
                holes: [hole]
            )

        let context =
            builder.build(
                golferPosition:
                    GeoCoordinate(
                        latitude: -39.93,
                        longitude: 175.05
                    ),
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
                    )
            )

        XCTAssertEqual(
            context.hole?.id,
            hole.id
        )

        XCTAssertEqual(
            context.holeLocationConfidence,
            .high
        )

        XCTAssertNotNil(
            context.remainingDistanceMeters
        )
    }

    func testGeometryAndLieAreIncludedWhenAvailable() {
        let geometry =
            HoleGeometry(
                areas: [
                    HoleArea(
                        type: .fairway,
                        boundary: [
                            GeoCoordinate(
                                latitude: -39.931,
                                longitude: 175.049
                            ),
                            GeoCoordinate(
                                latitude: -39.931,
                                longitude: 175.051
                            ),
                            GeoCoordinate(
                                latitude: -39.929,
                                longitude: 175.051
                            ),
                            GeoCoordinate(
                                latitude: -39.929,
                                longitude: 175.049
                            )
                        ]
                    )
                ]
            )

        let hole =
            Hole(
                number: 1,
                par: 4,
                lengthMeters: 350,
                teeLocation:
                    GeoCoordinate(
                        latitude: -39.93,
                        longitude: 175.05
                    ),
                greenLocation:
                    GeoCoordinate(
                        latitude: -39.9275,
                        longitude: 175.052
                    ),
                geometry:
                    geometry
            )

        let builder =
            RoundSpatialContextBuilder(
                holes: [hole]
            )

        let context =
            builder.build(
                golferPosition:
                    GeoCoordinate(
                        latitude: -39.93,
                        longitude: 175.05
                    ),
                observedAt:
                    Date(
                        timeIntervalSince1970:
                            1_700_000_000
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

        XCTAssertNotNil(
            context
                .nearestBoundaryDistanceMeters
        )
    }
}
