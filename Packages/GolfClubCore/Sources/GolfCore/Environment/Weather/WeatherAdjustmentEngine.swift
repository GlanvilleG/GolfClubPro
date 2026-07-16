//
//  WeatherAdjustmentEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct WeatherAdjustmentEngine:
    Sendable {


    public init() {}



    public func calculate(
        clubDistanceMeters:
            Double,
        shotBearingDegrees:
            Double,
        weather:
            WeatherCondition
    ) -> WeatherAdjustment {


        let windFactor =
            weather.windSpeedKph / 10


        let headwind =
            abs(
                weather.windDirectionDegrees -
                shotBearingDegrees
            )
            < 45


        let distanceAdjustment =
            headwind
            ?
            -(windFactor * 3)
            :
            (windFactor * 2)


        return WeatherAdjustment(
            distanceAdjustmentMeters:
                distanceAdjustment,
            lateralAdjustmentMeters:
                0,
            explanation:
                headwind
                ?
                "Headwind reducing expected carry."
                :
                "Wind assisting expected carry.",
            confidence:
                0.7
        )
    }
}
