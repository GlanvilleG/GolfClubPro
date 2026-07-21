//
//  RiskRewardAnalysisTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Testing
@testable import GolfCore

@Suite
struct RiskRewardAnalysisTests {

    @Test
    func valuesAreClampedToNormalizedRange() {

        let analysis =
            RiskRewardAnalysis(
                expectedReward: 1.5,
                expectedRisk: -0.5,
                balance: .aggressive,
                confidence:
                    DecisionConfidence(
                        value: 1.5
                    )
            )

        #expect(
            analysis.expectedReward ==
                1
        )

        #expect(
            analysis.expectedRisk ==
                0
        )

        #expect(
            analysis.confidence.value ==
                1
        )
    }

    @Test
    func netValueSubtractsRiskFromReward() {

        let analysis =
            RiskRewardAnalysis(
                expectedReward: 0.75,
                expectedRisk: 0.25,
                balance: .aggressive,
                confidence:
                    DecisionConfidence(
                        value: 0.8
                    )
            )

        #expect(
            abs(
                analysis.netValue -
                    0.50
            ) < 0.000_001
        )
    }

    @Test
    func decisionConfidenceIsClamped() {

        let low =
            DecisionConfidence(
                value: -1
            )

        let high =
            DecisionConfidence(
                value: 2
            )

        #expect(
            low ==
                .none
        )

        #expect(
            high ==
                .full
        )
    }

    @Test
    func decisionConfidenceIsComparable() {

        let lower =
            DecisionConfidence(
                value: 0.4
            )

        let higher =
            DecisionConfidence(
                value: 0.8
            )

        #expect(
            lower <
                higher
        )
    }
}
