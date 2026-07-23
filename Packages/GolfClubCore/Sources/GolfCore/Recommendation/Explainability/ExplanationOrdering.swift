//
//  ExplanationOrdering.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

// MARK: - Deterministic ordering and deduplication for StructuredExplanationEvidence

public struct StructuredEvidenceOrderer: Sendable {
    public init() {}

    /// Deterministically sort and deduplicate structured evidence.
    /// - Parameter items: Input evidence items (may contain duplicates)
    /// - Returns: Sorted, de-duplicated evidence
    public func orderedUnique(_ items: [StructuredExplanationEvidence]) -> [StructuredExplanationEvidence] {
        var seen: Set<String> = []
        var result: [StructuredExplanationEvidence] = []
        for item in items.sorted(by: stableSort) {
            let key = compositeKey(item)
            if seen.contains(key) { continue }
            seen.insert(key)
            result.append(item)
        }
        return result
    }

    private func stableSort(_ lhs: StructuredExplanationEvidence, _ rhs: StructuredExplanationEvidence) -> Bool {
        let categoryPriority: [ExplanationCategory] = [
            .primaryClub, .alternatives, .aimRoute, .riskHazard, .environment, .playerPerformance, .confidence, .warnings
        ]
        func prio(_ c: ExplanationCategory) -> Int { categoryPriority.firstIndex(of: c) ?? categoryPriority.count }
        if prio(lhs.category) != prio(rhs.category) { return prio(lhs.category) < prio(rhs.category) }
        if lhs.source.rawValue != rhs.source.rawValue { return lhs.source.rawValue < rhs.source.rawValue }
        switch (lhs.importance, rhs.importance) {
        case let (l?, r?) where l != r: return l > r
        default: break
        }
        if lhs.factKey != rhs.factKey { return lhs.factKey < rhs.factKey }
        let lID = lhs.relatedModel?.id ?? ""
        let rID = rhs.relatedModel?.id ?? ""
        if lID != rID { return lID < rID }
        return textualValue(lhs.value) < textualValue(rhs.value)
    }

    private func compositeKey(_ s: StructuredExplanationEvidence) -> String {
        "\(s.category.rawValue)|\(s.source.rawValue)|\(s.factKey)|\(s.relatedModel?.id ?? "")"
    }

    private func textualValue(_ v: ExplanationValue) -> String {
        switch v {
        case .number(let d): return String(format: "%.6f", d)
        case .integer(let i): return String(i)
        case .boolean(let b): return b ? "true" : "false"
        case .text(let s): return s
        case .quantity(let value, let unit): return String(format: "%.6f %@", value, unit)
        }
    }
}

// MARK: - Deterministic ordering and deduplication for public ExplanationEvidence

public struct PublicEvidenceOrderer: Sendable {
    public init() {}

    /// Deterministically sort and reindex public evidence items by kind, code, then details keys.
    /// - Parameter items: Input public evidence items
    /// - Returns: Sorted items with strictly increasing order values (0..n-1)
    public func ordered(_ items: [ExplanationEvidence]) -> [ExplanationEvidence] {
        let sorted = items.sorted(by: stableSort)
        return sorted.enumerated().map { idx, item in
            ExplanationEvidence(kind: item.kind, code: item.code, title: item.title, details: item.details, order: idx)
        }
    }

    private func stableSort(_ lhs: ExplanationEvidence, _ rhs: ExplanationEvidence) -> Bool {
        // Primary order: kind by fixed priority to keep preferred -> alternatives -> aim -> weather -> confidence -> context -> holeAssessment -> metadata -> other
        let kindPriority: [ExplanationEvidence.Kind] = [.preferredClub, .alternatives, .aim, .weather, .confidence, .context, .holeAssessment, .metadata, .dispersion, .riskReward, .strategicOption, .other]
        func kprio(_ k: ExplanationEvidence.Kind) -> Int { kindPriority.firstIndex(of: k) ?? kindPriority.count }
        if kprio(lhs.kind) != kprio(rhs.kind) { return kprio(lhs.kind) < kprio(rhs.kind) }
        if lhs.code != rhs.code { return lhs.code < rhs.code }
        // Tie-breaker by details keys and values sorted lexicographically
        let lPairs = lhs.details.sorted { $0.key < $1.key }
        let rPairs = rhs.details.sorted { $0.key < $1.key }
        for (l, r) in zip(lPairs, rPairs) {
            if l.key != r.key { return l.key < r.key }
            if l.value != r.value { return l.value < r.value }
        }
        // Finally by title
        if lhs.title != rhs.title { return lhs.title < rhs.title }
        // Fall back to existing order for stability if all else equal
        return lhs.order < rhs.order
    }
}

