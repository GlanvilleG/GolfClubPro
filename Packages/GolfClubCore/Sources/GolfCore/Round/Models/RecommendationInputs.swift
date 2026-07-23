//
//  RecommendationInputs.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//

import Foundation

/// Immutable snapshot of transient data required by the
/// recommendation pipeline.
///
/// Persistent round and shot state remains authoritative in
/// `RoundContext` and `ShotContext`.
public struct RecommendationInputs:
    Codable,
    Equatable,
    Sendable {

    /// Landing zones available for strategic evaluation.
    public let candidateLandingZones:
        [LandingZoneEvaluation]

    /// Course areas relevant to the current hole and shot.
    public let holeAreas:
        [HoleArea]

    /// Learned player-performance information used for
    /// adaptive target adjustment.
    public let playerPerformance:
        PlayerPerformanceModel?

    /// Current weather information used for carry and
    /// directional adjustment.
    public let weatherCondition:
        WeatherCondition?
    
    /// Estimated GPS horizontal accuracy in meters (lower is better).
       public let gpsAccuracyMeters: Double?

    public init(
        candidateLandingZones:
            [LandingZoneEvaluation] = [],
        holeAreas:
            [HoleArea] = [],
        playerPerformance:
            PlayerPerformanceModel? = nil,
        weatherCondition:
            WeatherCondition? = nil,
        gpsAccuracyMeters: Double? = nil
    ) {
        self.candidateLandingZones =
            candidateLandingZones

        self.holeAreas =
            holeAreas

        self.playerPerformance =
            playerPerformance

        self.weatherCondition =
            weatherCondition
        
        self.gpsAccuracyMeters =
            gpsAccuracyMeters
    }
}
