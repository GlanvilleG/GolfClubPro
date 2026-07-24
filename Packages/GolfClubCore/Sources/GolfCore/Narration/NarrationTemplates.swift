//
//  NarrationTemplates.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// Stable identifiers for template tokens used during narration composition.
public enum NarrationToken: String, Sendable, Codable, CaseIterable {
    case clubName          // e.g., "7-iron"
    case aimDegrees        // numeric string already formatted per policy (e.g., "5°")
    case aimDirection      // "left" | "right" | "at target"
    case routeStrategy     // e.g., "lay up", "recovery", "aggressive", "conservative"
    case riskPrimary       // concise risk wording
    case environmentPrimary// concise environmental factor wording
    case performancePrimary// concise player-performance wording
    case confidenceShort   // concise confidence wording
    case alternativeClub   // e.g., "6-iron"
}

/// Template role defines where a template is intended to be used in the narration output.
public enum TemplateRole: String, Sendable, Codable, CaseIterable {
    case primary
    case reason
    case detail
    case warning
    case confidence
    case alternative
}

/// A single narration template consisting of a localization key and ordered token placeholders.
public struct NarrationTemplate: Sendable, Hashable, Codable, Equatable {
    /// A stable localization key (English fallback provided by the engine later).
    public let key: String
    /// Ordered tokens required by this template. Missing tokens must be handled deterministically by the engine.
    public let tokens: [NarrationToken]
    /// The role this template serves in the final narration output.
    public let role: TemplateRole

    public init(key: String, tokens: [NarrationToken], role: TemplateRole) {
        self.key = key
        self.tokens = tokens
        self.role = role
    }
}

/// A catalog of narration templates organized by conceptual category.
public struct NarrationTemplates: Sendable, Hashable, Codable, Equatable {
    /// Monotonically increasing template set version used in metadata and audit.
    public static let version: String = "narration-templates.v1"

    /// Primary instruction templates.
    public let primaryClub: NarrationTemplate
    public let primaryAim: NarrationTemplate

    /// Supporting reason templates (environment, performance, route).
    public let reasonEnvironment: NarrationTemplate
    public let reasonPerformance: NarrationTemplate
    public let reasonRoute: NarrationTemplate

    /// Warning and confidence templates.
    public let warningPrimary: NarrationTemplate
    public let confidenceShort: NarrationTemplate

    /// Alternative suggestion template.
    public let alternativeClub: NarrationTemplate

    public init(primaryClub: NarrationTemplate,
                primaryAim: NarrationTemplate,
                reasonEnvironment: NarrationTemplate,
                reasonPerformance: NarrationTemplate,
                reasonRoute: NarrationTemplate,
                warningPrimary: NarrationTemplate,
                confidenceShort: NarrationTemplate,
                alternativeClub: NarrationTemplate) {
        self.primaryClub = primaryClub
        self.primaryAim = primaryAim
        self.reasonEnvironment = reasonEnvironment
        self.reasonPerformance = reasonPerformance
        self.reasonRoute = reasonRoute
        self.warningPrimary = warningPrimary
        self.confidenceShort = confidenceShort
        self.alternativeClub = alternativeClub
    }
}

public extension NarrationTemplates {
    /// Default English template catalog. The engine will provide English fallback strings for these keys.
    static let `default` = NarrationTemplates(
        primaryClub: NarrationTemplate(
            key: "narration.primary.club",
            tokens: [.clubName],
            role: .primary
        ),
        primaryAim: NarrationTemplate(
            key: "narration.primary.aim",
            tokens: [.aimDegrees, .aimDirection],
            role: .primary
        ),
        reasonEnvironment: NarrationTemplate(
            key: "narration.reason.environment.primary",
            tokens: [.environmentPrimary],
            role: .reason
        ),
        reasonPerformance: NarrationTemplate(
            key: "narration.reason.performance.primary",
            tokens: [.performancePrimary],
            role: .reason
        ),
        reasonRoute: NarrationTemplate(
            key: "narration.reason.route",
            tokens: [.routeStrategy],
            role: .reason
        ),
        warningPrimary: NarrationTemplate(
            key: "narration.warning.primary",
            tokens: [.riskPrimary],
            role: .warning
        ),
        confidenceShort: NarrationTemplate(
            key: "narration.confidence.short",
            tokens: [.confidenceShort],
            role: .confidence
        ),
        alternativeClub: NarrationTemplate(
            key: "narration.alternative.club",
            tokens: [.alternativeClub],
            role: .alternative
        )
    )
}

