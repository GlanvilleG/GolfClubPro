//
//  TestStrategicOptionFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation
@testable import GolfCore

enum TestStrategicOptionFactory {

    static func option(
        scoreExpectation: Double,
        hazardExposure: Double,
        penaltyProbability: Double,
        decisionConfidence: DecisionConfidence
    ) -> StrategicOption {

        let target =
            GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )

        let landingZone =
            LandingZoneEvaluation(
                location: target,
                lieQuality: .fairway,
                hazardExposure: hazardExposure,
                nextShotDistance: 120,
                scoreExpectation: scoreExpectation
            )

        let risk =
            RiskAssessment(
                riskLevel:
                    riskLevel(
                        hazardExposure: hazardExposure,
                        penaltyProbability: penaltyProbability
                    ),
                hazardExposure:
                    hazardExposure,
                penaltyProbability:
                    penaltyProbability,
                recommendation:
                    "Test risk assessment",
                confidence:
                    decisionConfidence == .none
                        ? 0
                        : 1
            )

        let metrics =
            StrategicDecisionMetrics(
                plannedCarryMeters: 160,
                optionScore: 2.5,
                decisionConfidence: decisionConfidence
            )

        return StrategicOption(
            target: target,
            clubID: ClubID(),
            landingZone: landingZone,
            risk: risk,
            metrics: metrics
        )
    }
    private static func riskLevel(
        hazardExposure: Double,
        penaltyProbability: Double
    ) -> RiskLevel {

        let combinedRisk =
            (
                hazardExposure +
                penaltyProbability
            ) / 2

        switch combinedRisk {

        case ..<0.25:
            return .low

        case ..<0.50:
            return .moderate

        case ..<0.75:
            return .high

        default:
            return .extreme
        }
    }
}
