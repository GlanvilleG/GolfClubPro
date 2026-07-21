//
//  TestStrategyGeometryFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//
import Foundation
@testable import GolfCore

enum TestStrategyGeometryFactory {

    static func holeStrategyGeometry(
        holeID: HoleID = HoleID(),
        greenCentre: GeoCoordinate = GeoCoordinate(latitude: 0, longitude: 0),
        pinLocation: GeoCoordinate? = nil,
        landingZones: [LandingZone] = []
    ) -> HoleStrategyGeometry {
        HoleStrategyGeometry(
            holeID: holeID,
            landingZones: landingZones,
            greenCentre: greenCentre,
            pinLocation: pinLocation
        )
    }

    static func landingZone(
        label: String = "Left fairway",
        priority: Int = 5,
        riskRating: Double = 0.20,
        centre: GeoCoordinate = GeoCoordinate(latitude: 0, longitude: 0)
    ) -> LandingZone {
        LandingZone(
            centre: centre,
            priority: priority,
            riskRating: riskRating,
            label: label
        )
    }

   static func targetPoint(
        location: GeoCoordinate = GeoCoordinate(latitude: 0, longitude: 0),
        type: TargetPointType = .landingZone,
        label: String? = nil
    ) -> TargetPoint {
        TargetPoint(
            location: location,
            type: type,
            label: label
        )
    }

    static func playingRoute(
        targets: [TargetPoint],
        strategy:RouteStrategy = .positional,
        rationale: String = "Test route",
        estimatedRisk: Double = 0.15
    ) -> PlayingRoute {
        PlayingRoute(
            targets: targets,
            strategy: strategy,
            rationale: rationale,
            estimatedRisk: estimatedRisk
        )
    }
}
// Test-only convenience for creating rectangular boundaries used in strategy tests.
extension GeometryTestFactory {

    static func makeSquareBoundary(
        minimumLatitude: Double,
        minimumLongitude: Double,
        maximumLatitude: Double,
        maximumLongitude: Double
    ) -> [GeoCoordinate] {
        [
            GeoCoordinate(latitude: minimumLatitude, longitude: minimumLongitude),
            GeoCoordinate(latitude: minimumLatitude, longitude: maximumLongitude),
            GeoCoordinate(latitude: maximumLatitude, longitude: maximumLongitude),
            GeoCoordinate(latitude: maximumLatitude, longitude: minimumLongitude)
        ]
    }
}

