//
//  DispersionModelTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class DispersionModelTests: XCTestCase {

    private let model = DispersionModel()

    func testCalculatesAverageDistance() {
        let clubID = ClubID()

        let shots = [
            completedShot(
                clubID: clubID,
                distanceMeters: 140
            ),
            completedShot(
                clubID: clubID,
                distanceMeters: 150
            ),
            completedShot(
                clubID: clubID,
                distanceMeters: 145
            )
        ]

        let summary = model.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(
            summary.averageDistanceMeters ?? 0,
            145,
            accuracy: 0.001
        )

        XCTAssertEqual(summary.sampleSize, 3)
    }

    func testCalculatesDistanceStandardDeviation() {
        let clubID = ClubID()

        let shots = [
            completedShot(
                clubID: clubID,
                distanceMeters: 140
            ),
            completedShot(
                clubID: clubID,
                distanceMeters: 145
            ),
            completedShot(
                clubID: clubID,
                distanceMeters: 150
            )
        ]

        let summary = model.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertNotNil(
            summary.distanceStandardDeviationMeters
        )

        XCTAssertGreaterThan(
            summary.distanceStandardDeviationMeters ?? 0,
            0
        )
    }

    func testRightMissProducesRightTendency() {
        let clubID = ClubID()

        let shots = [
            directionalShot(
                clubID: clubID,
                endLongitude: 0.001
            ),
            directionalShot(
                clubID: clubID,
                endLongitude: 0.0012
            ),
            directionalShot(
                clubID: clubID,
                endLongitude: 0.0008
            )
        ]

        let summary = model.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(
            summary.directionalTendency,
            .right
        )

        XCTAssertGreaterThan(
            summary.averageDirectionalErrorDegrees ?? 0,
            0
        )

        XCTAssertEqual(
            summary.rightMissPercentage ?? 0,
            100,
            accuracy: 0.001
        )
    }

    func testLeftMissProducesLeftTendency() {
        let clubID = ClubID()

        let shots = [
            directionalShot(
                clubID: clubID,
                endLongitude: -0.001
            ),
            directionalShot(
                clubID: clubID,
                endLongitude: -0.0012
            ),
            directionalShot(
                clubID: clubID,
                endLongitude: -0.0008
            )
        ]

        let summary = model.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(
            summary.directionalTendency,
            .left
        )

        XCTAssertLessThan(
            summary.averageDirectionalErrorDegrees ?? 0,
            0
        )
    }

    func testInsufficientDirectionalDataIsReported() {
        let clubID = ClubID()

        let shots = [
            directionalShot(
                clubID: clubID,
                endLongitude: 0.001
            ),
            directionalShot(
                clubID: clubID,
                endLongitude: 0.001
            )
        ]

        let summary = model.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(
            summary.directionalTendency,
            .insufficientData
        )
    }

    func testShotsWithoutPlannedBearingAreExcludedFromDirectionalSample() {
        let clubID = ClubID()

        let shot = completedShot(
            clubID: clubID,
            distanceMeters: 145
        )

        let summary = model.makeSummary(
            for: clubID,
            from: [shot]
        )

        XCTAssertEqual(summary.sampleSize, 1)
        XCTAssertEqual(
            summary.directionalSampleSize,
            0
        )

        XCTAssertNil(
            summary.averageDirectionalErrorDegrees
        )
    }

    private func completedShot(
        clubID: ClubID,
        distanceMeters: Double?
    ) -> Shot {
        Shot(
            roundID: RoundID(),
            holeID: HoleID(),
            clubID: clubID,
            completedAt: Date(),
            distanceMeters: distanceMeters
        )
    }

    private func directionalShot(
        clubID: ClubID,
        endLongitude: Double
    ) -> Shot {
        Shot(
            roundID: RoundID(),
            holeID: HoleID(),
            clubID: clubID,
            completedAt: Date(),
            startLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            endLocation: GeoCoordinate(
                latitude: 0.001,
                longitude: endLongitude
            ),
            plannedBearingDegrees: 0
        )
    }
}
