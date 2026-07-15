//
//  RecommendationExplanation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public enum ExplanationSeverity:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case information
    case advisory
    case caution
}

public struct ExplanationItem:
    Codable,
    Equatable,
    Sendable {

    public let title:
        String

    public let detail:
        String?

    public let severity:
        ExplanationSeverity

    public init(
        title: String,
        detail: String? = nil,
        severity:
            ExplanationSeverity =
                .information
    ) {
        self.title =
            title

        self.detail =
            detail

        self.severity =
            severity
    }
}

public struct RecommendationExplanation:
    Codable,
    Equatable,
    Sendable {

    public let summary:
        String

    public let primaryReasons:
        [ExplanationItem]

    public let environmentalConditions:
        [ExplanationItem]

    public let warnings:
        [ExplanationItem]

    public let confidenceStatement:
        String?

    public let courseManagementAdvice:
        String?

    public let nextShotFocus:
        String?

    public init(
        summary: String,
        primaryReasons:
            [ExplanationItem] = [],
        environmentalConditions:
            [ExplanationItem] = [],
        warnings:
            [ExplanationItem] = [],
        confidenceStatement:
            String? = nil,
        courseManagementAdvice:
            String? = nil,
        nextShotFocus:
            String? = nil
    ) {
        self.summary =
            summary

        self.primaryReasons =
            primaryReasons

        self.environmentalConditions =
            environmentalConditions

        self.warnings =
            warnings

        self.confidenceStatement =
            confidenceStatement

        self.courseManagementAdvice =
            courseManagementAdvice

        self.nextShotFocus =
            nextShotFocus
    }
}
