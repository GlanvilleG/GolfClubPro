//
//  ConfidenceAndWarningComposer.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

/// Composes confidence and warning evidence without recalculation, using only available decision facts.
public struct ConfidenceAndWarningsComposer: Sendable {
    public init() {}
    
    public func compose(from decision: RecommendationDecision) -> [StructuredExplanationEvidence] {
        var items: [StructuredExplanationEvidence] = []
        
        // Add preferred club confidence item
        if let preferred = decision.preferredClub {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("conf.preferred"),
                    category: .confidence,
                    source: .recommendationDecision,
                    factKey: "confidence.preferredClub",
                    value: .number(preferred.confidence),
                    unit: nil,
                    direction: .increased,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "preferredClub", keyPath: "confidence"),
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: preferred.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )
            if let preferred = decision.preferredClub, preferred.confidence < 0.2 {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("conf.preferred.lowFlag"),
                        category: .confidence,
                        source: .recommendationDecision,
                        factKey: "confidence.preferredClub.lowFlag",
                        value: .boolean(true),
                        unit: nil,
                        direction: .neutral,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: RelatedModelRef(kind: .club, id: String(describing: preferred.clubID)),
                        humanFallback: nil,
                        audit: nil
                    )
                )
            }
        }
        
        // Add shot plan confidence item
        items.append(
            StructuredExplanationEvidence(
                id: ExplanationEvidenceID("conf.shotPlan"),
                category: .confidence,
                source: .recommendationDecision,
                factKey: "confidence.shotPlan",
                value: .number(decision.shotPlan.confidence),
                unit: nil,
                direction: .increased,
                importance: nil,
                confidenceRef: ConfidenceRef(domain: "shotPlan", keyPath: "confidence"),
                relatedModel: nil,
                humanFallback: nil,
                audit: nil
            )
        )
        if decision.shotPlan.confidence < 0.2 {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("conf.shotPlan.lowFlag"),
                    category: .confidence,
                    source: .recommendationDecision,
                    factKey: "confidence.shotPlan.lowFlag",
                    value: .boolean(true),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "shotPlan", keyPath: "confidence"),
                    relatedModel: nil,
                    humanFallback: nil,
                    audit: nil
                )
            )
        }
        
        // Existing handling of rationale/noRationale warning block
        // Use shotPlan.rationale as the canonical rationale source
        let rationaleText = decision.shotPlan.rationale
        if !rationaleText.isEmpty {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("rationale"),
                        category: .warnings,
                        source: .recommendationDecision,
                        factKey: "rationale.text",
                        value: .text(rationaleText),
                        unit: nil,
                        direction: .neutral,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: rationaleText,
                        audit: nil
                    )
            )
        } else {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("noRationale"),
                    category: .warnings,
                    source: .recommendationDecision,
                    factKey: "rationale.missing",
                    value: .boolean(true),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: nil,
                    humanFallback: nil,
                    audit: nil
                )
            )
        }
        
        for (idx, alt) in decision.alternatives.enumerated() where alt.confidence < 0.2 {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("conf.alternative.\(idx).lowFlag"),
                    category: .confidence,
                    source: .recommendationDecision,
                    factKey: "confidence.alternative.lowFlag",
                    value: .boolean(true),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "recommendation.alternative", keyPath: "confidence[\(idx)]"),
                    relatedModel: RelatedModelRef(kind: .club, id: String(describing: alt.clubID)),
                    humanFallback: nil,
                    audit: nil
                )
            )
        }
        
        return items
    }
}

