//
//  RecommendedNarration.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// Presentation-neutral narration output derived from structured explanation.
/// This type is immutable and contains no rendering or platform dependencies.
public struct RecommendationNarration: Codable, Hashable, Sendable, Equatable {
    /// Primary concise instruction (e.g., "Use the 7-iron.")
    public let primary: String
    /// A short supporting reason, when available.
    public let reason: String?
    /// Optional ordered secondary details for standard/detailed variants.
    public let details: [String]
    /// Optional ordered warnings (safety, strategic, data-quality) by narration priority.
    public let warnings: [String]
    /// Optional confidence/uncertainty note.
    public let confidenceNote: String?
    /// Optional concise alternatives (e.g., "Alternative: 6-iron").
    public let alternatives: [String]
    /// Metadata for auditing and reproducibility.
    public let metadata: NarrationMetadata

    public init(
        primary: String,
        reason: String? = nil,
        details: [String] = [],
        warnings: [String] = [],
        confidenceNote: String? = nil,
        alternatives: [String] = [],
        metadata: NarrationMetadata
    ) {
        self.primary = primary
        self.reason = reason
        self.details = details
        self.warnings = warnings
        self.confidenceNote = confidenceNote
        self.alternatives = alternatives
        self.metadata = metadata
    }
}

