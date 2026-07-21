//
//  RecommendationEvaluationTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
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
    let shotContext =
        makeShotContext()

    let spatialContext =
        makeSpatialContext()

    let spatialAnalysis =
        SpatialAnalysis(
            insideMappedArea: true
        )

    let context =
        RecommendationContext(
            shotContext: shotContext,
            spatialContext: spatialContext,
            spatialAnalysis: spatialAnalysis
        )

    return context
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
    let target =
    GeoCoordinate(
        latitude: -39.9300,
        longitude: 175.0500
    )
    let dispersion = ShotDispersionModel(
        target: target,
        lateralSigmaMeters: 8,
        longitudinalSigmaMeters: 10,
        lateralBiasMeters: 0,
        longitudinalBiasMeters: 0,
        confidence: 0.8
        
    )
    return dispersion
}

private func makeStrategicOption() -> StrategicOption {
    // Minimal placeholder; align with your actual StrategicOption initializer
    StrategicOption(
        target: GeoCoordinate(latitude: 0, longitude: 0),
        clubID: ClubID(),
        landingZone: LandingZoneEvaluation(
            location: GeoCoordinate(latitude: 0, longitude: 0),
            lieQuality: .fairway,
            hazardExposure: 0.1,
            nextShotDistance: 120,
            scoreExpectation: 2.0
        ),
        risk: RiskAssessment(riskLevel:
                .low,
            hazardExposure:
                0,
            penaltyProbability:
                0,
            recommendation:
                "Low-risk option.",
            confidence:
                0.8)
    )
}

private func makeRiskRewardAnalysis() -> RiskRewardAnalysis {
    // Minimal placeholder; align with your actual RiskRewardAnalysis initializer
    RiskRewardAnalysis(
        expectedReward: 0.5,
        expectedRisk: 0.5,
        balance: .neutral,
        confidence: .full
    )
}
private func makeShotContext()
    -> ShotContext {

    GolfCoreTestFactory
        .makeShotContext()
}
private func makeSpatialContext()
    -> RoundSpatialContext {

    RoundSpatialContext(
        observedAt:
            Date(
                timeIntervalSince1970:
                    1_700_000_000
            ),
        golferPosition:
            GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
        hole: nil,
        holeLocationConfidence:
            .none,
        requiresConfirmation:
            true
    )
}

