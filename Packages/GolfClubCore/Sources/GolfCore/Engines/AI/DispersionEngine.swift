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
}
