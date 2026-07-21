//
//  TestRecommendationDecisionFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//

import Foundation
@testable import GolfCore

enum TestRecommendationDecisionFactory {

    static func decision(
        shotPlan: ShotPlan = TestShotPlanFactory.makeShotPlan(),
        preferredClub: ClubRecommendation? = nil,
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

    static func clubRecommendation(
        clubID: ClubID = ClubID(),
        score: Double = 0.90,
        adjustedCarryMeters: Double = 150,
        distanceDifferenceMeters: Double = 0,
        confidence: Double = 0.85,
        reasons: [String] = ["Distance fit"]
    ) -> ClubRecommendation {
        ClubRecommendation(
            clubID: clubID,
            score: score,
            adjustedCarryMeters: adjustedCarryMeters,
            distanceDifferenceMeters: distanceDifferenceMeters,
            confidence: confidence,
            reasons: reasons
        )
    }
}
