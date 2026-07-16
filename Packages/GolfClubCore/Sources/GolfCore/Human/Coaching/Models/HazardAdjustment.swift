//
//  HazardAdjustment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct HazardAdjustment:
    Codable,
    Equatable,
    Sendable {

    public let additionalAdjustmentMeters:
        Double

    public let hazard:
        HazardZone

    public let reason:
        String

    public let confidence:
        Double


    public init(
        additionalAdjustmentMeters:
            Double,
        hazard:
            HazardZone,
        reason:
            String,
        confidence:
            Double
    ) {

        self.additionalAdjustmentMeters =
            additionalAdjustmentMeters

        self.hazard =
            hazard

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
