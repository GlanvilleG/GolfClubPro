//
//  WeatherAdjustment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation


public struct WeatherAdjustment:
    Codable,
    Equatable,
    Sendable {


    public let distanceAdjustmentMeters:
        Double


    public let lateralAdjustmentMeters:
        Double


    public let explanation:
        String


    public let confidence:
        Double


    public init(
        distanceAdjustmentMeters:
            Double,
        lateralAdjustmentMeters:
            Double,
        explanation:
            String,
        confidence:
            Double
    ) {

        self.distanceAdjustmentMeters =
            distanceAdjustmentMeters

        self.lateralAdjustmentMeters =
            lateralAdjustmentMeters

        self.explanation =
            explanation

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )
    }
}
