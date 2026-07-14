//
//  WelfordAccumulator.swift
//  GolfClubCore
//
import Foundation

/// A numerically stable online accumulator for calculating running
/// mean and variance using Welford's algorithm.
///
/// This type is domain independent and may be reused wherever
/// continuous statistical learning is required.
///
/// References:
/// - B. P. Welford (1962)
/// - Knuth, The Art of Computer Programming, Vol. 2
///
///Constraints - Welford’s algorithm doesn’t support arbitrary removal efficiently. Supporting that would require retaining historical observations or adopting a different statistical model. That aligns perfectly with EP-004 – Facts Are Immutable. In GolfClubPro, if a recorded shot is incorrect, the preferred approach is to correct the underlying fact and rebuild the derived model rather than trying to “undo” incremental statistics.
    
// MARK: - API Stability
//
// The public API of this type is considered stable.
// Future changes should preserve source compatibility.
// Internal implementation may evolve provided the public
// behaviour remains unchanged.
                                                                                
                                                                                
public struct WelfordAccumulator:
    Codable,
    Equatable,
    Sendable {

    // MARK: - Internal State

    private(set) var count: Int

    private(set) var runningMean: Double

    private(set) var runningM2: Double

    // MARK: - Initialisation

    public init(
        count: Int = 0,
        runningMean: Double = 0,
        runningM2: Double = 0
    ) {
        self.count = count
        self.runningMean = runningMean
        self.runningM2 = runningM2
    }

    // MARK: - Domain Properties

    public var sampleCount: Int {
        count
    }

    public var mean: Double {
        runningMean
    }

    public var variance: Double {

        guard count > 1 else {
            return 0
        }

        return runningM2 /
            Double(count - 1)
    }

    public var populationVariance: Double {

        guard count > 0 else {
            return 0
        }

        return runningM2 /
            Double(count)
    }

    public var standardDeviation: Double {
        sqrt(variance)
    }

    public var populationStandardDeviation: Double {
        sqrt(populationVariance)
    }

    public var hasSamples: Bool {
        count > 0
    }

    // MARK: - Learning

    public mutating func addSample(
        _ value: Double
    ) {

        count += 1

        let delta =
            value - runningMean

        runningMean +=
            delta / Double(count)

        let delta2 =
            value - runningMean

        runningM2 +=
            delta * delta2
    }

    // MARK: - Utilities

    public func valueAfterAddingSample(
        _ value: Double
    ) -> WelfordAccumulator {

        var copy = self

        copy.addSample(value)

        return copy
    }

    public mutating func reset() {

        count = 0
        runningMean = 0
        runningM2 = 0
    }
}
