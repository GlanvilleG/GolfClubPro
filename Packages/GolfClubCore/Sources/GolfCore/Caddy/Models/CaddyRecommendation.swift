//
//  CaddyRecommendation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct CaddyRecommendation:
    Codable,
    Equatable,
    Sendable {


    public let clubID:
        ClubID


    public let target:
        GeoCoordinate


    public let adjustedTarget:
        GeoCoordinate


    public let reasons:
        [RecommendationReason]


    public let explanation:
        String


    public let confidence:
        Double


    public init(
        clubID:
            ClubID,
        target:
            GeoCoordinate,
        adjustedTarget:
            GeoCoordinate,
        reasons:
            [RecommendationReason],
        explanation:
            String,
        confidence:
            Double
    ) {

        self.clubID =
            clubID

        self.target =
            target

        self.adjustedTarget =
            adjustedTarget

        self.reasons =
            reasons

        self.explanation =
            explanation

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )
    }
}
