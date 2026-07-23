//
//  AlternativesExplanationComposer.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

/// Composes alternative-club explanation evidence from decision-only facts.
public struct AlternativesExplanationComposer: Sendable {
    public init() {}

    public func compose(from decision: RecommendationDecision) -> [StructuredExplanationEvidence] {
        var items: [StructuredExplanationEvidence] = []

        guard !decision.alternatives.isEmpty else { return items }

        for (rank, alt) in decision.alternatives.enumerated() {
            // Alternative identity
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("alt.\(rank).id"),
                    category: .alternatives,
                    source: .recommendationDecision,
                    factKey: "alternative.club.id",
                    value: .text(String(describing: alt.clubID)),
                    unit: nil,
                    direction: .unknown,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: alt.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )

            // Alternative confidence
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("alt.\(rank).confidence"),
                    category: .confidence,
                    source: .recommendationDecision,
                    factKey: "alternative.club.confidence",
                    value: .number(alt.confidence),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "recommendation.alternative", keyPath: "confidence[\(rank)]"),
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: alt.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )

            // Reasons as human-fallback items
            for (idx, reason) in alt.reasons.enumerated() {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("alt.\(rank).reason.\(idx)"),
                        category: .alternatives,
                        source: .recommendationDecision,
                        factKey: "alternative.club.reason",
                        value: .text(reason),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: RelatedModelRef(kind: .club, id: String(describing: alt.clubID)),
                        humanFallback: reason,
                        audit: nil
                    )
                )
            }
        }

        return items
    }
}

