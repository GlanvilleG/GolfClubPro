//
//  DefaultDispersionProfileProvider.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//

import Foundation

public struct DefaultDispersionProfileProvider: Sendable {

    public init() {}

    public func profile(
        for clubID: ClubID
    ) -> ShotDispersionProfile {

        ShotDispersionProfile(
            clubID: clubID,
            sampleCount: 0,
            averageCarryMeters: 0,
            lateralBiasMeters: 0,
            distanceStandardDeviationMeters: 12,
            lateralStandardDeviationMeters: 15,
            shotShape: .straight,
            confidence: 0,
            distanceBiasMeters: 0
        )
    }
}
