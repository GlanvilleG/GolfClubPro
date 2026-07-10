//
//  WeatherSnapshot.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum WeatherAvailability:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case live
    case cached
    case stale
    case unavailable
}

public enum WeatherDataSource:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case weatherKit
    case cachedWeatherKit
    case manual
    case unknown
}

public struct WeatherSnapshot:
    Codable,
    Equatable,
    Sendable {

    public var observedAt: Date
    public var location: GeoCoordinate

    public var wind: WindContext?
    public var windGustMetersPerSecond: Double?

    public var temperatureCelsius: Double?
    public var humidityPercent: Double?
    public var pressureHPa: Double?
    public var precipitationMillimetres: Double?

    public var availability: WeatherAvailability
    public var source: WeatherDataSource

    public init(
        observedAt: Date,
        location: GeoCoordinate,
        wind: WindContext? = nil,
        windGustMetersPerSecond: Double? = nil,
        temperatureCelsius: Double? = nil,
        humidityPercent: Double? = nil,
        pressureHPa: Double? = nil,
        precipitationMillimetres: Double? = nil,
        availability: WeatherAvailability,
        source: WeatherDataSource
    ) {
        self.observedAt = observedAt
        self.location = location
        self.wind = wind
        self.windGustMetersPerSecond =
            windGustMetersPerSecond.map { max(0, $0) }
        self.temperatureCelsius = temperatureCelsius
        self.humidityPercent =
            humidityPercent.map { min(100, max(0, $0)) }
        self.pressureHPa = pressureHPa
        self.precipitationMillimetres =
            precipitationMillimetres.map { max(0, $0) }
        self.availability = availability
        self.source = source
    }

    public func age(
        relativeTo date: Date = Date()
    ) -> TimeInterval {
        max(0, date.timeIntervalSince(observedAt))
    }

    public func classifiedAvailability(
        relativeTo date: Date = Date(),
        liveThreshold: TimeInterval = 15 * 60,
        cachedThreshold: TimeInterval = 45 * 60
    ) -> WeatherAvailability {
        let snapshotAge = age(relativeTo: date)

        if snapshotAge <= liveThreshold {
            return .live
        }

        if snapshotAge <= cachedThreshold {
            return .cached
        }

        return .stale
    }
}
