//
//  DispersionEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct DispersionEngine: Sendable {

    private let defaults =
        DefaultDispersionProfileProvider()

    public init() {}

    public func calculate(
        target: GeoCoordinate,
        clubID: ClubID,
        performance: PlayerPerformanceModel?
    ) -> ShotDispersionModel {

        let profile: ShotDispersionProfile

        if let playerProfile =
            performance?.dispersionProfile(for: clubID),
           playerProfile.hasSufficientData {

            profile = playerProfile

        } else {

            profile = defaults.profile(for: clubID)
        }

        return ShotDispersionModel(
            target: target,
            lateralSigmaMeters:
                profile.lateralStandardDeviationMeters,
            longitudinalSigmaMeters:
                profile.distanceStandardDeviationMeters,
            lateralBiasMeters:
                profile.lateralBiasMeters,
            longitudinalBiasMeters:
                profile.distanceBiasMeters,
            confidence:
                profile.confidence
        )
    }
    @usableFromInline
    func calculate(
        target: GeoCoordinate,
        clubID: ClubID,
        intelligence: PlayerIntelligence?
    ) -> ShotDispersionModel {
        // If intelligence is available, attempt to reconstruct a ShotDispersionProfile-like view.
        if let intelligence,
           let clubProfile = intelligence.clubs[clubID] {
            // Map ClubPerformanceProfile into a ShotDispersionModel using available fields.
            // We don’t have raw sigma/bias values here; we provide a conservative model based on typical miss direction and confidence.
            let lateralBiasMeters: Double
            switch clubProfile.typicalMissDirection {
            case .left: lateralBiasMeters = -3
            case .right: lateralBiasMeters = 3
            case .centred, .insufficientData: lateralBiasMeters = 0
            }

            // Use conservative defaults for sigmas when not provided by a canonical ShotDispersionProfile
            let lateralSigma = 8.0
            let longitudinalSigma = 12.0

            return ShotDispersionModel(
                target: target,
                lateralSigmaMeters: lateralSigma,
                longitudinalSigmaMeters: longitudinalSigma,
                lateralBiasMeters: lateralBiasMeters,
                longitudinalBiasMeters: 0,
                confidence: clubProfile.dispersionConfidence
            )
        }

        // Fallback to existing behavior (PlayerPerformanceModel/defaults)
        return calculate(target: target, clubID: clubID, performance: nil)
    }
}
