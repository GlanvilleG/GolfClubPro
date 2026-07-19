//
//  DispersionEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Testing

@testable import GolfCore

@Suite("Dispersion Engine")
struct DispersionEngineTests {

    @Test
    func defaultProfileUsedWhenNoPerformanceExists() {

        let engine = DispersionEngine()

        let result = engine.calculate(
            target: GeoCoordinate(
                latitude: -39.93,
                longitude: 175.05
            ),
            clubID: ClubID(),
            performance: nil
        )

        #expect(result.confidence == 0)
        #expect(result.lateralSigmaMeters == 15)
        #expect(result.longitudinalSigmaMeters == 12)
    }

    @Test
    func playerProfileOverridesDefaults() {

        let clubID = ClubID()

        let profile = ShotDispersionProfile(
            clubID: clubID,
            sampleCount: 20,
            averageCarryMeters: 165,
            lateralBiasMeters: 4,
            distanceStandardDeviationMeters: 7,
            lateralStandardDeviationMeters: 9,
            confidence: 0.82,
            distanceBiasMeters: -3
        )

        let performance = PlayerPerformanceModel(
            playerID: PlayerID(),
            dispersionProfiles: [profile]
        )

        let engine = DispersionEngine()

        let result = engine.calculate(
            target: GeoCoordinate(
                latitude: -39.93,
                longitude: 175.05
            ),
            clubID: clubID,
            performance: performance
        )

        #expect(result.lateralSigmaMeters == 9)
        #expect(result.longitudinalSigmaMeters == 7)
        #expect(result.lateralBiasMeters == 4)
        #expect(result.longitudinalBiasMeters == -3)
        #expect(result.confidence == 0.82)
    }
}
