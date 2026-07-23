//
//  ExplainabilityCompositionFacade.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

/// Facade to compose explainability evidence from decision-only facts using existing composers.
public struct ExplainabilityCompositionFacade: Sendable {
    private let confidenceComposer: ConfidenceAndWarningsComposer
    private let alternativesComposer: AlternativesExplanationComposer
    private let orderer: StructuredEvidenceOrderer
    private let mapper: ExplanationEvidenceMapper

    public init(
        confidenceComposer: ConfidenceAndWarningsComposer = ConfidenceAndWarningsComposer(),
        alternativesComposer: AlternativesExplanationComposer = AlternativesExplanationComposer(),
        orderer: StructuredEvidenceOrderer = StructuredEvidenceOrderer(),
        mapper: ExplanationEvidenceMapper = ExplanationEvidenceMapper()
    ) {
        self.confidenceComposer = confidenceComposer
        self.alternativesComposer = alternativesComposer
        self.orderer = orderer
        self.mapper = mapper
    }

    /// Build structured evidence from a decision using only existing facts.
    /// This does not recalculate golf logic and remains deterministic.
    public func structuredEvidence(from decision: RecommendationDecision) -> [StructuredExplanationEvidence] {
        var items: [StructuredExplanationEvidence] = []

        // Basics from decision (preferred, aim/route, risk, rationale, etc.)
        items.append(contentsOf: DecisionBasicsComposer().compose(from: decision))

        // Confidence and warnings
        items.append(contentsOf: confidenceComposer.compose(from: decision))

        // Alternatives
        items.append(contentsOf: alternativesComposer.compose(from: decision))

        // Normalize ordering and remove duplicates deterministically
        return orderer.orderedUnique(items)
    }

    /// Convenience: map structured evidence to public RecommendationExplanation evidence items.
    public func publicEvidence(from decision: RecommendationDecision) -> [ExplanationEvidence] {
        let structured = structuredEvidence(from: decision)
        return mapper.map(structured)
    }
}

// MARK: - Local basics composer (decision-only)

/// Extracts core decision facts as structured evidence without recomputation.
public struct DecisionBasicsComposer: Sendable {
    public init() {}

    public func compose(from decision: RecommendationDecision) -> [StructuredExplanationEvidence] {
        var items: [StructuredExplanationEvidence] = []

        if let preferred = decision.preferredClub {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("decision.preferredClub.id"),
                    category: .primaryClub,
                    source: .recommendationDecision,
                    factKey: "club.preferred.id",
                    value: .text(String(describing: preferred.clubID)),
                    unit: nil,
                    direction: .unknown,
                    importance: 1.0,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: preferred.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("decision.preferredClub.adjustedCarry"),
                    category: .primaryClub,
                    source: .recommendationDecision,
                    factKey: "club.preferred.adjustedCarryMeters",
                    value: .quantity(value: preferred.adjustedCarryMeters, unit: "m"),
                    unit: "m",
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: preferred.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )
            for (idx, reason) in preferred.reasons.enumerated() {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("decision.preferredClub.reason.\(idx)"),
                        category: .primaryClub,
                        source: .recommendationDecision,
                        factKey: "club.preferred.reason",
                        value: .text(reason),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: RelatedModelRef(kind: .club, id: String(describing: preferred.clubID)),
                        humanFallback: reason,
                        audit: nil
                    )
                )
            }
        }

        // Aim/route and risk
        items.append(
            StructuredExplanationEvidence(
                id: ExplanationEvidenceID("decision.aim.offset.degrees"),
                category: .aimRoute,
                source: .recommendationDecision,
                factKey: "aim.offset.degrees",
                value: .number(decision.aimOffsetDegrees),
                unit: "deg",
                direction: .neutral,
                importance: nil,
                confidenceRef: nil,
                relatedModel: nil,
                humanFallback: nil,
                audit: nil
            )
        )
        items.append(
            StructuredExplanationEvidence(
                id: ExplanationEvidenceID("decision.route.strategy"),
                category: .aimRoute,
                source: .recommendationDecision,
                factKey: "route.strategy",
                value: .text(decision.shotPlan.routeStrategy.rawValue),
                unit: nil,
                direction: .neutral,
                importance: nil,
                confidenceRef: nil,
                relatedModel: nil,
                humanFallback: nil,
                audit: nil
            )
        )
        items.append(
            StructuredExplanationEvidence(
                id: ExplanationEvidenceID("decision.risk.level"),
                category: .riskHazard,
                source: .recommendationDecision,
                factKey: "risk.level",
                value: .text(decision.shotPlan.riskLevel.rawValue),
                unit: nil,
                direction: .neutral,
                importance: nil,
                confidenceRef: nil,
                relatedModel: nil,
                humanFallback: nil,
                audit: nil
            )
        )

        // Rationale (human-fallback only)
        if !decision.shotPlan.rationale.isEmpty {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("decision.shotPlan.rationale"),
                    category: .aimRoute,
                    source: .recommendationDecision,
                    factKey: "shotPlan.rationale",
                    value: .text(decision.shotPlan.rationale),
                    unit: nil,
                    direction: .unknown,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: nil,
                    humanFallback: decision.shotPlan.rationale,
                    audit: nil
                )
            )
        }

        return items
    }
}

