//
//  AdaptiveTargetAdjustment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct AdaptiveTargetAdjustment:
    Codable,
    Equatable,
    Sendable {

    public let originalTarget:
        GeoCoordinate

    public let adjustedTarget:
        GeoCoordinate

    public let adjustmentMeters:
        Double

    public let reason:
        String

    public let confidence:
        Double


    public init(
        originalTarget:
            GeoCoordinate,
        adjustedTarget:
            GeoCoordinate,
        adjustmentMeters:
            Double,
        reason:
            String,
        confidence:
            Double
    ) {

        self.originalTarget =
            originalTarget

        self.adjustedTarget =
            adjustedTarget

        self.adjustmentMeters =
            adjustmentMeters

        self.reason =
            reason

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
