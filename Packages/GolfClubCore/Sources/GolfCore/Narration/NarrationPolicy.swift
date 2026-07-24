//
//  NarrationPolicy.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// Deterministic measurement/formatting policy independent of UI frameworks.
public struct MeasurementPolicy: Codable, Hashable, Sendable, Equatable {
    /// Supported distance systems.
    public enum DistanceSystem: String, Codable, CaseIterable, Sendable { case metric, imperial }

    /// The distance system to use for distances if/when applicable.
    public let distanceSystem: DistanceSystem
    /// Number of fraction digits for degrees.
    public let degreeFractionDigits: Int
    /// Suppress aim output when the absolute offset is below or equal to this threshold in degrees.
    public let aimZeroSuppressionThresholdDegrees: Double

    public init(
        distanceSystem: DistanceSystem = .metric,
        degreeFractionDigits: Int = 0,
        aimZeroSuppressionThresholdDegrees: Double = 0.0
    ) {
        self.distanceSystem = distanceSystem
        self.degreeFractionDigits = degreeFractionDigits
        self.aimZeroSuppressionThresholdDegrees = aimZeroSuppressionThresholdDegrees
    }
}

/// Deterministic mapping from numeric confidence to qualitative wording selection.
public struct ConfidenceWordingPolicy: Codable, Hashable, Sendable, Equatable {
    /// Thresholds for qualitative mapping. Values must satisfy: 0 <= low < moderate < high <= 1
    public let lowThreshold: Double
    public let moderateThreshold: Double
    public let highThreshold: Double
    /// Whether to surface confidence wording in concise variant when below thresholds.
    public let showInConciseWhenBelowModerate: Bool

    public init(
        lowThreshold: Double = 0.33,
        moderateThreshold: Double = 0.5,
        highThreshold: Double = 0.75,
        showInConciseWhenBelowModerate: Bool = true
    ) {
        self.lowThreshold = lowThreshold
        self.moderateThreshold = moderateThreshold
        self.highThreshold = highThreshold
        self.showInConciseWhenBelowModerate = showInConciseWhenBelowModerate
    }
}

/// Composite narration policy used by the Narration Engine.
public struct NarrationPolicy: Codable, Hashable, Sendable, Equatable {
    public let measurement: MeasurementPolicy
    public let confidence: ConfidenceWordingPolicy
    /// Optional identifier to embed in metadata for auditing.
    public let identifier: String?

    public init(
        measurement: MeasurementPolicy = MeasurementPolicy(),
        confidence: ConfidenceWordingPolicy = ConfidenceWordingPolicy(),
        identifier: String? = nil
    ) {
        self.measurement = measurement
        self.confidence = confidence
        self.identifier = identifier
    }
}

