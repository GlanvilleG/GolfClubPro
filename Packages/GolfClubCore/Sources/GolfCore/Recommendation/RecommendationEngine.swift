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

public enum RecommendationEngineError:
    Error,
    Equatable,
    Sendable {

    case noAvailableClubs
    case unableToCreateShotPlan
}

public struct RecommendationEngine:
    Sendable {

    private let strategyEngine:
        StrategyEngine

    private let spatialRiskEvaluator:
        SpatialRiskEvaluator

    private let clubScoringEngine:
        ClubScoringEngine

    private let recommendationSorter:
        RecommendationSorter

    private let explanationBuilder:
        RecommendationExplanationBuilder
    
    private let auditBuilder:
        RecommendationAuditBuilder
    
    private let explainabilityEngine:
        ExplainabilityEngine

    public init(
        strategyEngine:
            StrategyEngine =
                StrategyEngine(),
        spatialRiskEvaluator:
            SpatialRiskEvaluator =
                SpatialRiskEvaluator(),
        clubScoringEngine:
            ClubScoringEngine =
                ClubScoringEngine(),
        recommendationSorter:
            RecommendationSorter =
                RecommendationSorter(),
        explanationBuilder:
            RecommendationExplanationBuilder =
                RecommendationExplanationBuilder(),
        auditBuilder:
            RecommendationAuditBuilder =
                RecommendationAuditBuilder(),
        explainabilityEngine:
            ExplainabilityEngine =
                ExplainabilityEngine()
        ) {
        self.strategyEngine =
            strategyEngine

        self.spatialRiskEvaluator =
            spatialRiskEvaluator

        self.clubScoringEngine =
            clubScoringEngine

        self.recommendationSorter =
            recommendationSorter

        self.explanationBuilder =
            explanationBuilder
            
        self.auditBuilder =
                auditBuilder
            
        self.explainabilityEngine =
                explainabilityEngine
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
        spatialRisk:
            SpatialRiskAssessment
    ) throws -> RecommendationResult {

        guard !context.availableClubs.isEmpty else {
            throw RecommendationEngineError
                .noAvailableClubs
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

        let scoredCandidates =
            context.availableClubs
                .filter {
                    $0.type != .putter
                }
                .compactMap { club in
                    clubScoringEngine.score(
                        club: club,
                        targetDistanceMeters:
                            shotPlan
                                .targetDistanceMeters,
                        context:
                            context,
                        shotPlan:
                            shotPlan,
                        spatialRisk:
                            spatialRisk
                    )
                }

        let recommendations =
            recommendationSorter.sort(
                scoredCandidates
            )

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

        let decision =
            RecommendationDecision(
                shotPlan:
                    shotPlan,
                preferredClub:
                    preferred,
                alternatives:
                    alternatives,
                aimOffsetDegrees:
                    aimOffset
            )

        // Start Explanations being removed from the Engine - Code change Var -> Let - DEBUG
        let narrativeExplanation = explanationBuilder.build(
            decision: decision,
            context: context,
            spatialRisk: spatialRisk
        )
        // End DEBUG
        
        let structured = explainabilityEngine.explain(decision: decision)

        let explanation = RecommendationExplanation(
            summary: narrativeExplanation.summary,
            primaryReasons: narrativeExplanation.primaryReasons,
            environmentalConditions: narrativeExplanation.environmentalConditions,
            warnings: narrativeExplanation.warnings,
            confidenceStatement: narrativeExplanation.confidenceStatement,
            courseManagementAdvice: narrativeExplanation.courseManagementAdvice,
            nextShotFocus: narrativeExplanation.nextShotFocus,
            evidence: structured.evidence
        )

        let auditRecord =
            auditBuilder.build(
                decision:
                    decision,
                explanation:
                    explanation,
                context:
                    context,
                candidates:
                    recommendations
            )

       return RecommendationResult(
            decision:
                decision,
            explanation:
                explanation,
            auditRecord:
                auditRecord
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
    
    ///TEMP - Keep a copy of angular angularDifferenceDegrees() for calculateAimOffsetDegrees(...)  -> move to a shared utility so ClubScoringEngine() can access  the same logic.
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
    
}
