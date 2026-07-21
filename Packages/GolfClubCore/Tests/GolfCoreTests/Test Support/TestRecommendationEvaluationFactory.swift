//
//  TestRecommendationEvaluationFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation
@testable import GolfCore

enum TestRecommendationEvaluationFactory {
    
    static func decision(
        context: RecommendationContext,
        holeAssessment: HoleAssessment,
        shotDispersion: ShotDispersionModel,
        strategicOption: StrategicOption,
        riskRewardAnalysis: RiskRewardAnalysis,
        createdAt: Date = Date()
        //Date(timeIntervalSince1970: 1_700_000_000)
        
    ) -> RecommendationEvaluation {
        
        RecommendationEvaluation(
            context: context,
            holeAssessment: holeAssessment,
            shotDispersion: shotDispersion,
            strategicOption: strategicOption,
            riskRewardAnalysis: riskRewardAnalysis,
            createdAt: createdAt
        )
    }
    static func makeDecision(
        shotPlan: ShotPlan = TestShotPlanFactory.makeShotPlan(),
        preferredClub: ClubRecommendation? = TestClubRecommendationFactory.makeRecommendation(),
        alternatives: [ClubRecommendation] = [],
        aimOffsetDegrees: Double = 0
    ) -> RecommendationDecision {
        RecommendationDecision(
            shotPlan: shotPlan,
            preferredClub: preferredClub,
            alternatives: alternatives,
            aimOffsetDegrees: aimOffsetDegrees
        )
    }
}
