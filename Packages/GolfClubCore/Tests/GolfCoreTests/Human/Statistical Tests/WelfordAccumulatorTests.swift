//
//  WelfordAccumulatorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import XCTest
@testable import GolfCore

final class WelfordAccumulatorTests: XCTestCase {

    // MARK: - Construction

    func testNewAccumulatorHasZeroSamples() {

        let accumulator =
            WelfordAccumulator()

        XCTAssertEqual(
            accumulator.sampleCount,
            0
        )
    }

    func testNewAccumulatorHasZeroMean() {

        let accumulator =
            WelfordAccumulator()

        XCTAssertEqual(
            accumulator.mean,
            0,
            accuracy: 0.000001
        )
    }

    func testNewAccumulatorHasZeroVariance() {

        let accumulator =
            WelfordAccumulator()

        XCTAssertEqual(
            accumulator.variance,
            0,
            accuracy: 0.000001
        )
    }

    func testNewAccumulatorHasZeroStandardDeviation() {

        let accumulator =
            WelfordAccumulator()

        XCTAssertEqual(
            accumulator.standardDeviation,
            0,
            accuracy: 0.000001
        )
    }

    func testNewAccumulatorHasNoSamples() {

        let accumulator =
            WelfordAccumulator()

        XCTAssertFalse(
            accumulator.hasSamples
        )
    }

    // MARK: - Learning

    func testSingleSampleUpdatesMean() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(
            150
        )

        XCTAssertEqual(
            accumulator.sampleCount,
            1
        )

