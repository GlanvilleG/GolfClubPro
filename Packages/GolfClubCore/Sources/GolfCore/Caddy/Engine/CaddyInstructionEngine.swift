//
//  CaddyInstructionEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct CaddyInstructionEngine:
    Sendable {


    public init() {}



    public func create(
        recommendation:
            CaddyRecommendation,
        explanation:
            CaddyExplanation
    ) -> CaddyInstruction {


        let adjustment =
            calculateAdjustment(
                recommendation:
                    recommendation
            )


        return CaddyInstruction(
            clubID:
                recommendation.clubID,

            displayText:
                displayText(
                    recommendation:
                        recommendation,
                    adjustment:
                        adjustment
                ),

            spokenText:
                spokenText(
                    recommendation:
                        recommendation,
                    explanation:
                        explanation
                ),

            targetAdjustmentMeters:
                adjustment,

            confidence:
                recommendation.confidence,

            priority:
                priority(
                    explanation:
                        explanation
                )
        )
    }



    private func calculateAdjustment(
        recommendation:
            CaddyRecommendation
    ) -> Double {


        DistanceCalculator.distanceMeters(
            from:
                recommendation.target,
            to:
                recommendation.adjustedTarget
        )
    }



    private func displayText(
        recommendation:
            CaddyRecommendation,
        adjustment:
            Double
    ) -> String {


        if adjustment > 1 {

            return
            "Adjust target \(Int(adjustment))m"
        }


        return
        "Play standard target"
    }



    private func spokenText(
        recommendation:
            CaddyRecommendation,
        explanation:
            CaddyExplanation
    ) -> String {


        return
        explanation.summary
    }



    private func priority(
        explanation:
            CaddyExplanation
    ) -> InstructionPriority {


        if explanation.items.contains(
            where:
            {
                $0.severity ==
                    .caution
            }
        ) {

            return .caution
        }


        if explanation.items.contains(
            where:
            {
                $0.severity ==
                    .advisory
            }
        ) {

            return .advisory
        }


        return .normal
    }
}
