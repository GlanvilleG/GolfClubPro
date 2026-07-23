//
//  WeatherCondition.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct WeatherCondition:
    Codable,
    Equatable,
    Sendable {


    public let windSpeedKph: Double
    
    public let windDirectionDegrees: Double


    public let temperatureCelsius: Double

    public let precipitation: Double

    public let ageSeconds: Double
    
    public let providerQuality: Double
    

    public init(
        windSpeedKph: Double,
        windDirectionDegrees: Double,
        temperatureCelsius: Double,
        precipitation: Double,
        ageSeconds: Double = 0,
        providerQuality: Double = 1
    ) {

        self.windSpeedKph = max(0, windSpeedKph)
        self.windDirectionDegrees = windDirectionDegrees
        self.temperatureCelsius = temperatureCelsius
        self.precipitation = min(1, max(0, precipitation))
        self.ageSeconds = ageSeconds
        self.providerQuality = providerQuality
    }

    public var windSpeedmps: Double {
        windSpeedKph / 3.6
    }
}

