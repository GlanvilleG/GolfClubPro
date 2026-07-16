//
//  CaddyRecommendationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

//
//  CaddyRecommendationEngine.swift
//

import Foundation


public struct CaddyRecommendationEngine:
    Sendable {


    public init() {}



    public func create(
        option:
            StrategicOption,
        adaptiveAdjustment:
            AdaptiveTargetAdjustment
    ) -> CaddyRecommendation {


        var reasons:
            [RecommendationReason] = []


        if adaptiveAdjustment.adjustmentMeters != 0 {

            reasons.append(
                .playerPattern
            )
                        
            
        }

        if option.risk.hazardExposure > 0 {

            reasons.append(
                .hazardAvoidance
            )
        }


        return CaddyRecommendation(
            clubID:
                option.clubID,
            target:
                option.target,
            adjustedTarget:
                adaptiveAdjustment.adjustedTarget,
            reasons:
                reasons,
            explanation:
                buildExplanation(
                    reasons:
                        reasons
                ),
            confidence:
                min(
                    adaptiveAdjustment.confidence,
                    option.risk.confidence
                )
        )
    }



    private func buildExplanation(
        reasons:
            [RecommendationReason]
    ) -> String {


        if reasons.contains(
            .hazardAvoidance
        ) {

            return "Target adjusted to reduce course risk."
        }


        if reasons.contains(
            .playerPattern
        ) {

            return "Target adjusted based on your shot pattern."
        }

        return "Standard recommendation."
    }
}
