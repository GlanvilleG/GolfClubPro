//
//  RecommendationPipeline.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//


import Foundation

public struct RecommendationPipeline:
    Sendable {

    private let strategicOptionEngine:
        StrategicOptionEngine

    private let adaptiveCoachingEngine:
        AdaptiveCoachingEngine

    private let weatherAdjustmentEngine:
        WeatherAdjustmentEngine

    private let caddyRecommendationEngine:
        CaddyRecommendationEngine

    public init(
        strategicOptionEngine:
            StrategicOptionEngine =
                StrategicOptionEngine(),
        adaptiveCoachingEngine:
            AdaptiveCoachingEngine =
                AdaptiveCoachingEngine(),
        weatherAdjustmentEngine:
            WeatherAdjustmentEngine =
                WeatherAdjustmentEngine(),
        caddyRecommendationEngine:
            CaddyRecommendationEngine =
                CaddyRecommendationEngine()
    ) {

        self.strategicOptionEngine =
            strategicOptionEngine

        self.adaptiveCoachingEngine =
            adaptiveCoachingEngine

        self.weatherAdjustmentEngine =
            weatherAdjustmentEngine

        self.caddyRecommendationEngine =
            caddyRecommendationEngine
    }

    public func execute(
        context:
            RoundContext
    ) throws -> RecommendationPipelineResult {

        let shotContext =
            context.shot

        let inputs =
            context.recommendationInputs

        guard !inputs.candidateLandingZones.isEmpty else {

            throw RecommendationPipelineError
                .noCandidateLandingZones
        }

        let strategicOption =
            try strategicOptionEngine
                .determineBestOption(
                    from:
                        shotContext,
                    candidateLandingZones:
                        inputs.candidateLandingZones
                )

        let shotBearingDegrees =
            BearingCalculator
                .bearingDegrees(
                    from:
                        shotContext.currentPosition,
                    to:
                        strategicOption.target
                )

        let clubDistanceMeters =
            try selectedClubDistance(
                clubID:
                    strategicOption.clubID,
                target:
                    strategicOption.target,
                shotContext:
                    shotContext
            )

        let adaptiveAdjustment =
            adaptiveAdjustment(
                strategicOption:
                    strategicOption,
                bearingDegrees:
                    shotBearingDegrees,
                performance:
                    inputs.playerPerformance
            )

        let weatherAdjustment =
            weatherAdjustment(
                clubDistanceMeters:
                    clubDistanceMeters,
                shotBearingDegrees:
                    shotBearingDegrees,
                weather:
                    inputs.weatherCondition
            )

        let recommendation =
            caddyRecommendationEngine
                .create(
                    option:
                        strategicOption,
                    adaptiveAdjustment:
                        adaptiveAdjustment,
                    weatherAdjustment:
                        weatherAdjustment
                )

        return RecommendationPipelineResult(
            strategicOption:
                strategicOption,
            adaptiveAdjustment:
                adaptiveAdjustment,
            weatherAdjustment:
                weatherAdjustment,
            recommendation:
                recommendation
        )
    }

    private func selectedClubDistance(
        clubID: ClubID,
        target: GeoCoordinate,
        shotContext: ShotContext
    ) throws -> Double {

        guard let club =
            shotContext.availableClubs.first(
                where: { $0.id == clubID }
            )
        else {
            throw RecommendationPipelineError
                .selectedClubUnavailable
        }

        if let carryDistance =
            club.averageCarryMeters {

            return carryDistance
        }

        return DistanceCalculator.distanceMeters(
            from:
                shotContext.currentPosition,
            to:
                target
        )
    }

    private func adaptiveAdjustment(
        strategicOption:
            StrategicOption,
        bearingDegrees:
            Double,
        performance:
            PlayerPerformanceModel?
    ) -> AdaptiveTargetAdjustment {

        guard let performance else {

            return AdaptiveTargetAdjustment(
                originalTarget:
                    strategicOption.target,
                adjustedTarget:
                    strategicOption.target,
                adjustmentMeters:
                    0,
                reason:
                    "No player performance adjustment available.",
                confidence:
                    0
            )
        }

        return adaptiveCoachingEngine
            .adjustTarget(
                plannedTarget:
                    strategicOption.target,
                bearingDegrees:
                    bearingDegrees,
                clubID:
                    strategicOption.clubID,
                performance:
                    performance
            )
    }

    private func weatherAdjustment(
        clubDistanceMeters:
            Double,
        shotBearingDegrees:
            Double,
        weather:
            WeatherCondition?
    ) -> WeatherAdjustment? {

        guard let weather else {

            return nil
        }

        return weatherAdjustmentEngine
            .calculate(
                clubDistanceMeters:
                    clubDistanceMeters,
                shotBearingDegrees:
                    shotBearingDegrees,
                weather:
                    weather
            )
    }
}
