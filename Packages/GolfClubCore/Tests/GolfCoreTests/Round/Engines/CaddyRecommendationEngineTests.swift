//
//  CaddyRecommendationEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//

import Testing
@testable import GolfCore

@Test("Includes weather in recommendation explanation")
func includesWeatherInExplanation() {

    let weatherAdjustment =
        WeatherAdjustment(
            distanceAdjustmentMeters:
                -6,
            lateralAdjustmentMeters:
                0,
            explanation:
                "Headwind reducing expected carry.",
            confidence:
                0.7
        )
    let option =
        StrategicOption(
            target:
                GeoCoordinate(
                    latitude: -39.9300,
                    longitude: 175.0500
                ),
            clubID:
                ClubID(),
            landingZone:
                LandingZoneEvaluation(
                    location:
                        GeoCoordinate(
                            latitude: -39.9300,
                            longitude: 175.0500
                        ),
                    lieQuality:
                        .fairway,
                    hazardExposure:
                        0,
                    nextShotDistance:
                        120,
                    scoreExpectation:
                        4
                ),
            risk:
                RiskAssessment(
                    riskLevel:
                        .low,
                    hazardExposure:
                        0,
                    penaltyProbability:
                        0,
                    recommendation:
                        "Low-risk option.",
                    confidence:
                        0.8
                )
        )
    let adaptiveAdjustment =
        AdaptiveTargetAdjustment(
            originalTarget:
                option.target,
            adjustedTarget:
                option.target,
            adjustmentMeters:
                0,
            reason:
                "No adjustment required.",
            confidence:
                0
        )
    let recommendation =
        CaddyRecommendationEngine()
            .create(
                option:option,
                adaptiveAdjustment:
                    adaptiveAdjustment,
                weatherAdjustment:
                    weatherAdjustment
            )

    #expect(
        recommendation.reasons.contains(
            .weatherInfluence
        )
    )

    #expect(
        recommendation.explanation.contains(
            "Headwind reducing expected carry."
        )
    )
}

