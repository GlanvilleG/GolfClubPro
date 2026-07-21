//  RecommendationEvaluationTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation
import Testing
@testable import GolfCore

@Suite
struct RecommendationEvaluationTests {

    @Test
    func storesExplicitCreationDate() {

        let createdAt =
            Date(
                timeIntervalSince1970:
                    1_700_000_000
            )

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: makeHoleAssessment(),
                shotDispersion: makeShotDispersion(),
                strategicOption: makeStrategicOption(),
                riskRewardAnalysis: makeRiskRewardAnalysis(),
                createdAt: createdAt
            )

        #expect(
            evaluation.createdAt ==
                createdAt
        )
    }

    @Test
    func preservesStrategicOption() {

        let option =
            makeStrategicOption()

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: makeHoleAssessment(),
                shotDispersion: makeShotDispersion(),
                strategicOption: option,
                riskRewardAnalysis: makeRiskRewardAnalysis()
            )

        #expect(
            evaluation.strategicOption ==
                option
        )
    }

    @Test
    func preservesRiskRewardAnalysis() {

        let analysis =
            makeRiskRewardAnalysis()

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: makeHoleAssessment(),
                shotDispersion: makeShotDispersion(),
                strategicOption: makeStrategicOption(),
                riskRewardAnalysis: analysis
            )

        #expect(
            evaluation.riskRewardAnalysis ==
                analysis
        )
    }

    @Test
    func preservesHoleAssessment() {

        let assessment =
            makeHoleAssessment()

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: assessment,
                shotDispersion: makeShotDispersion(),
                strategicOption: makeStrategicOption(),
                riskRewardAnalysis: makeRiskRewardAnalysis()
            )

        #expect(
            evaluation.holeAssessment ==
                assessment
        )
    }

    @Test
    func preservesShotDispersion() {

        let dispersion =
            makeShotDispersion()

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: makeHoleAssessment(),
                shotDispersion: dispersion,
                strategicOption: makeStrategicOption(),
                riskRewardAnalysis: makeRiskRewardAnalysis()
            )

        #expect(
            evaluation.shotDispersion ==
                dispersion
        )
    }
    
    @Test
    func defaultCreationDateUsesCurrentTime() {

        let before =
            Date()

        let evaluation =
            TestRecommendationEvaluationFactory.decision(
                context: makeContext(),
                holeAssessment: makeHoleAssessment(),
                shotDispersion: makeShotDispersion(),
                strategicOption: makeStrategicOption(),
                riskRewardAnalysis: makeRiskRewardAnalysis()
            )

        let after =
            Date()

        #expect(
            evaluation.createdAt >= before
        )

        #expect(
            evaluation.createdAt <= after
        )
    }
}

// MARK: - Local helpers building inputs via other factories

private func makeContext() -> RecommendationContext {
    // Minimal placeholder; adjust if your RecommendationContext requires more fields
    RecommendationContext()
}

private func makeHoleAssessment() -> HoleAssessment {
    // Use existing TestHoleFactory or a future TestHoleAssessmentFactory
    HoleAssessment(
        areaAssessments: [],
        overallRisk: .negligible
    )
}

private func makeShotDispersion() -> ShotDispersionModel {
    // Minimal placeholder model; adjust to match your real initializer
    ShotDispersionModel(
        lateralStdDevMeters: 5,
        longitudinalStdDevMeters: 10,
        lateralBiasMeters: 0,
        distanceBiasMeters: 0,
        confidence: .medium
    )
}

private func makeStrategicOption() -> StrategicOption {
    // Minimal placeholder; align with your actual StrategicOption initializer
    StrategicOption(
        clubID: ClubID(),
        target: GeoCoordinate(latitude: 0, longitude: 0),
        rationale: "Test option"
    )
}

private func makeRiskRewardAnalysis() -> RiskRewardAnalysis {
    // Minimal placeholder; align with your actual RiskRewardAnalysis initializer
    RiskRewardAnalysis(
        expectedRisk: 0.5,
        expectedReward: 0.5,
        balance: .neutral,
        confidence: .full
    )
}
