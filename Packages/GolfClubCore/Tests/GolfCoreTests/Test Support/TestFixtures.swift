//
//  TestFixtures.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//
//

@testable import GolfCore

enum TestFixtures { }

// MARK: - Player

extension Player {

    static var mock: Player {
        Player(
            name: "Test Player",
            handicapIndex: 12.0,
            recommendationAuditEnabled: false
        )
    }
}

// MARK: - Hole

extension Hole {

    static var mock: Hole {
        Hole(
            number: 1,
            par: 4,
            strokeIndex: 10,
            lengthMeters: 360,
            teeLocation: GeoCoordinate(
                latitude: -39.930000,
                longitude: 175.050000
            ),
            greenLocation: GeoCoordinate(
                latitude: -39.927000,
                longitude: 175.053000
            )
        )
    }
}

// MARK: - Hole Strategy Geometry

extension HoleStrategyGeometry {

    static var mock: HoleStrategyGeometry {

        let hole = Hole.mock

        return HoleStrategyGeometry(
            holeID: hole.id,
            centreLine: [
                GeoCoordinate(
                    latitude: -39.930000,
                    longitude: 175.050000
                ),
                GeoCoordinate(
                    latitude: -39.927000,
                    longitude: 175.053000
                )
            ],
            landingZones: [],
            hazards: [],
            greenCentre: hole.greenLocation!
        )
    }
}

// MARK: - Environmental Context

extension EnvironmentalContext {

    static var `default`: EnvironmentalContext {
        EnvironmentalContext()
    }
}
