//
//  ExplainabilityEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//
import Foundation

public struct ExplainabilityEngine: Sendable {
    public init() {}

    // Deterministic string for ClubID without assuming UUID API
    private func clubIDString(_ id: ClubID) -> String {
        // Prefer CustomStringConvertible if available; otherwise fallback to debug description
        return String(describing: id)
    }

    // Deterministically convert a RecommendationDecision into a RecommendationExplanation
    // without recomputing any recommendation logic.
    public func explain(decision: RecommendationDecision) -> RecommendationExplanation {
        // Build compact, structured summary
        let preferredID = decision.preferredClub.map { clubIDString($0.clubID) } ?? "none"
        let altCount = decision.alternatives.count
        let aim = String(format: "%.2f", decision.aimOffsetDegrees)
        let summary = "decision:v1 preferred:\(preferredID) alternatives:\(altCount) aim:\(aim)"

        // Confidence summary (non-narrative)
        var confidenceSummary: String? = nil
        if let prefConf = decision.preferredClub?.confidence {
            let altMax = decision.alternatives.map { $0.confidence }.max()
            if let altMax { confidenceSummary = String(format: "preferred:%.4f altMax:%.4f", prefConf, altMax) }
            else { confidenceSummary = String(format: "preferred:%.4f", prefConf) }
        }

        // Evidence assembly (deterministic order)
        var order = 0
        var evidence: [ExplanationEvidence] = []

        // Context/metadata placeholders if available on decision in your codebase
        // Only include what exists to avoid recomputation
        // Since RecommendationDecision in this codebase does not show metadata fields here,
        // we skip context/metadata unless your concrete type exposes them.

        // Preferred club evidence
        if let preferred = decision.preferredClub {
            var details: [String: String] = [:]
            details["clubID"] = clubIDString(preferred.clubID)
            details["score"] = String(format: "%.4f", preferred.score)
            details["adjustedCarryMeters"] = String(format: "%.2f", preferred.adjustedCarryMeters)
            details["distanceDifferenceMeters"] = String(format: "%.2f", preferred.distanceDifferenceMeters)
            details["confidence"] = String(format: "%.4f", preferred.confidence)

            evidence.append(
                ExplanationEvidence(
                    kind: .preferredClub,
                    code: "preferred-club",
                    title: "Preferred Club",
                    details: details,
                    order: order
                )
            )
            order += 1
        }

        // Alternatives evidence
        if !decision.alternatives.isEmpty {
            var details: [String: String] = [:]
            details["count"] = String(decision.alternatives.count)
            let ids = decision.alternatives.map { clubIDString($0.clubID) }.joined(separator: ",")
            details["clubIDs"] = ids
            if let maxConf = decision.alternatives.map({ $0.confidence }).max() {
                details["maxConfidence"] = String(format: "%.4f", maxConf)
            }

            evidence.append(
                ExplanationEvidence(
                    kind: .alternatives,
                    code: "alternatives",
                    title: "Alternatives",
                    details: details,
                    order: order
                )
            )
            order += 1
        }

        // Aim evidence
        do {
            var details: [String: String] = [:]
            details["aimOffsetDegrees"] = String(format: "%.2f", decision.aimOffsetDegrees)
            evidence.append(
                ExplanationEvidence(
                    kind: .aim,
                    code: "aim",
                    title: "Aim",
                    details: details,
                    order: order
                )
            )
            order += 1
        }

        // Note: If RecommendationDecision later exposes strategic option, dispersion, hole assessment, weather, metadata
        // we will add them here without any recalculation, only copying existing values.

        // Confidence evidence (concise duplicate for consumers)
        if let confidenceSummary {
            evidence.append(
                ExplanationEvidence(
                    kind: .confidence,
                    code: "confidence",
                    title: "Confidence",
                    details: ["summary": confidenceSummary],
                    order: order
                )
            )
            order += 1
        }

        return RecommendationExplanation(
            summary: summary,
            primaryReasons: [],
            environmentalConditions: [],
            warnings: [],
            confidenceStatement: nil,
            courseManagementAdvice: nil,
            nextShotFocus: nil,
            evidence: evidence
        )
    }
}

