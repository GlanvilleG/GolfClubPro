//
//  RiskRewardAnalysis.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public struct RiskRewardAnalysis:
    Codable,
    Equatable,
    Sendable {

    /// Normalized expected benefit of the strategic option.
    ///
    /// The value is constrained to `0...1`.
    public let expectedReward:
        Double

    /// Normalized probability-weighted risk associated with
    /// the strategic option.
    ///
    /// The value is constrained to `0...1`.
    public let expectedRisk:
        Double

    /// Classification of the relationship between reward
    /// and risk.
    public let balance:
        RiskRewardBalance

    /// Confidence in the underlying decision inputs and
    /// resulting analysis.
    public let confidence:
        DecisionConfidence

    public init(
        expectedReward:
            Double,
        expectedRisk:
            Double,
        balance:
            RiskRewardBalance,
        confidence:
            DecisionConfidence
    ) {
        self.expectedReward =
            Self.clamp(
                expectedReward
            )

        self.expectedRisk =
            Self.clamp(
                expectedRisk
            )

        self.balance =
            balance

        self.confidence =
            confidence
    }

    /// Positive values favour reward.
    ///
    /// Negative values indicate that expected risk exceeds
    /// expected reward.
    public var netValue:
        Double {

        expectedReward -
            expectedRisk
    }

    private static func clamp(
        _ value:
            Double
    ) -> Double {

        min(
            max(value, 0),
            1
        )
    }
}
