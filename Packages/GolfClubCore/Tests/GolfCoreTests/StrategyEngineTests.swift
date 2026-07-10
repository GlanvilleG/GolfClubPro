//
//  StrategyEngineTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class StrategyEngineTests: XCTestCase {

    private let engine = StrategyEngine()

    func testStrategyEngineCreatesDirectShotPlan() throws {
        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )
        )

        let plan = try engine.makeShotPlan(
            from: GeoCoordinate(
                latitude: -39.9350,
                longitude: 175.0450
            ),
            using: geometry
        )

        XCTAssertEqual(plan.routeStrategy, .direct)
        XCTAssertEqual(plan.aimPoint.type, .greenCentre)
        XCTAssertGreaterThan(plan.targetDistanceMeters, 0)
    }

    func testStrategyEngineSelectsSaferLandingZone() throws {
        let currentPosition = GeoCoordinate(
            latitude: 0,
            longitude: 0
        )

        let landingZone = LandingZone(
            centre: GeoCoordinate(
                latitude: 10,
                longitude: 0
            ),
            priority: 10,
            riskRating: 0.10,
            label: "Safe fairway"
        )

        let water = CourseArea(
            type: .water,
            boundary: [
                GeoCoordinate(latitude: 4, longitude: 4),
                GeoCoordinate(latitude: 4, longitude: 6),
                GeoCoordinate(latitude: 6, longitude: 6),
                GeoCoordinate(latitude: 6, longitude: 4)
            ]
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            landingZones: [landingZone],
            hazards: [water],
            greenCentre: GeoCoordinate(
                latitude: 10,
                longitude: 10
            )
        )

        let plan = try engine.makeShotPlan(
            from: currentPosition,
            using: geometry
        )

        XCTAssertEqual(plan.routeStrategy, .positional)
        XCTAssertEqual(plan.aimPoint.type, .landingZone)
        XCTAssertEqual(plan.aimPoint.location, landingZone.centre)
    }

    func testStrategyEnginePreservesClubChoices() throws {
        let preferredClubID = ClubID()
        let alternativeClubID = ClubID()

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: GeoCoordinate(
                latitude: 1,
                longitude: 1
            )
        )

        let plan = try engine.makeShotPlan(
            from: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            using: geometry,
            preferredClubID: preferredClubID,
            alternativeClubIDs: [alternativeClubID]
        )

        XCTAssertEqual(plan.preferredClubID, preferredClubID)
        XCTAssertEqual(plan.alternativeClubIDs, [alternativeClubID])
    }

    func testStrategyEngineCreatesExplainableRationale() throws {
        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: GeoCoordinate(
                latitude: 1,
                longitude: 1
            )
        )

        let plan = try engine.makeShotPlan(
            from: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            using: geometry
        )

        XCTAssertFalse(plan.rationale.isEmpty)
    }
}
