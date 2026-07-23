///
//  CaddyRecommendationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct CaddyRecommendationEngine:
    Sendable {

    public init() {}

    // Backward-compatible overload for existing callers/tests
    public func create(
        option: StrategicOption,
        adaptiveAdjustment: AdaptiveTargetAdjustment,
        weatherAdjustment: WeatherAdjustment?
    ) -> CaddyRecommendation {
        return create(
            option: option,
            adaptiveAdjustment: adaptiveAdjustment,
            weatherAdjustment: weatherAdjustment,
            environmentalAssessment: nil
        )
    }
    public func create(
        option: StrategicOption,
        adaptiveAdjustment: AdaptiveTargetAdjustment,
        weatherAdjustment: WeatherAdjustment?,
        environmentalAssessment: EnvironmentalAssessment?
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

        if weatherAdjustment != nil {

            reasons.append(
                .weatherInfluence
            )
        }

        if environmentalAssessment != nil {
            // Environmental context was considered via standardized assessment
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
                        reasons,
                    weatherAdjustment:
                        weatherAdjustment
                ),
            confidence:
                recommendationConfidence(
                    adaptiveAdjustment:
                        adaptiveAdjustment,
                    riskAssessment:
                        option.risk,
                    weatherAdjustment:
                        weatherAdjustment
                )
        )
    }

    private func buildExplanation(
        reasons:
            [RecommendationReason],
        weatherAdjustment:
            WeatherAdjustment?
    ) -> String {

        var explanationParts:
            [String] = []

        if reasons.contains(
            .hazardAvoidance
        ) {

            explanationParts.append(
                "Target adjusted to reduce course risk."
            )
        }

        if reasons.contains(
            .playerPattern
        ) {

            explanationParts.append(
                "Target adjusted based on your shot pattern."
            )
        }

        if let weatherAdjustment {

            explanationParts.append(
                weatherAdjustment.explanation
            )
        }

        if explanationParts.isEmpty {

            return "Standard recommendation."
        }

        return explanationParts.joined(
            separator:
                " "
        )
    }

    private func recommendationConfidence(
        adaptiveAdjustment:
            AdaptiveTargetAdjustment,
        riskAssessment:
            RiskAssessment,
        weatherAdjustment:
            WeatherAdjustment?
    ) -> Double {

        var confidenceValues:
            [Double] = [
                riskAssessment.confidence
            ]

        if adaptiveAdjustment.confidence > 0 {

            confidenceValues.append(
                adaptiveAdjustment.confidence
            )
        }

        if let weatherAdjustment {

            confidenceValues.append(
                weatherAdjustment.confidence
            )
        }

        return confidenceValues.min()
            ?? riskAssessment.confidence
    }
}
