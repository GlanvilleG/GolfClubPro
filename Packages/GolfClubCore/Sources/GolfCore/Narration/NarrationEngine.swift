//
//  NarrationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// Deterministic, presentation-neutral Narration Engine.
/// Stage 5: Club and aim composition only — no environment/performance/risk/confidence yet.
public struct NarrationEngine: Sendable {
    public init() {}
    
    /// Generate narration for the given context using provided templates and variant.
    /// Returns a RecommendationNarration with primary composed from club and/or aim when available.
    public func narrate(
        context: NarrationContext,
        templates: NarrationTemplates = .default,
        variant: NarrationVariant
    ) -> RecommendationNarration {
        // Stage 5 composition for club/aim only
        let clubName = extractPreferredClubName(from: context)
        let aimDegrees = extractAimDegrees(from: context.explanation.evidence)
        let policy = context.policy
        
        let warnings = extractWarnings(from: context.explanation)
        let confidenceNote = extractConfidenceNote(from: context.explanation.evidence)
        
        var primary: String
        var reason: String? = nil
        let envReason = extractPrimaryEnvironmentalReason(from: context.explanation.evidence)
        let perfReason = extractPrimaryPerformanceReason(from: context.explanation.evidence)
        reason = envReason ?? perfReason
        
        
        var outReason: String? = nil
        var outWarnings: [String] = []
        var outDetails: [String] = []
        var outConfidence: String? = confidenceNote
        
        switch variant {
        case .concise:
            outReason = reason
            outWarnings = Array(warnings.prefix(1))
            outDetails = []
            outConfidence = nil
        case .standard:
            outReason = reason
            outWarnings = Array(warnings.prefix(1))
            outDetails = []
        case .detailed:
            outReason = reason
            outWarnings = warnings
            outDetails = buildDetails(from: context.explanation, excluding: reason)
        }
        
        if let club = clubName, let degrees = aimDegrees,
           abs(degrees) > policy.measurement.aimZeroSuppressionThresholdDegrees {
            let formattedDegrees = formatDegrees(degrees, policy: policy.measurement)
            let direction = aimDirectionWord(for: degrees)
            primary = "Use the \(club). Aim \(formattedDegrees) \(direction)."
        } else if let club = clubName {
            primary = "Use the \(club)."
        } else if let degrees = aimDegrees,
                  abs(degrees) > policy.measurement.aimZeroSuppressionThresholdDegrees {
            let formattedDegrees = formatDegrees(degrees, policy: policy.measurement)
            let direction = aimDirectionWord(for: degrees)
            primary = "Aim \(formattedDegrees) \(direction)."
        } else {
            primary = "Narration pending"
        }
        
        let metadata = NarrationMetadata(
            templateVersion: NarrationTemplates.version,
            policyIdentifier: context.policy.identifier,
            orderingSeed: nil
        )
        
        let alternativeNames = extractAlternativeClubNames(from: context)
        let alternatives: [String]

        switch variant {
        case .concise, .standard:
            if let first = alternativeNames.first {
                alternatives = ["Alternative: \(first)"]
            } else {
                alternatives = []
            }
        case .detailed:
            alternatives = alternativeNames.prefix(3).map { "Alternative: \($0)" }
        }
        
        return RecommendationNarration(
            primary: primary,
            reason: outReason,
            details: outDetails,
            warnings: outWarnings,
            confidenceNote: outConfidence,
            alternatives: alternatives,
            metadata: metadata
        )
    }
    
    // MARK: - Helpers
    
    private func extractPreferredClubName(from context: NarrationContext) -> String? {
        for ev in context.explanation.evidence {
            if ev.kind == .preferredClub,
               let clubID = ev.details["clubID"],
               let displayName = context.clubDisplayNames[clubID] {
                return displayName
            }
        }
        return nil
    }
    
    private func extractAimDegrees(from evidence: [ExplanationEvidence]) -> Double? {
        for ev in evidence {
            if ev.kind == .aim,
               let aimString = ev.details["aimOffsetDegrees"],
               let aimDegrees = Double(aimString) {
                return aimDegrees
            }
        }
        return nil
    }
    
    private func formatDegrees(_ degrees: Double, policy: MeasurementPolicy) -> String {
        let digits = max(0, policy.degreeFractionDigits)
        let format = "% .\(digits)f"
        let value = String(format: format, abs(degrees))
        return value + "°"
    }
    
    private func aimDirectionWord(for degrees: Double) -> String {
        if degrees > 0 { return "right" }
        if degrees < 0 { return "left" }
        return "at target"
    }
    private func extractPrimaryEnvironmentalReason(from evidence: [ExplanationEvidence]) -> String? {
        for ev in evidence.sorted(by: { $0.order < $1.order }) {
            if ev.kind == .weather {
                return ev.title
            }
        }
        return nil
    }
    
    private func extractPrimaryPerformanceReason(from evidence: [ExplanationEvidence]) -> String? {
        for ev in evidence.sorted(by: { $0.order < $1.order }) {
            if ev.kind == .dispersion {
                return ev.title
            }
        }
        return nil
    }
    private func extractWarnings(from explanation: RecommendationExplanation) -> [String] {
        return explanation.warnings.map { $0.title }
    }
    
    private func extractConfidenceNote(from evidence: [ExplanationEvidence]) -> String? {
        for item in evidence {
            if item.kind == .confidence {
                return item.details["summary"]
            }
        }
        return nil
    }
    private func buildDetails(from explanation: RecommendationExplanation, excluding reason: String?) -> [String] {
        var titles: [String] = []
        titles.append(contentsOf: explanation.environmentalConditions.map { $0.title })
        titles.append(contentsOf: explanation.primaryReasons.map { $0.title })
        var seen = Set<String>()
        var result: [String] = []
        for t in titles {
            if let r = reason, t == r { continue }
            if !seen.contains(t) {
                seen.insert(t)
                result.append(t)
            }
        }
        return result
    }
    func extractAlternativeClubNames(from context: NarrationContext) -> [String] {
        guard let evidence = context.explanation.evidence.first(where: { $0.kind == .alternatives }),
              let clubIDsString = evidence.details["clubIDs"] else {
            return []
        }
        let clubIDs = clubIDsString.split(separator: ",").map { String($0) }
        let alternativeNames = clubIDs.compactMap { context.clubDisplayNames[$0] }
        return alternativeNames
    }
}
