//
//  RiskRewardAnalysisEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Testing
@testable import GolfCore

@Suite
struct RiskRewardAnalysisEngineTests {

    private let engine =
        RiskRewardAnalysisEngine()

    @Test
    func highRiskLowRewardIsVeryConservative() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 5,
                hazardExposure: 0.9,
                penaltyProbability: 0.9,
                decisionConfidence: .full
            )

        let analysis =
            engine.analyse(
                option: option
            )

        #expect(
            abs(
                analysis.expectedReward -
                    0.2
            ) < 0.000_001
        )

        #expect(
            analysis.expectedRisk ==
                0.9
        )

        #expect(
            analysis.balance ==
                .veryConservative
        )
    }

    @Test
    func similarRiskAndRewardAreNeutral() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 2,
                hazardExposure: 0.5,
                penaltyProbability: 0.5,
                decisionConfidence: .full
            )

        let analysis =
            engine.analyse(
                option: option
            )

        #expect(
            analysis.expectedReward ==
                0.5
        )

        #expect(
            analysis.expectedRisk ==
                0.5
        )

        #expect(
            analysis.balance ==
                .neutral
        )
    }

    @Test
    func highRewardLowRiskIsVeryAggressive() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 1,
                hazardExposure: 0.05,
                penaltyProbability: 0.05,
                decisionConfidence: .full
            )

        let analysis =
            engine.analyse(
                option: option
            )

        #expect(
            analysis.expectedReward ==
                1
        )

        #expect(
            analysis.expectedRisk ==
                0.05
        )

        #expect(
            analysis.balance ==
                .veryAggressive
        )
    }

    @Test
    func confidencePropagatesFromStrategicMetrics() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 2,
                hazardExposure: 0.3,
                penaltyProbability: 0.3,
                decisionConfidence: .none
            )

        let analysis =
            engine.analyse(
                option: option
            )

        #expect(
            analysis.confidence ==
                .none
        )
    }

    @Test
    func netValueIsRewardMinusRisk() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 2,
                hazardExposure: 0.2,
                penaltyProbability: 0.2,
                decisionConfidence: .full
            )

        let analysis =
            engine.analyse(
                option: option
            )

        #expect(
            analysis.netValue ==
                0.3
        )
    }

    @Test
    func repeatedAnalysisIsDeterministic() {

        let option =
            TestStrategicOptionFactory.option(
                scoreExpectation: 2.5,
                hazardExposure: 0.25,
                penaltyProbability: 0.35,
                decisionConfidence: .full
            )

        let first =
            engine.analyse(
                option: option
            )

        let second =
            engine.analyse(
                option: option
            )

        #expect(
            first ==
                second
        )
    }
}
