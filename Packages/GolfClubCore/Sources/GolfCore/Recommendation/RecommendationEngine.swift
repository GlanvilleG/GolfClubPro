//
//  RecommendationEngine.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

// Disambiguate RecommendationDecision if multiple modules define it
//private typealias CoreRecommendationDecision = RecommendationDecision

public struct ClubRecommendation:
    Codable,
    Equatable,
    Sendable {

    public var clubID: ClubID
    public var score: Double
    public var adjustedCarryMeters: Double
    public var distanceDifferenceMeters: Double
    public var confidence: Double
    public var reasons: [String]

    public init(
        clubID: ClubID,
        score: Double,
        adjustedCarryMeters: Double,
        distanceDifferenceMeters: Double,
        confidence: Double,
        reasons: [String]
    ) {
        self.clubID = clubID
        self.score = score
        self.adjustedCarryMeters = adjustedCarryMeters
        self.distanceDifferenceMeters = distanceDifferenceMeters
        self.confidence = min(1, max(0, confidence))
        self.reasons = reasons
    }
}

public struct RecommendationResult:
    Codable,
    Equatable,
    Sendable {

    public let decision:
        RecommendationDecision

    public let explanation:
        String

    public let auditRecord:
        RecommendationAuditRecord?

    public init(
        decision:
            RecommendationDecision,
        explanation:
            String,
        auditRecord:
            RecommendationAuditRecord? = nil
    ) {
        self.decision =
            decision

        self.explanation =
            explanation

        self.auditRecord =
            auditRecord
    }
}
public enum RecommendationEngineError:
    Error,
    Equatable,
    Sendable {

    case noAvailableClubs
    case unableToCreateShotPlan
}

public struct RecommendationEngine: Sendable {

    private let strategyEngine: StrategyEngine
    private let spatialRiskEvaluator: SpatialRiskEvaluator
    private let clubScoringEngine: ClubScoringEngine
 
    public init(
        strategyEngine:
            StrategyEngine =
                StrategyEngine(),
        spatialRiskEvaluator:
            SpatialRiskEvaluator =
                SpatialRiskEvaluator(),
        clubScoringEngine:
            ClubScoringEngine =
                ClubScoringEngine()
    ) {

        self.strategyEngine =
            strategyEngine

        self.spatialRiskEvaluator =
            spatialRiskEvaluator

        self.clubScoringEngine =
            clubScoringEngine

    }
    
    public func recommend(
        for context: ShotContext
    ) throws -> RecommendationResult {
        try recommend(
            for: context,
            spatialRisk:
                SpatialRiskAssessment.none
        )
    }

