//
//  SpatialRiskEvaluator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

public struct SpatialRiskEvaluator:
    Sendable {

    public init() {}

    private enum Constants {

        static let lowConfidencePenalty = 0.05
        static let boundaryRiskPenalty = 0.08
        static let maximumSpatialPenalty = 0.30
        static let boundaryRiskDistanceMeters = 5.0
        static let positionUncertaintyPenalty = 0.05
        
    }
    
    public func evaluate(
        analysis: SpatialAnalysis,
        spatialContext: RoundSpatialContext
    ) -> SpatialRiskAssessment {

        var penalty =
            0.0

        var reasons:
            [RecommendationReason] = []

        if !analysis.insideMappedArea {

            penalty +=
                Constants.positionUncertaintyPenalty

            reasons.append(
                .uncertainPosition
            )
        }

        if spatialContext.requiresConfirmation {
            penalty += Constants.lowConfidencePenalty
            reasons.append(
                .lowConfidence
            )
        }

        if let boundaryDistance =
                analysis
                    .nearestBoundaryDistanceMeters,
           boundaryDistance <= Constants.boundaryRiskDistanceMeters {

            penalty += Constants.boundaryRiskPenalty
            reasons.append(
                .boundaryRisk
            )
        }

        if let hazard =
                analysis.nearestHazard,
           let hazardDistance =
                analysis
                    .nearestHazardDistanceMeters {

            penalty += hazardPenalty(
                type: hazard.type,
                distanceMeters:
                    hazardDistance
            )

            reasons.append(
                .hazardAvoidance
            )
        }

        return SpatialRiskAssessment(
            penalty:
                min(Constants.maximumSpatialPenalty, penalty),
            reasons:
                unique(reasons)
        )
    }

    private func hazardPenalty(
        type: HoleAreaType,
        distanceMeters: Double
    ) -> Double {

        let proximityPenalty: Double

        switch distanceMeters {
        case ...5:
            proximityPenalty = 0.15

        case ...15:
            proximityPenalty = 0.10

        case ...30:
            proximityPenalty = 0.05

        default:
            proximityPenalty = 0
        }

        let severityMultiplier: Double

        switch type {
        case .outOfBounds:
            severityMultiplier = 1.30

        case .water,
             .penaltyArea:
            severityMultiplier = 1.20

        case .bunker:
            severityMultiplier = 0.80

        default:
            severityMultiplier = 0
        }

        return proximityPenalty *
            severityMultiplier
    }

    private func unique(
        _ reasons: [RecommendationReason]
    ) -> [RecommendationReason] {

        reasons.reduce(into: []) {
            result,
            reason in

            if !result.contains(reason) {
                result.append(reason)
            }
        }
    }
}
