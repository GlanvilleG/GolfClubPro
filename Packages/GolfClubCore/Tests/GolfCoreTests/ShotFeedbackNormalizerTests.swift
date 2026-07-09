//
//  ShotFeedbackNormalizerTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class ShotFeedbackNormalizerTests: XCTestCase {

    private let normalizer = ShotFeedbackNormalizer()

    func testPushAndBunkerAreClassified() {
        let feedback = normalizer.normalize("I pushed it right into the bunker")

        XCTAssertEqual(feedback.rawTranscript, "I pushed it right into the bunker")
        XCTAssertTrue(feedback.classifiedErrors.contains(.push))
        XCTAssertTrue(feedback.classifiedErrors.contains(.bunker))
        XCTAssertEqual(feedback.sentiment, .negative)
    }

    func testChunkedShotIsClassified() {
        let feedback = normalizer.normalize("I chunked that")

        XCTAssertTrue(feedback.classifiedErrors.contains(.chunk))
        XCTAssertEqual(feedback.sentiment, .negative)
    }

    func testWetShotIsClassifiedAsWater() {
        let feedback = normalizer.normalize("That’s wet")

        XCTAssertTrue(feedback.classifiedErrors.contains(.water))
        XCTAssertEqual(feedback.sentiment, .negative)
    }

    func testLuckyOutcomeIsPositive() {
        let feedback = normalizer.normalize("I got away with that")

        XCTAssertTrue(feedback.classifiedErrors.contains(.luckyOutcome))
        XCTAssertEqual(feedback.sentiment, .positive)
    }

    func testForeIsWarning() {
        let feedback = normalizer.normalize("Fore!")

        XCTAssertEqual(feedback.sentiment, .warning)
    }

    func testNeutralTranscript() {
        let feedback = normalizer.normalize("Middle of the fairway")

        XCTAssertTrue(feedback.classifiedErrors.isEmpty)
        XCTAssertEqual(feedback.sentiment, .neutral)
    }
}
