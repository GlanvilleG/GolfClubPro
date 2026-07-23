//
//  PlayerIntelligence.swift
//  GolfClubCore
//
//  Created by Dragon Development on 22/07/2026.
//
import Foundation
public enum TrendScope: String, Codable, Sendable, Equatable {
    case overallConsistency
    case dispersion
    case distance
    case clubConfidence
    case recentForm
}

public enum TrendDirection: String, Codable, Sendable, Equatable {
    case improving
    case declining
    case stable
}

public struct PerformanceTrend: Sendable, Equatable, Codable {
    public let scope: TrendScope
    public let direction: TrendDirection
    public let magnitude: Double
    public let confidence: Double
    public let windowDescription: String

    public init(
        scope: TrendScope,
        direction: TrendDirection,
        magnitude: Double,
        confidence: Double,
        windowDescription: String
    ) {
        self.scope = scope
        self.direction = direction
        self.magnitude = magnitude
        self.confidence = confidence
        self.windowDescription = windowDescription
    }
}

public struct PlayerIntelligence: Sendable {
    public init(
        playerID: PlayerID,
        generatedAt: Date,
        overall: PlayerPerformanceProfile,
        clubs: [ClubID: ClubPerformanceProfile],
        trends: [PerformanceTrend],
        confidence: ConfidenceProfile,
        notes: [String] = []
    ) {
        self.playerID = playerID
        self.generatedAt = generatedAt
        self.overall = overall
        self.clubs = clubs
        self.trends = trends
        self.confidence = confidence
        self.notes = notes
    }

    public let playerID: PlayerID
    public let generatedAt: Date
    public let overall: PlayerPerformanceProfile
    public let clubs: [ClubID: ClubPerformanceProfile]
    public let trends: [PerformanceTrend]
    public let confidence: ConfidenceProfile
    public let notes: [String]
}
