//
//  StrategicOptionEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//
//
//  StrategicOptionEngineTests.swift
//  GolfCoreTests
//

import Testing
@testable import GolfCore

@Suite("Strategic Option Engine")
struct StrategicOptionEngineTests {

    // MARK: - Helpers

    private func makeClub(
        name: String,
        carry: Double
    ) -> Club {

        Club(
            name: name,
            type: .iron,
            averageCarryMeters: carry
        )
    }

   private func makeShotContext(
        clubs: [Club]
    ) -> ShotContext {

        ShotContext(
            player: Player.mock,
            roundID: RoundID(),
            hole: Hole.mock,
            currentPosition: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            playableLie: .fairway,
            courseArea: .fairway,
            availableClubs: clubs,
            strategyGeometry: HoleStrategyGeometry.mock
        )
    }

    private func landingZone(
        latitude: Double,
        longitude: Double,
        score: Double
    ) -> LandingZoneEvaluation {

        LandingZoneEvaluation(
            location: GeoCoordinate(
                latitude: latitude,
                longitude: longitude
            ),
            lieQuality: .fairway,
            hazardExposure: 0.2,
            nextShotDistance: 120,
            scoreExpectation: score
        )
    }

    // MARK: - Tests

    @Test("Throws when no clubs are available")
    func throwsWhenNoClubsAvailable() {

        let engine = StrategicOptionEngine()

        let context = makeShotContext(
            clubs: []
        )

        #expect(
            throws: StrategicOptionEngineError.noAvailableClubs
        ) {
            try engine.determineBestOption(
                from: context,
                candidateLandingZones: [
                    landingZone(
                        latitude: -39.929,
                        longitude: 175.051,
                        score: 2.0
                    )
                ]
            )
        }
    }

    @Test("Throws when no landing zones supplied")
    func throwsWhenNoLandingZones() {

        let engine = StrategicOptionEngine()

        let context = makeShotContext(
            clubs: [
                makeClub(
                    name: "7 Iron",
                    carry: 150
                )
            ]
        )

        #expect(
            throws: StrategicOptionEngineError.noCandidateLandingZones
        ) {
            try engine.determineBestOption(
                from: context,
                candidateLandingZones: []
            )
        }
    }

    @Test("Returns a strategic option")
    func returnsStrategicOption() throws {

        let engine = StrategicOptionEngine()

        let club = makeClub(
            name: "7 Iron",
            carry: 150
        )

        let context = makeShotContext(
            clubs: [club]
        )

        let option = try engine.determineBestOption(
            from: context,
            candidateLandingZones: [
                landingZone(
                    latitude: -39.929,
                    longitude: 175.051,
                    score: 2.0
                )
            ]
        )

        #expect(option.clubID == club.id)
    }

    @Test("Chooses lowest ranked option")
    func choosesLowestRankedOption() throws {

        let engine = StrategicOptionEngine()

        let context = makeShotContext(
            clubs: [
                makeClub(
                    name: "6 Iron",
                    carry: 165
                )
            ]
        )

        let safer = landingZone(
            latitude: -39.929,
            longitude: 175.051,
            score: 1.5
        )

        let risky = landingZone(
            latitude: -39.928,
            longitude: 175.052,
            score: 3.0
        )

        let option = try engine.determineBestOption(
            from: context,
            candidateLandingZones: [
                risky,
                safer
            ]
        )

        #expect(option.landingZone == safer)
    }

    @Test("Selects club closest to required carry")
    func selectsClosestClub() throws {

        let engine = StrategicOptionEngine()

        let shortClub = makeClub(
            name: "8 Iron",
            carry: 140
        )

        let idealClub = makeClub(
            name: "7 Iron",
            carry: 155
        )

        let longClub = makeClub(
            name: "6 Iron",
            carry: 170
        )

        let context = makeShotContext(
            clubs: [
                shortClub,
                idealClub,
                longClub
            ]
        )

        let option = try engine.determineBestOption(
            from: context,
            candidateLandingZones: [
                landingZone(
                    latitude: -39.92895,
                    longitude: 175.05120,
                    score: 2.0
                )
            ]
        )

        #expect(option.clubID == idealClub.id)
    }
}