    private func recommend(
        for context: ShotContext,
        spatialRisk: SpatialRiskAssessment
    ) throws -> RecommendationResult {
        guard !context.availableClubs.isEmpty else {
            throw RecommendationEngineError.noAvailableClubs
        }

        let shotPlan: ShotPlan

        if let existingPlan =
            context.currentShotPlan {

            shotPlan =
                existingPlan
        } else {
            shotPlan =
                try strategyEngine.makeShotPlan(
                    from:
                        context.currentPosition,
                    using:
                        context.strategyGeometry
                )
        }

        let recommendations =
            context.availableClubs
                .filter {
                    $0.type != .putter
                }
                .compactMap { club in
                    clubScoringEngine.score(
                        club:
                            club,
                        targetDistanceMeters:
                            shotPlan.targetDistanceMeters,
                        context:
                            context,
                        shotPlan:
                            shotPlan,
                        spatialRisk:
                            spatialRisk
                    )
                }
                .sorted { lhs, rhs in
                    if lhs.score == rhs.score {
                        return lhs
                            .distanceDifferenceMeters <
                            rhs
                            .distanceDifferenceMeters
                    }

                    return lhs.score >
                        rhs.score
                }

        let preferred =
            recommendations.first

        let alternatives =
            Array(
                recommendations
                    .dropFirst()
                    .prefix(2)
            )

        let aimOffset =
            calculateAimOffsetDegrees(
                context: context
            )

        let explanation =
            makeExplanation(
                preferred: preferred,
                shotPlan: shotPlan,
                context: context,
                aimOffsetDegrees:
                    aimOffset
            )

        let auditRecord:
            RecommendationAuditRecord?

        if context.player
            .recommendationAuditEnabled {

            auditRecord =
                makeAuditRecord(
                    context: context,
                    shotPlan: shotPlan,
                    preferred: preferred,
                    alternatives:
                        alternatives,
                    aimOffsetDegrees:
                        aimOffset,
                    explanation:
                        explanation,
                    candidates:
                        recommendations
                )
        } else {
            auditRecord = nil
        }

        let decision =
            RecommendationDecision(
                shotPlan: shotPlan,
                preferredClub: preferred,
                alternatives: alternatives,
                aimOffsetDegrees:
                    aimOffset
            )

        return RecommendationResult(
            decision: decision,
            explanation: explanation,
            auditRecord: auditRecord
        )
    }
    private func makeAuditRecord(
        context: ShotContext,
        shotPlan: ShotPlan,
        preferred: ClubRecommendation?,
        alternatives: [ClubRecommendation],
        aimOffsetDegrees: Double,
        explanation: String,
        candidates: [ClubRecommendation]
    ) -> RecommendationAuditRecord {
        RecommendationAuditRecord(
            playerID: context.player.id,
            roundID: context.roundID,
            holeID: context.hole.id,
            currentPosition:
                context.currentPosition,
            playableLie:
                context.playableLie,
            courseArea:
                context.courseArea,
            targetPoint:
                shotPlan.aimPoint,
            targetBearingDegrees:
                shotPlan.targetBearingDegrees,
            targetDistanceMeters:
                shotPlan.targetDistanceMeters,
            preferredClubID:
                preferred?.clubID,
            alternativeClubIDs:
                alternatives.map(\.clubID),
            candidateClubs:
                candidates.map {
                    RecommendationCandidateSnapshot(
                        clubID: $0.clubID,
                        score: $0.score,
                        adjustedCarryMeters:
                            $0.adjustedCarryMeters,
                        confidence:
                            $0.confidence
                    )
                },
            aimOffsetDegrees:
                aimOffsetDegrees,
            riskLevel:
                shotPlan.riskLevel,
            recommendationConfidence:
                preferred?.confidence ?? 0,
            explanation:
                explanation,
            weatherObservedAt:
                context.environment
                    .weatherSnapshot?
                    .observedAt,

            weatherAvailability:
                context.environment
                    .weatherAvailability,

            weatherSource:
                context.environment
                    .weatherSnapshot?
                    .source ?? .unknown,

            windSpeedMetersPerSecond:
                context.environment
                    .wind?
                    .speedMetersPerSecond,

            windDirectionDegrees:
                context.environment
                    .wind?
                    .directionDegrees,

            windGustMetersPerSecond:
                context.environment
                    .weatherSnapshot?
                    .windGustMetersPerSecond,

            temperatureCelsius:
                context.environment
                    .temperatureCelsius,

            humidityPercent:
                context.environment
                    .humidityPercent,

            pressureHPa:
                context.environment
                    .pressureHPa
        )
    }
    
   
    private func calculateAimOffsetDegrees(
        context: ShotContext
    ) -> Double {
        var offset = 0.0

        for summary in context.recentShotHistory {
            if summary.commonErrors.contains(.push) ||
                summary.commonErrors.contains(.slice) {
                offset -= 3
            }

            if summary.commonErrors.contains(.pull) ||
                summary.commonErrors.contains(.hook) {
                offset += 3
            }
        }
        for summary in context.dispersionSummaries {
            guard summary.directionalSampleSize >= 3,
                  let averageError =
                    summary.averageDirectionalErrorDegrees
            else {
                continue
            }

            offset -= averageError * 0.50
        }

        if let wind = context.environment.wind {
            let relativeAngle =
                angularDifferenceDegrees(
                    context.currentShotPlan?
                        .targetBearingDegrees ?? 0,
                    wind.directionDegrees
                )

            let crosswindComponent =
                sin(relativeAngle * .pi / 180) *
                wind.speedMetersPerSecond

            offset -= crosswindComponent * 0.6
        }

        return min(15, max(-15, offset))
    }
    
    ///TEMP - Keep a copy of angular angularDifferenceDegrees() for calculateAimOffsetDegrees(...)  -> move to a shared utility so ClubScoringEngine() can access a the same.
    ///
    private func angularDifferenceDegrees(
        _ first: Double,
        _ second: Double
    ) -> Double {
        var difference =
            (second - first)
                .truncatingRemainder(dividingBy: 360)

        if difference > 180 {
            difference -= 360
        }

        if difference < -180 {
            difference += 360
        }

        return difference
    }
    
    private func makeExplanation(
        preferred: ClubRecommendation?,
        shotPlan: ShotPlan,
        context: ShotContext,
        aimOffsetDegrees: Double
    ) -> String {
        guard let preferred else {
            return "No suitable club recommendation is available."
        }

        let directionDescription: String

        if aimOffsetDegrees < -0.5 {
            directionDescription =
                "Aim \(Int(abs(aimOffsetDegrees).rounded())) degrees left of the planned target."
        } else if aimOffsetDegrees > 0.5 {
            directionDescription =
                "Aim \(Int(aimOffsetDegrees.rounded())) degrees right of the planned target."
        } else {
            directionDescription =
                "Aim directly at the planned target."
        }

        let weatherDescription: String

        switch context.environment.weatherAvailability {
        case .live:
            weatherDescription =
                "Live weather data was used."

        case .cached:
            weatherDescription =
                "Recent cached weather data was used."

        case .stale:
            weatherDescription =
                "Weather data is stale, so treat the recommendation cautiously."

        case .unavailable:
            weatherDescription =
                "Live weather was unavailable."
        }
        
        return """
        Recommended club confidence is \(Int((preferred.confidence * 100).rounded())) percent. \
        The adjusted carry is \(Int(preferred.adjustedCarryMeters.rounded())) metres. \
        \(directionDescription) \
        \(weatherDescription) \
        \(shotPlan.rationale)
        """
    }

  
}

