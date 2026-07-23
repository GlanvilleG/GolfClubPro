//
//  ExplanationMapping.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

/// Maps internal StructuredExplanationEvidence into the public RecommendationExplanation evidence items.
/// This preserves the existing public API while allowing the Explainability Engine to operate on richer internal structures.
public struct ExplanationEvidenceMapper: Sendable {

    public init() {}

    /// Deterministically map a list of StructuredExplanationEvidence into the lightweight public evidence items.
    /// - Parameters:
    ///   - structured: Internal structured evidence items.
    /// - Returns: Public-facing evidence items, ordered deterministically.
    public func map(_ structured: [StructuredExplanationEvidence]) -> [ExplanationEvidence] {
        // Deduplicate by a stable composite key (category, source, factKey, relatedModel id)
        var seen: Set<String> = []
        var items: [ExplanationEvidence] = []

        for s in structured.sorted(by: stableSort) {
            let key = compositeKey(for: s)
            if seen.contains(key) { continue }
            seen.insert(key)
            items.append(convert(s))
        }

        // Assign a deterministic order index based on the final order
        return items.enumerated().map { index, item in
            ExplanationEvidence(
                kind: item.kind,
                code: item.code,
                title: item.title,
                details: item.details,
                order: index
            )
        }
    }

    // MARK: - Private helpers

    private func stableSort(_ lhs: StructuredExplanationEvidence, _ rhs: StructuredExplanationEvidence) -> Bool {
        // Category priority ordering to align with Phase 7 baseline
        let categoryPriority: [ExplanationCategory] = [
            .primaryClub, .alternatives, .aimRoute, .riskHazard, .environment, .playerPerformance, .confidence, .warnings
        ]
        func priority(_ c: ExplanationCategory) -> Int { categoryPriority.firstIndex(of: c) ?? categoryPriority.count }

        if priority(lhs.category) != priority(rhs.category) {
            return priority(lhs.category) < priority(rhs.category)
        }
        // Source name
        if lhs.source.rawValue != rhs.source.rawValue { return lhs.source.rawValue < rhs.source.rawValue }
        // Importance (higher first when available)
        switch (lhs.importance, rhs.importance) {
        case let (l?, r?) where l != r:
            return l > r
        default:
            break
        }
        // factKey
        if lhs.factKey != rhs.factKey { return lhs.factKey < rhs.factKey }
        // relatedModel id if present
        let lID = lhs.relatedModel?.id ?? ""
        let rID = rhs.relatedModel?.id ?? ""
        if lID != rID { return lID < rID }
        // value textual fallback for tie-break
        return textualValue(lhs.value) < textualValue(rhs.value)
    }

    private func compositeKey(for s: StructuredExplanationEvidence) -> String {
        let rm = s.relatedModel?.id ?? ""
        return "\(s.category.rawValue)|\(s.source.rawValue)|\(s.factKey)|\(rm)"
    }

    private func convert(_ s: StructuredExplanationEvidence) -> ExplanationEvidence {
        // Map category/source to existing Kind best-effort without inventing new semantics.
        let kind: ExplanationEvidence.Kind = mapKind(category: s.category, source: s.source)
        let code = s.factKey
        let title = humanTitle(from: s) // Prefer structured description; fallback to humanFallback or factKey
        var details: [String: String] = [:]
        if let unit = s.unit {
            details["unit"] = unit
        }
        if let dir = s.direction { details["direction"] = dir.rawValue }
        if let conf = s.confidenceRef {
            details["confidence.domain"] = conf.domain
            details["confidence.path"] = conf.keyPath
        }
        if let rm = s.relatedModel {
            details["related.kind"] = rm.kind.rawValue
            details["related.id"] = rm.id
            if let extra = rm.extra {
                for (k, v) in extra.sorted(by: { $0.key < $1.key }) {
                    details["related.extra.\(k)"] = v
                }
            }
        }
        // Encode the value in a stable textual form for the lightweight evidence API
        details["value"] = textualValue(s.value)
        return ExplanationEvidence(kind: kind, code: code, title: title, details: details, order: 0)
    }

    private func mapKind(category: ExplanationCategory, source: ExplanationSource) -> ExplanationEvidence.Kind {
        switch category {
        case .primaryClub: return .preferredClub
        case .aimRoute: return .aim
        case .riskHazard: return .holeAssessment
        case .environment: return .weather
        case .playerPerformance: return .context
        case .confidence: return .confidence
        case .alternatives: return .alternatives
        case .warnings: return .metadata
        }
    }

    private func humanTitle(from s: StructuredExplanationEvidence) -> String {
        if let text = s.humanFallback, !text.isEmpty { return text }
        // Construct a minimal human-readable title from factKey and value
        let valueText = textualValue(s.value)
        if let unit = s.unit, case .quantity = s.value {
            return "\(s.factKey): \(valueText) \(unit)"
        } else {
            return "\(s.factKey): \(valueText)"
        }
    }

    private func textualValue(_ v: ExplanationValue) -> String {
        switch v {
        case .number(let d): return String(format: "%.3f", d)
        case .integer(let i): return String(i)
        case .boolean(let b): return b ? "true" : "false"
        case .text(let s): return s
        case .quantity(let value, let unit):
            return String(format: "%.3f %@", value, unit)
        }
    }
}

