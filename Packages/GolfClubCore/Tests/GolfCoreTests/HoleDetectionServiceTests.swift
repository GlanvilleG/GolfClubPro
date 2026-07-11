//
//  HoleDetectionServiceTests.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//
import XCTest
@testable import GolfCore

final class HoleDetectionServiceTests:
    XCTestCase {

    private let service =
        HoleDetectionService()

    func testDetectsHoleNearTee() {
        let firstHole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            )
        )

        let secondHole = Hole(
            number: 2,
            par: 4,
            lengthMeters: 370,
            teeLocation: GeoCoordinate(
                latitude: 0.01,
                longitude: 0.01
            )
        )

        let result = service.detectHole(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 0.00005,
                    longitude: 0
                ),
                horizontalAccuracyMeters: 3
            ),
            among: [firstHole, secondHole]
        )

        XCTAssertEqual(
            result.status,
            .detected
        )

        XCTAssertEqual(
            result.selectedHoleID,
            firstHole.id
        )
    }

    func testSupportsStartingOnAnyHole() {
        let tenthHole = Hole(
            number: 10,
            par: 4,
            lengthMeters: 380,
            teeLocation: GeoCoordinate(
                latitude: 1,
                longitude: 1
            )
        )

        let result = service.detectHole(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 1.00002,
                    longitude: 1
                ),
                horizontalAccuracyMeters: 3
            ),
            among: [tenthHole]
        )

        XCTAssertEqual(
            result.selectedHoleID,
            tenthHole.id
        )
    }

    func testReturnsNotFoundAwayFromTees() {
        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            teeDetectionRadiusMeters: 30
        )

        let result = service.detectHole(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 1,
                    longitude: 1
                ),
                horizontalAccuracyMeters: 3
            ),
            among: [hole]
        )

        XCTAssertEqual(
            result.status,
            .notFound
        )
    }

    func testNextHoleReceivesConfidenceBoost() {
        let firstHole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            teeDetectionRadiusMeters: 50
        )

        let secondHole = Hole(
            number: 2,
            par: 4,
            lengthMeters: 360,
            teeLocation: GeoCoordinate(
                latitude: 0.0001,
                longitude: 0
            ),
            teeDetectionRadiusMeters: 50
        )

        let result = service.detectHole(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 0.00008,
                    longitude: 0
                ),
                horizontalAccuracyMeters: 3
            ),
            among: [firstHole, secondHole],
            previouslyCompletedHoleNumber: 1
        )

        let secondCandidate =
            result.candidates.first {
                $0.holeID == secondHole.id
            }

        let firstCandidate =
            result.candidates.first {
                $0.holeID == firstHole.id
            }

        XCTAssertGreaterThan(
            secondCandidate?.confidence ?? 0,
            firstCandidate?.confidence ?? 0
        )
    }

    func testPoorAccuracyIsRejected() {
        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            )
        )

        let result = service.detectHole(
            from: LocationObservation(
                coordinate: GeoCoordinate(
                    latitude: 0,
                    longitude: 0
                ),
                horizontalAccuracyMeters: 100
            ),
            among: [hole]
        )

        XCTAssertEqual(
            result.status,
            .insufficientAccuracy
        )
    }
}
