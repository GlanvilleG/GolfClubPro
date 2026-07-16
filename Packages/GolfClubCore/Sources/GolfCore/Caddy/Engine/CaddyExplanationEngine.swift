//
//  CaddyExplanationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct CaddyExplanationEngine:
    Sendable {


    public init() {}



    public func explain(
        recommendation:
            CaddyRecommendation
    ) -> CaddyExplanation {


        let items =
            recommendation.reasons.map {
                explanationItem(
                    for:
                        $0
                )
            }


        return CaddyExplanation(
            summary:
                createSummary(
                    reasons:
                        recommendation.reasons
                ),
            items:
                items,
            confidence:
                recommendation.confidence
        )
    }


    private func explanationItem(
        for reason:
            RecommendationReason
    ) -> ExplanationItem {


        switch reason {


        case .playerPattern:

            return ExplanationItem(
                title:
                    "Your normal shot pattern",
                detail:
                    "The target has been adjusted using your historical shot tendencies.",
                severity:
                    .information
            )


        case .hazardAvoidance:

            return ExplanationItem(
                title:
                    "Hazard avoidance",
                detail:
                    "The recommendation reduces exposure to course hazards.",
                severity:
                    .caution
            )


        case .routeSafety:

            return ExplanationItem(
                title:
                    "Safer strategy",
                detail:
                    "A lower-risk route was selected to improve expected outcome.",
                severity:
                    .advisory
            )


        case .distanceFit:

            return ExplanationItem(
                title:
                    "Distance fit",
                detail:
                    "The selected club matches the required distance.",
                severity:
                    .information
            )


        case .lieSuitability:

            return ExplanationItem(
                title:
                    "Lie suitability",
                detail:
                    "The selected club matches the current lie conditions.",
                severity:
                    .information
            )


        case .uncertainPosition:

            return ExplanationItem(
                title:
                    "Position uncertainty",
                detail:
                    "The current location or course position requires confirmation.",
                severity:
                    .advisory
            )


        case .lowConfidence:

            return ExplanationItem(
                title:
                    "Confidence check",
                detail:
                    "The recommendation has reduced confidence and may require confirmation.",
                severity:
                    .advisory
            )


        case .boundaryRisk:

            return ExplanationItem(
                title:
                    "Boundary risk",
                detail:
                    "The target area has increased out-of-play risk.",
                severity:
                    .caution
            )


        case .recovery:

            return ExplanationItem(
                title:
                    "Recovery strategy",
                detail:
                    "The recommendation prioritises returning the ball to a playable position.",
                severity:
                    .advisory
            )


        case .layup:

            return ExplanationItem(
                title:
                    "Lay-up strategy",
                detail:
                    "The recommendation prioritises position over maximum distance.",
                severity:
                    .advisory
            )


        case .aggressiveOption:

            return ExplanationItem(
                title:
                    "Aggressive option",
                detail:
                    "The recommendation accepts additional risk for potential advantage.",
                severity:
                    .advisory
            )


        case .conservativeOption:

            return ExplanationItem(
                title:
                    "Conservative option",
                detail:
                    "The recommendation prioritises control and reduced risk.",
                severity:
                    .information
            )
        }
    }



    private func createSummary(
        reasons:
            [RecommendationReason]
    ) -> String {


        if reasons.contains(
            .hazardAvoidance
        )
        &&
        reasons.contains(
            .playerPattern
        ) {

            return "Target adjusted based on your shot pattern and course risk."
        }


        if reasons.contains(
            .hazardAvoidance
        ) {

            return "Target adjusted to reduce course risk."
        }


        if reasons.contains(
            .playerPattern
        ) {

            return "Target adjusted using your historical shot pattern."
        }

        if reasons.contains(
            .routeSafety
        ) {

            return "A safer course-management option has been selected."
        }
        
        return "Standard recommendation."
    }
}
