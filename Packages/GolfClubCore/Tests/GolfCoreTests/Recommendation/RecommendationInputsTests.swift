//
//  RecommendationInputsTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//
//
//  RecommendationInputsTests.swift
//  GolfClubCoreTests
//

import Testing
@testable import GolfCore

@Suite("Recommendation Inputs")
struct RecommendationInputsTests {

    @Test("Initialises with safe empty defaults")
    func initialisesWithDefaults() {

        let inputs =
            RecommendationInputs()

        #expect(
            inputs.candidateLandingZones.isEmpty
        )

        #expect(
            inputs.playerPerformance == nil
        )

        #expect(
            inputs.weatherCondition == nil
        )
    }

    @Test("Stores candidate landing zones")
    func storesCandidateLandingZones() {

        let landingZone =
            LandingZoneEvaluation(
                location:
                    GeoCoordinate(
                        latitude:
                            -39.9290,
                        longitude:
                            175.0510
                    ),
                lieQuality:
                    .fairway,
                hazardExposure:
                    0.2,
                nextShotDistance:
                    120,
                scoreExpectation:
                    2.5
            )

        let inputs =
            RecommendationInputs(
                candidateLandingZones: [
                    landingZone
                ]
            )

        #expect(
            inputs.candidateLandingZones == [
                landingZone
            ]
        )
    }
}
