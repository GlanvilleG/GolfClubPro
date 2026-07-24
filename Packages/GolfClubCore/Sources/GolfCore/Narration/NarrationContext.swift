//
//  NarrationContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
///
///Note : - quatability/hashability rely on sorted-key JSON encoding and that both RecommendationExplanation and NarrationPolicy are expected to remain Codable-stable. 


import Foundation

/// Immutable input context for the Narration Engine.
/// Contains only explanation and deterministic policy/configuration required for narration.
public struct NarrationContext: Codable, Hashable, Sendable {
    /// The authoritative structured explanation from which narration is derived.
    public let explanation: RecommendationExplanation
    /// Deterministic narration policy controlling measurement and confidence wording.
    public let policy: NarrationPolicy
    /// Optional mapping from club identifier strings to display names (e.g., "7-iron").
    /// This allows human-readable club wording without querying equipment services.
    public let clubDisplayNames: [String: String]

    public init(
        explanation: RecommendationExplanation,
        policy: NarrationPolicy = NarrationPolicy(),
        clubDisplayNames: [String: String] = [:]
    ) {
        self.explanation = explanation
        self.policy = policy
        self.clubDisplayNames = clubDisplayNames
    }
}

extension NarrationContext {
    private static func stableEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        } else {
            encoder.outputFormatting = []
        }
        return encoder
    }
}

extension NarrationContext: Equatable {
    public static func == (lhs: NarrationContext, rhs: NarrationContext) -> Bool {
        // Fast path: compare the trivially equatable/hashable dictionary first
        guard lhs.clubDisplayNames == rhs.clubDisplayNames else { return false }
        // Compare encoded forms of codable members to avoid requiring them to be Hashable
        let encoder = stableEncoder()
        let leftExp = try? encoder.encode(lhs.explanation)
        let rightExp = try? encoder.encode(rhs.explanation)
        guard leftExp == rightExp else { return false }
        let leftPolicy = try? encoder.encode(lhs.policy)
        let rightPolicy = try? encoder.encode(rhs.policy)
        return leftPolicy == rightPolicy
    }
}

extension NarrationContext {
    public func hash(into hasher: inout Hasher) {
        // Hash a stable encoding of codable members plus the dictionary
        let encoder = Self.stableEncoder()
        if let expData = try? encoder.encode(explanation) {
            hasher.combine(expData)
        } else {
            // Fallback to type name to maintain some entropy if encoding fails
            hasher.combine("explanation_encoding_failed")
        }
        if let policyData = try? encoder.encode(policy) {
            hasher.combine(policyData)
        } else {
            hasher.combine("policy_encoding_failed")
        }
        hasher.combine(clubDisplayNames)
    }
}

