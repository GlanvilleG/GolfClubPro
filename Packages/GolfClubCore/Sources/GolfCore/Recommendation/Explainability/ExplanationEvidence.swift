//
//  ExplanationEvidence.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

// MARK: - Supporting lightweight references

/// Reference to a confidence value that already exists in the snapshot (environmental, player, risk, etc.).
public struct ConfidenceRef: Codable, Equatable, Sendable {
    public let domain: String     // e.g., "environmental.overall", "player.sampleSize"
    public let keyPath: String    // stable path within the snapshot model
    public init(domain: String, keyPath: String) {
        self.domain = domain
        self.keyPath = keyPath
    }
}

/// Reference to a related domain entity (e.g., a club, option, or hazard type) without embedding the full model.
public struct RelatedModelRef: Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Sendable { case club, strategicOption, hazard, hole, dispersion, riskReward, environment }
    public let kind: Kind
    public let id: String         // UUID or domain identifier encoded as string
    public let extra: [String: String]? // optional small metadata like club type or hazard subtype
    public init(kind: Kind, id: String, extra: [String: String]? = nil) {
        self.kind = kind
        self.id = id
        self.extra = extra
    }
}

/// Minimal audit metadata for traceability without copying source models.
public struct EvidenceAuditMeta: Codable, Equatable, Sendable {
    public let snapshotID: String?
    public let producedAt: Date?
    public let schemaVersion: String?
    public init(snapshotID: String? = nil, producedAt: Date? = nil, schemaVersion: String? = nil) {
        self.snapshotID = snapshotID
        self.producedAt = producedAt
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Explanation Evidence (Stage 2)

/// A single traceable, deterministic fact that supports the explanation.
public struct StructuredExplanationEvidence: Codable, Equatable, Sendable {
    public let id: ExplanationEvidenceID
    public let category: ExplanationCategory
    public let source: ExplanationSource
    public let factKey: String              // stable key, e.g., "club.preferred.carry.medianMeters"
    public let value: ExplanationValue      // structured value
    public let unit: String?                // optional unit (e.g., "m", "m/s", "deg")
    public let direction: InfluenceDirection?
    public let importance: Double?          // 0...1 if known; do not invent
    public let confidenceRef: ConfidenceRef?
    public let relatedModel: RelatedModelRef?
    public let humanFallback: String?       // for legacy reasons/strings when structure is unavailable
    public let audit: EvidenceAuditMeta?

    public init(
        id: ExplanationEvidenceID,
        category: ExplanationCategory,
        source: ExplanationSource,
        factKey: String,
        value: ExplanationValue,
        unit: String? = nil,
        direction: InfluenceDirection? = nil,
        importance: Double? = nil,
        confidenceRef: ConfidenceRef? = nil,
        relatedModel: RelatedModelRef? = nil,
        humanFallback: String? = nil,
        audit: EvidenceAuditMeta? = nil
    ) {
        self.id = id
        self.category = category
        self.source = source
        self.factKey = factKey
        self.value = value
        self.unit = unit
        self.direction = direction
        self.importance = importance.map { max(0, min(1, $0)) }
        self.confidenceRef = confidenceRef
        self.relatedModel = relatedModel
        self.humanFallback = humanFallback
        self.audit = audit
    }
}

