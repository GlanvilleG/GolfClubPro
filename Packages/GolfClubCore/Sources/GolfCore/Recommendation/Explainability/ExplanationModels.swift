//
//  ExplanationModels.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//

import Foundation

// MARK: - Explainability core enums and value types (Stage 1)

/// High-level categories for grouping explanation evidence.
public enum ExplanationCategory: String, Codable, CaseIterable, Sendable {
    case primaryClub
    case aimRoute
    case riskHazard
    case environment
    case playerPerformance
    case confidence
    case alternatives
    case warnings
}

/// Source systems from which deterministic evidence is drawn.
public enum ExplanationSource: String, Codable, CaseIterable, Sendable {
    case recommendationDecision
    case strategicOption
    case riskReward
    case spatialAssessment
    case environmentalAssessment
    case playerIntelligence
    case scoringEngine
    case audit
}

/// Direction of influence for a given fact (when applicable).
public enum InfluenceDirection: String, Codable, CaseIterable, Sendable {
    case increased
    case decreased
    case neutral
    case unknown
}

/// Identifier for evidence items used to de-duplicate and reference items deterministically.
public struct ExplanationEvidenceID: Hashable, Codable, Sendable, Equatable {
    public let rawValue: String
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Structured value container for evidence facts.
/// Prefer numeric and boolean forms with optional units; string is a fallback for legacy reasons.
public enum ExplanationValue: Codable, Equatable, Sendable {
    case number(Double)
    case integer(Int)
    case boolean(Bool)
    case text(String)
    case quantity(value: Double, unit: String)

    private enum CodingKeys: String, CodingKey { case kind, number, integer, boolean, text, value, unit }
    private enum Kind: String, Codable { case number, integer, boolean, text, quantity }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .number:
            self = .number(try container.decode(Double.self, forKey: .number))
        case .integer:
            self = .integer(try container.decode(Int.self, forKey: .integer))
        case .boolean:
            self = .boolean(try container.decode(Bool.self, forKey: .boolean))
        case .text:
            self = .text(try container.decode(String.self, forKey: .text))
        case .quantity:
            let v = try container.decode(Double.self, forKey: .value)
            let u = try container.decode(String.self, forKey: .unit)
            self = .quantity(value: v, unit: u)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .number(let n):
            try container.encode(Kind.number, forKey: .kind)
            try container.encode(n, forKey: .number)
        case .integer(let i):
            try container.encode(Kind.integer, forKey: .kind)
            try container.encode(i, forKey: .integer)
        case .boolean(let b):
            try container.encode(Kind.boolean, forKey: .kind)
            try container.encode(b, forKey: .boolean)
        case .text(let s):
            try container.encode(Kind.text, forKey: .kind)
            try container.encode(s, forKey: .text)
        case .quantity(let v, let u):
            try container.encode(Kind.quantity, forKey: .kind)
            try container.encode(v, forKey: .value)
            try container.encode(u, forKey: .unit)
        }
    }
}
