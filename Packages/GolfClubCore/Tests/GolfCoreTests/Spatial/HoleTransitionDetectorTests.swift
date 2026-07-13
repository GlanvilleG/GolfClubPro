//
//  HoleTransitionDetectorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import XCTest
@testable import GolfCore

final class HoleTransitionDetectorTests:
    XCTestCase {

    func testSameHoleReturnsNoChange() {
        let hole =
            makeHole(number: 1)

        let context =
            makeContext(
                hole: hole,
                confidence: .high
            )

        var detector =
            HoleTransitionDetector()

        let result =
            detector.evaluate(
                previous: context,
                current: context
            )

        XCTAssertEqual(
            result,
            .noChange
        )
    }

    func testFirstObservationOnNewHoleIsPossible() {
        let firstHole =
            makeHole(number: 1)

        let secondHole =
            makeHole(number: 2)

        var detector =
            HoleTransitionDetector()

        let result =
            detector.evaluate(
                previous:
                    makeContext(
                        hole: firstHole,
                        confidence: .high
                    ),
                current:
                    makeContext(
                        hole: secondHole,
                        confidence: .high
                    )
            )

        XCTAssertEqual(
            result,
            .possible(
                fromHoleID:
                    firstHole.id,
                toHoleID:
                    secondHole.id
            )
        )
    }

    func testSecondConsecutiveObservationConfirmsTransition() {
        let firstHole =
            makeHole(number: 1)

        let secondHole =
            makeHole(number: 2)

        var detector =
            HoleTransitionDetector()

        let firstContext =
            makeContext(
                hole: firstHole,
                confidence: .high
            )

        let secondContext =
            makeContext(
                hole: secondHole,
                confidence: .high
            )

        _ = detector.evaluate(
            previous: firstContext,
            current: secondContext
        )

        let result =
            detector.evaluate(
                previous: firstContext,
                current: secondContext
            )

        XCTAssertEqual(
            result,
            .confirmed(
                fromHoleID:
                    firstHole.id,
                toHoleID:
                    secondHole.id
            )
        )
    }

    func testLowConfidenceDoesNotConfirmTransition() {
        let firstHole =
            makeHole(number: 1)

        let secondHole =
            makeHole(number: 2)

        var detector =
            HoleTransitionDetector()

        let previous =
            makeContext(
                hole: firstHole,
                confidence: .high
            )

        let current =
            makeContext(
                hole: secondHole,
                confidence: .likely
            )

        let firstResult =
            detector.evaluate(
                previous: previous,
                current: current
            )

        let secondResult =
            detector.evaluate(
                previous: previous,
                current: current
            )

        XCTAssertEqual(
            firstResult,
            .possible(
                fromHoleID:
                    firstHole.id,
                toHoleID:
                    secondHole.id
            )
        )

        XCTAssertEqual(
            secondResult,
            .possible(
                fromHoleID:
                    firstHole.id,
                toHoleID:
                    secondHole.id
            )
        )
    }

    func testMissingCurrentHoleReturnsLocationLost() {
        let firstHole =
            makeHole(number: 1)

        var detector =
            HoleTransitionDetector()

        let result =
            detector.evaluate(
                previous:
                    makeContext(
                        hole: firstHole,
                        confidence: .high
                    ),
                current:
                    makeContext(
                        hole: nil,
                        confidence: .none
                    )
            )

        XCTAssertEqual(
            result,
            .locationLost(
                previousHoleID:
                    firstHole.id
            )
        )
    }

    func testReturningToOriginalHoleResetsPendingTransition() {
        let firstHole =
            makeHole(number: 1)

        let secondHole =
            makeHole(number: 2)

        var detector =
            HoleTransitionDetector()

        let firstContext =
            makeContext(
                hole: firstHole,
                confidence: .high
            )

        let secondContext =
            makeContext(
                hole: secondHole,
                confidence: .high
            )

        _ = detector.evaluate(
            previous: firstContext,
            current: secondContext
        )

        let resetResult =
            detector.evaluate(
                previous: firstContext,
                current: firstContext
            )

        XCTAssertEqual(
            resetResult,
            .noChange
        )

        let nextResult =
            detector.evaluate(
                previous: firstContext,
                current: secondContext
            )

        XCTAssertEqual(
            nextResult,
            .possible(
                fromHoleID:
                    firstHole.id,
                toHoleID:
                    secondHole.id
            )
        )
    }

    private func makeHole(
        number: Int
    ) -> Hole {
        Hole(
            number: number,
            par: 4,
            lengthMeters: 350
        )
    }

    private func makeContext(
        hole: Hole?,
        confidence:
            HoleLocationConfidence
    ) -> RoundSpatialContext {
        RoundSpatialContext(
            observedAt:
                Date(
                    timeIntervalSince1970:
                        1_700_000_000
                ),
            golferPosition:
                GeoCoordinate(
                    latitude: -39.93,
                    longitude: 175.05
                ),
            hole: hole,
            holeLocationConfidence:
                confidence
        )
    }
}
