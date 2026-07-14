//
//  RecommendationSorterTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class RecommendationSorterTests:
    XCTestCase {

    private let sorter =
        RecommendationSorter()

    func testHigherScoreIsRankedFirst() {
        let lower =
            makeRecommendation(
                score: 0.70,
                distanceDifferenceMeters: 2,
                confidence: 0.90
            )

        let higher =
            makeRecommendation(
                score: 0.90,
                distanceDifferenceMeters: 20,
                confidence: 0.50
            )

        let result =
            sorter.sort([
                lower,
                higher
            ])

        XCTAssertEqual(
            result.first?.clubID,
            higher.clubID
        )
    }

    func testSmallerDistanceDifferenceBreaksScoreTie() {
        let farther =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 12,
                confidence: 0.90
            )

        let closer =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 4,
                confidence: 0.60
            )

        let result =
            sorter.sort([
                farther,
                closer
            ])

        XCTAssertEqual(
            result.first?.clubID,
            closer.clubID
        )
    }

    func testHigherConfidenceBreaksScoreAndDistanceTie() {
        let lowerConfidence =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 5,
                confidence: 0.60
            )

        let higherConfidence =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 5,
                confidence: 0.90
            )

        let result =
            sorter.sort([
                lowerConfidence,
                higherConfidence
            ])

        XCTAssertEqual(
            result.first?.clubID,
            higherConfidence.clubID
        )
    }

    func testExactTiePreservesInputOrder() {
        let first =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 5,
                confidence: 0.80
            )

        let second =
            makeRecommendation(
                score: 0.80,
                distanceDifferenceMeters: 5,
                confidence: 0.80
            )

        let result =
            sorter.sort([
                first,
                second
            ])

        XCTAssertEqual(
            result.map(\.clubID),
            [
                first.clubID,
                second.clubID
            ]
        )
    }

    func testEmptyCandidatesReturnsEmptyArray() {
        XCTAssertTrue(
            sorter.sort([]).isEmpty
        )
    }

    func testSortingDoesNotMutateInput() {
        let first =
            makeRecommendation(
                score: 0.50
            )

        let second =
            makeRecommendation(
                score: 0.90
            )

        let input = [
            first,
            second
        ]

        _ = sorter.sort(input)

        XCTAssertEqual(
            input.map(\.clubID),
            [
                first.clubID,
                second.clubID
            ]
        )
    }

    private func makeRecommendation(
        score: Double,
        distanceDifferenceMeters:
            Double = 0,
        confidence: Double = 0.80
    ) -> ClubRecommendation {

        ClubRecommendation(
            clubID:
                ClubID(),
            score:
                score,
            adjustedCarryMeters:
                150,
            distanceDifferenceMeters:
                distanceDifferenceMeters,
            confidence:
                confidence,
            reasons:
                []
        )
    }
}
