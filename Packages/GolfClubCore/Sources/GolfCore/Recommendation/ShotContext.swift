//
//  ShotContext.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct WindContext: Codable, Equatable, Sendable {
    public var speedMetersPerSecond: Double
    public var directionDegrees: Double

    public init(
        speedMetersPerSecond: Double,
        directionDegrees: Double
    ) {
        self.speedMetersPerSecond = max(0, speedMetersPerSecond)
        self.directionDegrees =
            directionDegrees
                .truncatingRemainder(dividingBy: 360)
    }
}

public struct EnvironmentalContext:
    Codable,
    Equatable,
    Sendable {

    public var weatherSnapshot: WeatherSnapshot?
    public var elevationChangeMeters: Double?
   

    public init(
        weatherSnapshot: WeatherSnapshot? = nil,
        elevationChangeMeters: Double? = nil,

    ) {
        self.weatherSnapshot = weatherSnapshot
        self.elevationChangeMeters =
            elevationChangeMeters

    }

    public var wind: WindContext? {
        weatherSnapshot?.wind
    }

    public var temperatureCelsius: Double? {
        weatherSnapshot?.temperatureCelsius
    }

    public var humidityPercent: Double? {
        weatherSnapshot?.humidityPercent
    }

    public var pressureHPa: Double? {
        weatherSnapshot?.pressureHPa
    }

    public var weatherAvailability:
        WeatherAvailability {
        weatherSnapshot?.availability ??
            .unavailable
    }
    
}

public struct RecentShotSummary:
    Codable,
    Equatable,
    Sendable {

    public var clubID: ClubID
    public var averageDistanceMeters: Double?
    public var commonErrors: [ShotError]
    public var sampleSize: Int

    public init(
        clubID: ClubID,
        averageDistanceMeters: Double? = nil,
        commonErrors: [ShotError] = [],
        sampleSize: Int = 0
    ) {
        self.clubID = clubID
        self.averageDistanceMeters = averageDistanceMeters
        self.commonErrors = commonErrors
        self.sampleSize = max(0, sampleSize)
    }
}

public struct ShotContext:
    Codable,
    Equatable,
    Sendable {

    public var player: Player
    public var roundID: RoundID
    public var hole: Hole

    public var currentPosition: GeoCoordinate
    public var playableLie: PlayableLie
    public var courseArea: HoleAreaType

    public var availableClubs: [Club]
    public var recentShotHistory: [RecentShotSummary]

    public var strategyGeometry: HoleStrategyGeometry
    public var currentShotPlan: ShotPlan?

    public var environment: EnvironmentalContext
    
    public var dispersionSummaries: [ClubDispersionSummary]
    public var environmentalAssessment: EnvironmentalAssessment?

    public init(
        player: Player,
        roundID: RoundID,
        hole: Hole,
        currentPosition: GeoCoordinate,
        playableLie: PlayableLie,
        courseArea: HoleAreaType,
        availableClubs: [Club],
        recentShotHistory: [RecentShotSummary] = [],
        dispersionSummaries: [ClubDispersionSummary] = [],
        strategyGeometry: HoleStrategyGeometry,
        currentShotPlan: ShotPlan? = nil,
        environment: EnvironmentalContext =
            EnvironmentalContext(),
        environmentalAssessment: EnvironmentalAssessment? = nil
        
    ) {
        self.player = player
        self.roundID = roundID
        self.hole = hole
        self.currentPosition = currentPosition
        self.playableLie = playableLie
        self.courseArea = courseArea
        self.availableClubs = availableClubs
        self.recentShotHistory = recentShotHistory
        self.dispersionSummaries = dispersionSummaries
        self.strategyGeometry = strategyGeometry
        self.currentShotPlan = currentShotPlan
        self.environment = environment
        self.environmentalAssessment = environmentalAssessment
    }

    public var finalTarget: GeoCoordinate {
        strategyGeometry.finalTarget
    }

    public var remainingDistanceMeters: Double {
        DistanceCalculator.distanceMeters(
            from: currentPosition,
            to: finalTarget
        )
    }
}