        XCTAssertEqual(
            accumulator.mean,
            150,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.variance,
            0,
            accuracy: 0.000001
        )
    }

    func testTwoSamplesUpdatesMean() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(150)
        accumulator.addSample(160)

        XCTAssertEqual(
            accumulator.sampleCount,
            2
        )

        XCTAssertEqual(
            accumulator.mean,
            155,
            accuracy: 0.000001
        )
    }

    func testThreeSamplesUpdatesMean() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(150)
        accumulator.addSample(160)
        accumulator.addSample(170)

        XCTAssertEqual(
            accumulator.mean,
            160,
            accuracy: 0.000001
        )
    }

    func testIncreasingSequence() {

        var accumulator =
            WelfordAccumulator()

        for value in 1...100 {

            accumulator.addSample(
                Double(value)
            )
        }

        XCTAssertEqual(
            accumulator.sampleCount,
            100
        )

        XCTAssertEqual(
            accumulator.mean,
            50.5,
            accuracy: 0.000001
        )
    }

    func testDecreasingSequence() {

        var accumulator =
            WelfordAccumulator()

        for value in stride(
            from: 100,
            through: 1,
            by: -1
        ) {

            accumulator.addSample(
                Double(value)
            )
        }

        XCTAssertEqual(
            accumulator.sampleCount,
            100
        )

        XCTAssertEqual(
            accumulator.mean,
            50.5,
            accuracy: 0.000001
        )
    }

    func testIdenticalSamples() {

        var accumulator =
            WelfordAccumulator()

        for _ in 0..<25 {

            accumulator.addSample(
                145
            )
        }

        XCTAssertEqual(
            accumulator.sampleCount,
            25
        )

        XCTAssertEqual(
            accumulator.mean,
            145,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.variance,
            0,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.standardDeviation,
            0,
            accuracy: 0.000001
        )
    }

    func testNegativeSamples() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(-10)
        accumulator.addSample(-20)

        XCTAssertEqual(
            accumulator.mean,
            -15,
            accuracy: 0.000001
        )
    }

    func testZeroSamples() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(0)
        accumulator.addSample(0)
        accumulator.addSample(0)

        XCTAssertEqual(
            accumulator.mean,
            0,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.variance,
            0,
            accuracy: 0.000001
        )
    }

    // MARK: - Value Semantics

    func testCopyDoesNotMutateOriginal() {

        var original =
            WelfordAccumulator()

        original.addSample(150)

        var copy =
            original

        copy.addSample(160)

        XCTAssertEqual(
            original.sampleCount,
            1
        )

        XCTAssertEqual(
            original.mean,
            150,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            copy.sampleCount,
            2
        )

        XCTAssertEqual(
            copy.mean,
            155,
            accuracy: 0.000001
        )
    }

    func testValueAfterAddingSampleReturnsUpdatedCopy() {

        let original =
            WelfordAccumulator()

        let updated =
            original.valueAfterAddingSample(
                150
            )

        XCTAssertEqual(
            original.sampleCount,
            0
        )

        XCTAssertEqual(
            updated.sampleCount,
            1
        )

        XCTAssertEqual(
            updated.mean,
            150,
            accuracy: 0.000001
        )
    }

    // MARK: - Reset

    func testResetReturnsAccumulatorToInitialState() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(150)
        accumulator.addSample(160)

        accumulator.reset()

        XCTAssertEqual(
            accumulator.sampleCount,
            0
        )

        XCTAssertEqual(
            accumulator.mean,
            0,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.variance,
            0,
            accuracy: 0.000001
        )

        XCTAssertFalse(
            accumulator.hasSamples
        )
    }
    // MARK: - Mathematical Verification section
    func testKnownDatasetMatchesExpectedStatistics() {

        var accumulator =
            WelfordAccumulator()

        let samples = [
            2.0, 4.0, 4.0, 4.0,
            5.0, 5.0, 7.0, 9.0
        ]

        for sample in samples {
            accumulator.addSample(sample)
        }

        XCTAssertEqual(
            accumulator.mean,
            5.0,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.variance,
            4.571428571428571,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.standardDeviation,
            2.138089935,
            accuracy: 0.000001
        )
    }
    func testPopulationVarianceMatchesExpectedValue() {

        var accumulator =
            WelfordAccumulator()

        let samples = [
            2.0,4.0,4.0,4.0,
            5.0,5.0,7.0,9.0
        ]

        samples.forEach {
            accumulator.addSample($0)
        }

        XCTAssertEqual(
            accumulator.populationVariance,
            4.0,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            accumulator.populationStandardDeviation,
            2.0,
            accuracy: 0.000001
        )
    }
    func testIncrementalMeanMatchesBatchMean() {

        let samples = [
            141.2,
            152.4,
            163.1,
            157.8,
            149.6,
            155.3,
            161.9
        ]

        var accumulator =
            WelfordAccumulator()

        samples.forEach {
            accumulator.addSample($0)
        }

        let batchMean =
            samples.reduce(0,+) /
            Double(samples.count)

        XCTAssertEqual(
            accumulator.mean,
            batchMean,
            accuracy: 0.0000001
        )
    }
    func testSampleOrderDoesNotChangeStatistics() {

        let samples = [
            150.0,
            155.0,
            160.0,
            165.0,
            170.0
        ]

        var first =
            WelfordAccumulator()

        samples.forEach {
            first.addSample($0)
        }

        var second =
            WelfordAccumulator()

        samples.reversed().forEach {
            second.addSample($0)
        }

        XCTAssertEqual(
            first.mean,
            second.mean,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            first.variance,
            second.variance,
            accuracy: 0.000001
        )
    }
    func testLargeDatasetProducesStableStatistics() {

        var accumulator =
            WelfordAccumulator()

        for value in 1...10000 {

            accumulator.addSample(
                Double(value)
            )
        }

        XCTAssertEqual(
            accumulator.sampleCount,
            10000
        )

        XCTAssertEqual(
            accumulator.mean,
            5000.5,
            accuracy: 0.000001
        )

        XCTAssertGreaterThan(
            accumulator.variance,
            0
        )

        XCTAssertFalse(
            accumulator.variance.isNaN
        )

        XCTAssertFalse(
            accumulator.standardDeviation.isNaN
        )
    }
    func testVerySmallDifferencesRemainStable() {

        var accumulator =
            WelfordAccumulator()

        accumulator.addSample(150.000001)
        accumulator.addSample(150.000002)
        accumulator.addSample(150.000003)

        XCTAssertFalse(
            accumulator.mean.isNaN
        )

        XCTAssertFalse(
            accumulator.variance.isNaN
        )

        XCTAssertGreaterThanOrEqual(
            accumulator.variance,
            0
        )
    }
}
