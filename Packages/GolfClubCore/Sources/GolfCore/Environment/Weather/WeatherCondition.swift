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


    public let windSpeedKph:
        Double


    public let windDirectionDegrees:
        Double


    public let temperatureCelsius:
        Double


    public let precipitation:
        Double


    public init(
        windSpeedKph:
            Double,
        windDirectionDegrees:
            Double,
        temperatureCelsius:
            Double,
        precipitation:
            Double
    ) {

        self.windSpeedKph =
            max(
                0,
                windSpeedKph
            )

        self.windDirectionDegrees =
            windDirectionDegrees

        self.temperatureCelsius =
            temperatureCelsius

        self.precipitation =
            min(
                1,
                max(
                    0,
                    precipitation
                )
            )
    }
}
