//
//  ShotOutcomeClassification.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//

import Foundation

public enum ShotOutcome: String, Sendable, Codable, Equatable {
    case excellent
    case good
    case acceptable
    case poor
    case recovery
    case penalty
    case punchOut
    case layUp
    case approach
    case chip
    case putt
    case recoverySuccess
}

public enum ShotIntent: String, Sendable, Codable, Equatable {
    case normal
    case layUp
    case punchOut
    case approach
    case chip
    case putt
}

public struct ShotContextHint: Sendable, Codable, Equatable {
    public let isPenalty: Bool
    public let isRecovery: Bool
    public let intent: ShotIntent
    public let distanceToTargetMeters: Double?
    public let onGreen: Bool

    public init(
        isPenalty: Bool = false,
        isRecovery: Bool = false,
        intent: ShotIntent = .normal,
        distanceToTargetMeters: Double? = nil,
        onGreen: Bool = false
    ) {
        self.isPenalty = isPenalty
        self.isRecovery = isRecovery
        self.intent = intent
        self.distanceToTargetMeters = distanceToTargetMeters
        self.onGreen = onGreen
    }
}

public struct ShotOutcomeClassifier: Sendable {
    public init() {}

    /// Deterministically classifies a shot using optional context hints.
    /// The logic is conservative: it only assigns specific outcomes when clear signals are present.
    public func classify(
        carryMeters: Double,
        totalMeters: Double,
        hints: ShotContextHint = ShotContextHint()
    ) -> ShotOutcome {
        // Highest-priority explicit signals
        if hints.isPenalty { return .penalty }
        if hints.intent == .punchOut || hints.isRecovery { return .punchOut }
        if hints.intent == .layUp { return .layUp }
        if hints.onGreen || hints.intent == .putt { return .putt }
        if hints.intent == .chip { return .chip }
        if hints.intent == .approach { return .approach }

        // Basic quality heuristic using carry vs total
        // If total is very close to carry, assume minimal roll; treat extremes conservatively.
        let effective = max(carryMeters, totalMeters)
        switch effective {
        case ..<10:
            return .poor
        case 10..<40:
            return .acceptable
        case 40..<120:
            return .good
        default:
            return .excellent
        }
    }
}
