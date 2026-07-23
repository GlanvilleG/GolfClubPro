//
//  RecommendationEvidenceSnapshot.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import Foundation

/// Immutable, codable snapshot of recommendation-time evidence for explainability and audit.
/// This snapshot is presentation-neutral and contains no recomputation logic.
public struct RecommendationEvidenceSnapshot: Codable, Equatable, Sendable {
    // Schema version for forward-compatibility
    public let schemaVersion: String

    // Core decision (as produced at recommendation time)
    public let decision: RecommendationDecision

    // Selected assessments available at recommendation time (optional fields if not present)
    public let environmentalAssessment: EnvironmentalAssessment?

    // Strategic and risk context (optional placeholders if types are not exposed here)
    public let strategicOptionID: String?
    public let riskRewardSummary: [String: String]? // lightweight summary without duplicating full model

    // Spatial/hole context (lightweight summary)
    public let holeHazardSummary: [String: String]? // e.g., { "water": "high", "oob": "low" }

    // Dispersion snapshot reference (lightweight)
    public let shotDispersionSummary: [String: String]?

    // Adjustments applied
    public let adaptiveAdjustmentSummary: [String: String]?
    public let weatherAdjustmentSummary: [String: String]?

    // Candidate list summary (not re-scored here)
    public let candidates: [CandidateSummary]

    // Audit metadata
    public let snapshotID: String
    public let producedAt: Date

    public init(
        schemaVersion: String = "1",
        decision: RecommendationDecision,
        environmentalAssessment: EnvironmentalAssessment? = nil,
        strategicOptionID: String? = nil,
        riskRewardSummary: [String: String]? = nil,
        holeHazardSummary: [String: String]? = nil,
        shotDispersionSummary: [String: String]? = nil,
        adaptiveAdjustmentSummary: [String: String]? = nil,
        weatherAdjustmentSummary: [String: String]? = nil,
        candidates: [CandidateSummary] = [],
        snapshotID: String = UUID().uuidString,
        producedAt: Date = Date()
    ) {
        self.schemaVersion = schemaVersion
        self.decision = decision
        self.environmentalAssessment = environmentalAssessment
        self.strategicOptionID = strategicOptionID
        self.riskRewardSummary = riskRewardSummary
        self.holeHazardSummary = holeHazardSummary
        self.shotDispersionSummary = shotDispersionSummary
        self.adaptiveAdjustmentSummary = adaptiveAdjustmentSummary
        self.weatherAdjustmentSummary = weatherAdjustmentSummary
        self.candidates = candidates
        self.snapshotID = snapshotID
        self.producedAt = producedAt
    }

    /// Lightweight candidate summary mirroring already computed values.
    public struct CandidateSummary: Codable, Equatable, Sendable {
        public let clubID: String
        public let score: Double
        public let confidence: Double
        public init(clubID: String, score: Double, confidence: Double) {
            self.clubID = clubID
            self.score = score
            self.confidence = confidence
        }
    }
}

