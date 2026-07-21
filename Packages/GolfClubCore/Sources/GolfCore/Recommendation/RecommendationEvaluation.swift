//
//  RecommendationEvaluation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public struct RecommendationEvaluation:
    Sendable {

    public let context:
        RecommendationContext

    public let holeAssessment:
        HoleAssessment

    public let shotDispersion:
        ShotDispersionModel

    public let strategicOption:
        StrategicOption

    public let riskRewardAnalysis:
        RiskRewardAnalysis

    public let createdAt:
        Date

    public init(
        context:
            RecommendationContext,
        holeAssessment:
            HoleAssessment,
        shotDispersion:
            ShotDispersionModel,
        strategicOption:
            StrategicOption,
        riskRewardAnalysis:
            RiskRewardAnalysis,
        createdAt:
            Date = Date()
    ) {
        self.context =
            context

        self.holeAssessment =
            holeAssessment

        self.shotDispersion =
            shotDispersion

        self.strategicOption =
            strategicOption

        self.riskRewardAnalysis =
            riskRewardAnalysis

        self.createdAt =
            createdAt
    }
}
