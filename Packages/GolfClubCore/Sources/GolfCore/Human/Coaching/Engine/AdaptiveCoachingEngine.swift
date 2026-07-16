//
//  AdaptiveCoachingEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct AdaptiveCoachingEngine:
    Sendable {


    public init() {}


    public func adjustTarget(
        plannedTarget:
            GeoCoordinate,
        bearingDegrees:
            Double,
        clubID:
            ClubID,
        performance:
            PlayerPerformanceModel
    ) -> AdaptiveTargetAdjustment {


        guard let profile =
                performance
                    .dispersionProfile(
                        for:
                            clubID
                    ),

              profile.confidence >= 0.5,

              abs(
                profile.lateralBiasMeters
              ) > 3

        else {

            return AdaptiveTargetAdjustment(
                originalTarget:
                    plannedTarget,
                adjustedTarget:
                    plannedTarget,
                adjustmentMeters:
                    0,
                reason:
                    "Insufficient performance data for target adjustment.",
                confidence:
                    0
            )
        }


        let adjustment =
            -profile.lateralBiasMeters


        return AdaptiveTargetAdjustment(
            originalTarget:
                plannedTarget,
            adjustedTarget:
                TargetOffsetCalculator.offset(
                    target:
                        plannedTarget,
                    bearingDegrees:
                        bearingDegrees,
                    offsetMeters:
                        adjustment
                ),
            adjustmentMeters:
                adjustment,
            reason:
                "Target adjusted using learned club dispersion.",
            confidence:
                profile.confidence
        )
    }
}
