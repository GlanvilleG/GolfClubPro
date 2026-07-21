//
//  RiskRewardAnalysisEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public struct RiskRewardAnalysisEngine:
    Sendable {

    public init() {}

    public func analyse(
        option: StrategicOption
    ) -> RiskRewardAnalysis {

        let expectedReward =
            calculateExpectedReward(
                from: option
            )

        let expectedRisk =
            calculateExpectedRisk(
                from: option
            )

        let balance =
            classifyBalance(
                expectedReward: expectedReward,
                expectedRisk: expectedRisk
            )

        return RiskRewardAnalysis(
            expectedReward: expectedReward,
            expectedRisk: expectedRisk,
            balance: balance,
            confidence:
                option.metrics.decisionConfidence
        )
    }
}

private extension RiskRewardAnalysisEngine {

    func calculateExpectedReward(
        from option: StrategicOption
    ) -> Double {

        let expectedStrokes =
            max(
                option.landingZone.scoreExpectation,
                1
            )

        return min(
            1,
            1 / expectedStrokes
        )
    }

    func calculateExpectedRisk(
        from option: StrategicOption
    ) -> Double {

        let combinedRisk =
            (
                option.risk.hazardExposure +
                option.risk.penaltyProbability
            ) / 2

        return min(
            max(combinedRisk, 0),
            1
        )
    }

    func classifyBalance(
        expectedReward: Double,
        expectedRisk: Double
    ) -> RiskRewardBalance {

        let netValue =
            expectedReward -
                expectedRisk

        switch netValue {

        case ..<(-0.40):
            return .veryConservative

        case ..<(-0.15):
            return .conservative

        case ...0.15:
            return .neutral

        case ...0.40:
            return .aggressive

        default:
            return .veryAggressive
        }
    }
}
