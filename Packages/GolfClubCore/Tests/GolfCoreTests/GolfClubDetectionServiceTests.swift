//
//  GolfClubDetectionServiceTests.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import XCTest
@testable import GolfCore

final class GolfClubDetectionServiceTests:
    XCTestCase {

    private let service =
        GolfClubDetectionService()

    func testDetectsNearbyGolfClub() throws {
        let nearbyClub = GolfClub(
            name: "Nearby Club",
            location: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            detectionRadiusMeters: 1_000
        )

        let distantClub = GolfClub(
            name: "Distant Club",
            location: GeoCoordinate(
                latitude: -39.9800,
                longitude: 175.1000
            ),
            detectionRadiusMeters: 1_000
        )

        let result = service.detectGolfClub(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: -39.9301,
                    longitude: 175.0501
                ),
                horizontalAccuracyMeters: 5
            ),
            among: [
                nearbyClub,
                distantClub
            ]
        )

        XCTAssertEqual(
            result.status,
            .detected
        )

        XCTAssertEqual(
            result.selectedGolfClubID,
            nearbyClub.id
        )
    }

    func testReturnsNotFoundOutsideAllRadii() {
        let club = GolfClub(
            name: "Club",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            detectionRadiusMeters: 100
        )

        let result = service.detectGolfClub(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 1,
                    longitude: 1
                ),
                horizontalAccuracyMeters: 5
            ),
            among: [club]
        )

        XCTAssertEqual(
            result.status,
            .notFound
        )

        XCTAssertNil(
            result.selectedGolfClubID
        )
    }

    func testPoorAccuracyIsRejected() {
        let club = GolfClub(
            name: "Club",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            )
        )

        let result = service.detectGolfClub(
            from: LocationObservation(
                coordinate: club.location,
                horizontalAccuracyMeters: 200
            ),
            among: [club]
        )

        XCTAssertEqual(
            result.status,
            .insufficientAccuracy
        )
    }

    func testNearbyClubsCanBeAmbiguous() {
        let first = GolfClub(
            name: "First",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            detectionRadiusMeters: 1_000
        )

        let second = GolfClub(
            name: "Second",
            location: GeoCoordinate(
                latitude: 0.0005,
                longitude: 0
            ),
            detectionRadiusMeters: 1_000
        )

        let result = service.detectGolfClub(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 0.00025,
                    longitude: 0
                ),
                horizontalAccuracyMeters: 5
            ),
            among: [first, second]
        )

        XCTAssertEqual(
            result.status,
            .ambiguous
        )

        XCTAssertNil(
            result.selectedGolfClubID
        )

        XCTAssertEqual(
            result.candidates.count,
            2
        )
    }
}
