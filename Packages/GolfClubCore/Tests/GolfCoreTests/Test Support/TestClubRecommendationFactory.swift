//
//  TestClubRecommendationFactory.swift
//  GolfCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation
@testable import GolfCore

enum TestClubRecommendationFactory {

    static func makeRecommendation(
        clubID: ClubID = ClubID(),
        score: Double = 0.85,
        adjustedCarryMeters: Double = 150,
        distanceDifferenceMeters: Double = 3,
        confidence: Double = 0.90,
        reasons: [String] = [
            "Test recommendation."
        ]
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
