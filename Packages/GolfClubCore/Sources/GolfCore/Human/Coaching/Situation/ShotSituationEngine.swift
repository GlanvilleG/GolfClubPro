//
//  ShotSituationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
public struct ShotSituationEngine:
    Sendable {

    public init() {}

    public func classify(
        recommendation:
            RecommendationDecision,
        context:
            ShotContext
    ) -> ShotSituationAssessment
}
