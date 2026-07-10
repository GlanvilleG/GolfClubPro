//
//  PlayerStatisticsEngineTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class PlayerStatisticsEngineTests: XCTestCase {

    private let engine = PlayerStatisticsEngine()

    func testCreatesAverageDistanceForClub() {
        let clubID = ClubID()

        let shots = [
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: 140
            ),
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: 150
            ),
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: 145
            )
        ]

        let summary = engine.makeSummary(
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

    func testIncompleteShotsAreIgnored() {
        let clubID = ClubID()

        let completed = makeCompletedShot(
            clubID: clubID,
            distanceMeters: 145
        )

        let incomplete = Shot(
            roundID: RoundID(),
            holeID: HoleID(),
            clubID: clubID,
            distanceMeters: 200
        )

        let summary = engine.makeSummary(
            for: clubID,
            from: [completed, incomplete]
        )

        XCTAssertEqual(summary.sampleSize, 1)
        XCTAssertEqual(
            summary.averageDistanceMeters,
            145
        )
    }

    func testCommonErrorsAreRankedByFrequency() {
        let clubID = ClubID()

        let shots = [
            makeCompletedShot(
                clubID: clubID,
                errors: [.push, .short]
            ),
            makeCompletedShot(
                clubID: clubID,
                errors: [.push]
            ),
            makeCompletedShot(
                clubID: clubID,
                errors: [.slice]
            )
        ]

        let summary = engine.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(
            summary.commonErrors.first,
            .push
        )

        XCTAssertTrue(
            summary.commonErrors.contains(.short)
        )

        XCTAssertTrue(
            summary.commonErrors.contains(.slice)
        )
    }

    func testMaximumShotsLimitsSample() {
        let clubID = ClubID()

        let shots = (1...10).map { index in
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: Double(100 + index),
                completedAt: Date(
                    timeIntervalSince1970:
                        Double(index)
                )
            )
        }

        let summary = engine.makeSummary(
            for: clubID,
            from: shots,
            maximumShots: 5
        )

        XCTAssertEqual(summary.sampleSize, 5)

        XCTAssertEqual(
            summary.averageDistanceMeters ?? 0,
            108,
            accuracy: 0.001
        )
    }

    func testCreatesSeparateSummariesForEachClub() {
        let firstClubID = ClubID()
        let secondClubID = ClubID()

        let shots = [
            makeCompletedShot(
                clubID: firstClubID,
                distanceMeters: 140
            ),
            makeCompletedShot(
                clubID: secondClubID,
                distanceMeters: 180
            )
        ]

        let summaries =
            engine.makeRecentShotSummaries(
                from: shots
            )

        XCTAssertEqual(summaries.count, 2)

        XCTAssertTrue(
            summaries.contains {
                $0.clubID == firstClubID
            }
        )

        XCTAssertTrue(
            summaries.contains {
                $0.clubID == secondClubID
            }
        )
    }

    func testNilDistancesDoNotPreventSampleCount() {
        let clubID = ClubID()

        let shots = [
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: nil
            ),
            makeCompletedShot(
                clubID: clubID,
                distanceMeters: 150
            )
        ]

        let summary = engine.makeSummary(
            for: clubID,
            from: shots
        )

        XCTAssertEqual(summary.sampleSize, 2)
        XCTAssertEqual(
            summary.averageDistanceMeters,
            150
        )
    }

    private func makeCompletedShot(
        clubID: ClubID,
        distanceMeters: Double? = nil,
        errors: [ShotError] = [],
        completedAt: Date = Date()
    ) -> Shot {
        Shot(
            roundID: RoundID(),
            holeID: HoleID(),
            clubID: clubID,
            completedAt: completedAt,
            distanceMeters: distanceMeters,
            feedback: ShotFeedback(
                rawTranscript: "Test feedback",
                classifiedErrors: errors
            )
        )
    }
}
