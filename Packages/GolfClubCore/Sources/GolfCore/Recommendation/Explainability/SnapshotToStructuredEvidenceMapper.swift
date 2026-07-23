//
//  SnapshotToStructuredEvidenceMapper.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//

import Foundation

/// Maps a RecommendationEvidenceSnapshot into structured explanation evidence without recomputation.
public struct SnapshotToStructuredEvidenceMapper: Sendable {
    private let orderer: StructuredEvidenceOrderer

    public init(orderer: StructuredEvidenceOrderer = StructuredEvidenceOrderer()) {
        self.orderer = orderer
    }

    public func map(_ snapshot: RecommendationEvidenceSnapshot) -> [StructuredExplanationEvidence] {
        var items: [StructuredExplanationEvidence] = []

        // Decision basics via the existing composer
        items.append(contentsOf: DecisionBasicsComposer().compose(from: snapshot.decision))

        // Preferred/shot-plan/alternatives confidence and warnings from decision
        items.append(contentsOf: ConfidenceAndWarningsComposer().compose(from: snapshot.decision))
        items.append(contentsOf: AlternativesExplanationComposer().compose(from: snapshot.decision))

        // Environmental assessment (if present)
        if let env = snapshot.environmentalAssessment {
            if let weather = env.weather {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("env.weather.crosswind"),
                        category: .environment,
                        source: .environmentalAssessment,
                        factKey: "environment.weather.crosswind.mps",
                        value: .quantity(value: weather.crosswindMetersPerSecond, unit: "m/s"),
                        unit: "m/s",
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: nil,
                        audit: nil
                    )
                )
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("env.weather.along"),
                        category: .environment,
                        source: .environmentalAssessment,
                        factKey: "environment.weather.along.mps",
                        value: .quantity(value: weather.alongWindMetersPerSecond, unit: "m/s"),
                        unit: "m/s",
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: nil,
                        audit: nil
                    )
                )
                // Weather freshness as confidence-related evidence
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("env.weather.ageSeconds"),
                        category: .confidence,
                        source: .environmentalAssessment,
                        factKey: "environment.weather.ageSeconds",
                        value: .integer(Int(weather.ageSeconds)),
                        unit: "s",
                        direction: .neutral,
                        importance: nil,
                        confidenceRef: ConfidenceRef(domain: "environment.weather", keyPath: "ageSeconds"),
                        relatedModel: nil,
                        humanFallback: nil,
                        audit: nil
                    )
                )
            }
            // Environmental overall confidence
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("env.confidence.overall"),
                    category: .confidence,
                    source: .environmentalAssessment,
                    factKey: "environment.confidence.overall",
                    value: .number(env.confidence.overall),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "environment", keyPath: "confidence.overall"),
                    relatedModel: nil,
                    humanFallback: nil,
                    audit: nil
                )
            )
        }

        // Strategic/risk/hole/dispersion/adjustments (lightweight summaries)
        if let strategicID = snapshot.strategicOptionID {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("strategy.option.id"),
                    category: .aimRoute,
                    source: .strategicOption,
                    factKey: "strategy.option.id",
                    value: .text(strategicID),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .strategicOption, id: strategicID),
                    humanFallback: nil,
                    audit: nil
                )
            )
        }
        if let risk = snapshot.riskRewardSummary {
            for (k, v) in risk.sorted(by: { $0.key < $1.key }) {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("risk.\(k)"),
                        category: .riskHazard,
                        source: .riskReward,
                        factKey: "riskReward.\(k)",
                        value: .text(v),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: "\(k): \(v)",
                        audit: nil
                    )
                )
            }
        }
        if let hazards = snapshot.holeHazardSummary {
            for (k, v) in hazards.sorted(by: { $0.key < $1.key }) {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("hazard.\(k)"),
                        category: .riskHazard,
                        source: .spatialAssessment,
                        factKey: "hazard.\(k)",
                        value: .text(v),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: "\(k): \(v)",
                        audit: nil
                    )
                )
            }
        }
        if let disp = snapshot.shotDispersionSummary {
            for (k, v) in disp.sorted(by: { $0.key < $1.key }) {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("dispersion.\(k)"),
                        category: .playerPerformance,
                        source: .playerIntelligence,
                        factKey: "dispersion.\(k)",
                        value: .text(v),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: "\(k): \(v)",
                        audit: nil
                    )
                )
            }
        }
        if let aa = snapshot.adaptiveAdjustmentSummary {
            for (k, v) in aa.sorted(by: { $0.key < $1.key }) {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("adaptive.\(k)"),
                        category: .playerPerformance,
                        source: .playerIntelligence,
                        factKey: "adaptive.\(k)",
                        value: .text(v),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: "\(k): \(v)",
                        audit: nil
                    )
                )
            }
        }
        if let wa = snapshot.weatherAdjustmentSummary {
            for (k, v) in wa.sorted(by: { $0.key < $1.key }) {
                items.append(
                    StructuredExplanationEvidence(
                        id: ExplanationEvidenceID("weatherAdj.\(k)"),
                        category: .environment,
                        source: .environmentalAssessment,
                        factKey: "weatherAdjustment.\(k)",
                        value: .text(v),
                        unit: nil,
                        direction: .unknown,
                        importance: nil,
                        confidenceRef: nil,
                        relatedModel: nil,
                        humanFallback: "\(k): \(v)",
                        audit: nil
                    )
                )
            }
        }

        // Candidates summary
        for (idx, c) in snapshot.candidates.enumerated() {
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("candidate.\(idx).clubID"),
                    category: .alternatives,
                    source: .scoringEngine,
                    factKey: "candidate.club.id",
                    value: .text(c.clubID),
                    unit: nil,
                    direction: .unknown,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .club, id: c.clubID),
                    humanFallback: nil,
                    audit: nil
                )
            )
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("candidate.\(idx).score"),
                    category: .alternatives,
                    source: .scoringEngine,
                    factKey: "candidate.score",
                    value: .number(c.score),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: nil,
                    relatedModel: RelatedModelRef(kind: .club, id: c.clubID),
                    humanFallback: nil,
                    audit: nil
                )
            )
            items.append(
                StructuredExplanationEvidence(
                    id: ExplanationEvidenceID("candidate.\(idx).confidence"),
                    category: .confidence,
                    source: .scoringEngine,
                    factKey: "candidate.confidence",
                    value: .number(c.confidence),
                    unit: nil,
                    direction: .neutral,
                    importance: nil,
                    confidenceRef: ConfidenceRef(domain: "candidate", keyPath: "confidence[\(idx)]"),
                    relatedModel: RelatedModelRef(kind: .club, id: c.clubID),
                    humanFallback: nil,
                    audit: nil
                )
            )
        }

        return orderer.orderedUnique(items)
    }
}
extension SnapshotToStructuredEvidenceMapper {
    /// Convenience: map a snapshot directly to public evidence items.
    public func mapToPublicEvidence(_ snapshot: RecommendationEvidenceSnapshot,
                                    mapper: ExplanationEvidenceMapper = ExplanationEvidenceMapper(),
                                    publicOrderer: PublicEvidenceOrderer = PublicEvidenceOrderer()) -> [ExplanationEvidence] {
        let structured = map(snapshot)
        let publicItems = mapper.map(structured)
        return publicOrderer.ordered(publicItems)
    }
}

