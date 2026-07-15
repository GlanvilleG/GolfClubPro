//
//  RecommendationResult.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct RecommendationResult:
    Codable,
    Equatable,
    Sendable {

    public let decision:
        RecommendationDecision

    public let explanation:
        RecommendationExplanation

    public let auditRecord:
        RecommendationAuditRecord?

    public init(
        decision:
            RecommendationDecision,
        explanation:
            RecommendationExplanation,
        auditRecord:
            RecommendationAuditRecord? = nil
    ) {
        self.decision =
            decision

        self.explanation =
            explanation

        self.auditRecord =
            auditRecord
    }
}
