//
//  RecommendationAuditBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct RecommendationAuditBuilder:
    Sendable {

    public init() {}

    public func build(
        decision: RecommendationDecision,
        explanation: RecommendationExplanation,
        context: ShotContext,
        candidates: [ClubRecommendation]
    ) -> RecommendationAuditRecord? {

        guard context.player
            .recommendationAuditEnabled
        else {
            return nil
        }

        return RecommendationAuditRecord(
            playerID:
                context.player.id,
            roundID:
                context.roundID,
            holeID:
                context.hole.id,
            currentPosition:
                context.currentPosition,
            playableLie:
                context.playableLie,
            courseArea:
                context.courseArea,
            targetPoint:
                decision.shotPlan.aimPoint,
            targetBearingDegrees:
                decision
                    .shotPlan
                    .targetBearingDegrees,
            targetDistanceMeters:
                decision
                    .shotPlan
                    .targetDistanceMeters,
            preferredClubID:
                decision
                    .preferredClub?
                    .clubID,
            alternativeClubIDs:
                decision
                    .alternatives
                    .map(\.clubID),
            candidateClubs:
                makeCandidateSnapshots(
                    candidates
                ),
            aimOffsetDegrees:
                decision.aimOffsetDegrees,
            riskLevel:
                decision.shotPlan.riskLevel,
            recommendationConfidence:
                decision
                    .preferredClub?
                    .confidence ??
                0,
            explanation:
                explanation.summary,
            weatherObservedAt:
                context
                    .environment
                    .weatherSnapshot?
                    .observedAt,
            weatherAvailability:
                context
                    .environment
                    .weatherAvailability,
            weatherSource:
                context
                    .environment
                    .weatherSnapshot?
                    .source ??
                .unknown,
            windSpeedMetersPerSecond:
                context
                    .environment
                    .wind?
                    .speedMetersPerSecond,
            windDirectionDegrees:
                context
                    .environment
                    .wind?
                    .directionDegrees,
            windGustMetersPerSecond:
                context
                    .environment
                    .weatherSnapshot?
                    .windGustMetersPerSecond,
            temperatureCelsius:
                context
                    .environment
                    .temperatureCelsius,
            humidityPercent:
                context
                    .environment
                    .humidityPercent,
            pressureHPa:
                context
                    .environment
                    .pressureHPa
        )
    }

    private func makeCandidateSnapshots(
        _ candidates: [ClubRecommendation]
    ) -> [RecommendationCandidateSnapshot] {

        candidates.map {
            RecommendationCandidateSnapshot(
                clubID:
                    $0.clubID,
                score:
                    $0.score,
                adjustedCarryMeters:
                    $0.adjustedCarryMeters,
                confidence:
                    $0.confidence
            )
        }
    }
}
