//
//  ShotPlannerTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotPlannerTests: XCTestCase {

    private let planner = ShotPlanner()

    func testShotPlanCalculatesDistance() {
        let start = GeoCoordinate(
            latitude: -39.9300,
            longitude: 175.0500
        )

        let target = TargetPoint(
            location: GeoCoordinate(
                latitude: -39.9290,
                longitude: 175.0510
            ),
            type: .landingZone,
            label: "Fairway target"
        )

        let route = PlayingRoute(
            targets: [target],
            strategy: .positional,
            rationale: "Play to the fairway.",
            estimatedRisk: 0.10
        )

        let selection = TargetSelection(
            route: route,
            target: target,
            obstacleEvaluation: ObstacleEvaluation(
                isBlocked: false,
                intersectedAreas: [],
                riskScore: 0,
                rationale: "Clear route."
            ),
            score: 0.15
        )

        let plan = planner.makePlan(
            from: start,
            selection: selection
        )

        XCTAssertGreaterThan(plan.targetDistanceMeters, 0)
        XCTAssertEqual(plan.aimPoint, target)
    }

    func testShotPlanBearingIsNormalised() {
        let start = GeoCoordinate(
            latitude: 0,
            longitude: 0
        )

        let target = TargetPoint(
            location: GeoCoordinate(
                latitude: 1,
                longitude: 1
            ),
            type: .greenCentre
        )

        let route = PlayingRoute(
            targets: [target],
            strategy: .direct,
            rationale: "Direct route.",
            estimatedRisk: 0.10
        )

        let selection = TargetSelection(
            route: route,
            target: target,
            obstacleEvaluation: ObstacleEvaluation(
                isBlocked: false,
                intersectedAreas: [],
                riskScore: 0,
                rationale: "No obstacle."
            ),
            score: 0.10
        )

        let plan = planner.makePlan(
            from: start,
            selection: selection
        )

        XCTAssertGreaterThanOrEqual(
            plan.targetBearingDegrees,
            0
        )

        XCTAssertLessThan(
            plan.targetBearingDegrees,
            360
        )
    }

    func testLowRiskProducesHighConfidence() {
        let target = TargetPoint(
            location: GeoCoordinate(
                latitude: 1,
                longitude: 1
            ),
            type: .landingZone
        )

        let route = PlayingRoute(
            targets: [target],
            strategy: .conservative,
            rationale: "Safe route.",
            estimatedRisk: 0.10
        )

        let selection = TargetSelection(
            route: route,
            target: target,
            obstacleEvaluation: ObstacleEvaluation(
                isBlocked: false,
                intersectedAreas: [],
                riskScore: 0.05,
                rationale: "Clear route."
            ),
            score: 0.15
        )

        let plan = planner.makePlan(
            from: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            selection: selection
        )

        XCTAssertEqual(plan.riskLevel, .low)
        XCTAssertEqual(plan.confidence, 0.85, accuracy: 0.001)
    }

    func testHighRiskProducesHighRiskLevel() {
        let target = TargetPoint(
            location: GeoCoordinate(
                latitude: 1,
                longitude: 1
            ),
            type: .pin
        )

        let route = PlayingRoute(
            targets: [target],
            strategy: .aggressive,
            rationale: "Aggressive route.",
            estimatedRisk: 0.40
        )

        let selection = TargetSelection(
            route: route,
            target: target,
            obstacleEvaluation: ObstacleEvaluation(
                isBlocked: false,
                intersectedAreas: [.water],
                riskScore: 0.50,
                rationale: "Water intersects route."
            ),
            score: 0.90
        )

        let plan = planner.makePlan(
            from: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            selection: selection
        )

        XCTAssertEqual(plan.riskLevel, .high)
        XCTAssertEqual(plan.confidence, 0.10, accuracy: 0.001)
    }

    func testPreferredAndAlternativeClubsArePreserved() {
        let preferredClub = ClubID()
        let alternativeClub = ClubID()

        let target = TargetPoint(
            location: GeoCoordinate(
                latitude: 1,
                longitude: 1
            ),
            type: .landingZone
        )

        let route = PlayingRoute(
            targets: [target],
            strategy: .positional,
            rationale: "Positional play.",
            estimatedRisk: 0.20
        )

        let selection = TargetSelection(
            route: route,
            target: target,
            obstacleEvaluation: ObstacleEvaluation(
                isBlocked: false,
                intersectedAreas: [],
                riskScore: 0,
                rationale: "Clear route."
            ),
            score: 0.25
        )

        let plan = planner.makePlan(
            from: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            selection: selection,
            preferredClubID: preferredClub,
            alternativeClubIDs: [alternativeClub]
        )

        XCTAssertEqual(
            plan.preferredClubID,
            preferredClub
        )

        XCTAssertEqual(
            plan.alternativeClubIDs,
            [alternativeClub]
        )
    }
}
