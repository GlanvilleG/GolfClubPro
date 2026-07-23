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
    
    
    @usableFromInline
    func adjustTarget(
        plannedTarget: GeoCoordinate,
        bearingDegrees: Double,
        clubID: ClubID,
        intelligence: PlayerIntelligence?
    ) -> AdaptiveTargetAdjustment {
        guard let intelligence,
              let clubProfile = intelligence.clubs[clubID] else {
            // Fallback to no adjustment when intelligence unavailable
            return AdaptiveTargetAdjustment(
                originalTarget: plannedTarget,
                adjustedTarget: plannedTarget,
                adjustmentMeters: 0,
                reason: "No player intelligence available for target adjustment.",
                confidence: 0
            )
        }

        // Derive lateral bias from typical miss direction (coarse mapping)
        let lateralBias: Double
        switch clubProfile.typicalMissDirection {
        case .left:
            lateralBias = -3 // meters (coarse default)
        case .right:
            lateralBias = 3
        case .centred:
            lateralBias = 0
        case .insufficientData:
            return AdaptiveTargetAdjustment(
                originalTarget: plannedTarget,
                adjustedTarget: plannedTarget,
                adjustmentMeters: 0,
                reason: "Insufficient performance data for target adjustment.",
                confidence: 0
            )
        }

        // Confidence sourced from dispersionConfidence (bounded already)
        let confidence = clubProfile.dispersionConfidence

        if abs(lateralBias) < 1 || confidence < 0.5 {
            return AdaptiveTargetAdjustment(
                originalTarget: plannedTarget,
                adjustedTarget: plannedTarget,
                adjustmentMeters: 0,
                reason: "Insufficient performance data for target adjustment.",
                confidence: 0
            )
        }

        let adjustment = -lateralBias

        return AdaptiveTargetAdjustment(
            originalTarget: plannedTarget,
            adjustedTarget: TargetOffsetCalculator.offset(
                target: plannedTarget,
                bearingDegrees: bearingDegrees,
                offsetMeters: adjustment
            ),
            adjustmentMeters: adjustment,
            reason: "Target adjusted using player intelligence (club miss tendency).",
            confidence: confidence
        )
    }
}
