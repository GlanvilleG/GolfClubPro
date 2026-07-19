//
//  HoleAreaAssessmentEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Testing
@testable import GolfCore

@Suite
struct HoleAreaAssessmentEngineTests {
    
    @Test
    func targetInsideBunkerProducesMaterialRisk() throws {
        
        let target =
        GeoCoordinate(
            latitude: -39.9300,
            longitude: 175.0500
        )
        
        let bunker =
        squareArea(
            type: .bunker,
            centre: target,
            halfSizeDegrees: 0.0001
        )
        
        let dispersion =
        ShotDispersionModel(
            target: target,
            lateralSigmaMeters: 8,
            longitudinalSigmaMeters: 10,
            lateralBiasMeters: 0,
            longitudinalBiasMeters: 0,
            confidence: 0.8
        )
        
        let result =
        HoleAreaAssessmentEngine()
            .assess(
                areas: [bunker],
                shotDispersion: dispersion,
                shotBearingDegrees: 0
            )
        
        let assessment =
        try #require(
            result.areas.first
        )
        
        #expect(
            assessment.probability > 0.25
        )
        
        #expect(
            assessment.risk >= .moderate
        )
        
        #expect(
            result.overallRisk >= .moderate
        )
    }
    
    @Test
    func distantAreaIsRemovedByBoundingBoxFilter() {
        
        let target =
        GeoCoordinate(
            latitude: -39.9300,
            longitude: 175.0500
        )
        
        let distantWater =
        squareArea(
            type: .water,
            centre:
                GeoCoordinate(
                    latitude: -39.9400,
                    longitude: 175.0600
                ),
            halfSizeDegrees: 0.0001
        )
        
        let dispersion =
        ShotDispersionModel(
            target: target,
            lateralSigmaMeters: 8,
            longitudinalSigmaMeters: 10,
            lateralBiasMeters: 0,
            longitudinalBiasMeters: 0,
            confidence: 0.8
        )
        
        let result =
        HoleAreaAssessmentEngine()
            .assess(
                areas: [distantWater],
                shotDispersion: dispersion,
                shotBearingDegrees: 0
            )
        
        #expect(
            result.areas.isEmpty
        )
        
        #expect(
            result.overallRisk ==
                .negligible
        )
    }
}

    private func squareArea(
        type: HoleAreaType,
        centre: GeoCoordinate,
        halfSizeDegrees: Double
    ) -> HoleArea {

        HoleArea(
            type: type,
            boundary: [
                GeoCoordinate(
                    latitude:
                        centre.latitude -
                        halfSizeDegrees,
                    longitude:
                        centre.longitude -
                        halfSizeDegrees
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude -
                        halfSizeDegrees,
                    longitude:
                        centre.longitude +
                        halfSizeDegrees
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude +
                        halfSizeDegrees,
                    longitude:
                        centre.longitude +
                        halfSizeDegrees
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude +
                        halfSizeDegrees,
                    longitude:
                        centre.longitude -
                        halfSizeDegrees
                )
            ]
        )
    }

