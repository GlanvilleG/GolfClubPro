//
//  StrategyTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class StrategyTests: XCTestCase {

    // MARK: - Route Planner

    func testRoutePlannerAlwaysCreatesDirectRoute() throws {
        let holeID = HoleID()

        let geometry = HoleStrategyGeometry(
            holeID: holeID,
            greenCentre: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )
        )

        let planner = RoutePlanner()

        let routes = planner.generateRoutes(
            from: GeoCoordinate(
                latitude: -39.9350,
                longitude: 175.0450
            ),
            using: geometry
        )

        let directRoute = try XCTUnwrap(
            routes.first(where: { $0.strategy == .direct })
        )

        XCTAssertEqual(directRoute.targets.count, 1)
        XCTAssertEqual(
            directRoute.immediateTarget?.type,
            .greenCentre
        )
        XCTAssertEqual(
            directRoute.immediateTarget?.location,
            geometry.greenCentre
        )
    }

    func testRoutePlannerUsesPinAsFinalTargetWhenAvailable() throws {
        let pin = GeoCoordinate(
            latitude: -39.9301,
            longitude: 175.0502
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            pinLocation: pin
        )

        let routes = RoutePlanner().generateRoutes(
            from: GeoCoordinate(
                latitude: -39.9350,
                longitude: 175.0450
            ),
            using: geometry
        )

        let directRoute = try XCTUnwrap(
            routes.first(where: { $0.strategy == .direct })
        )

        XCTAssertEqual(directRoute.immediateTarget?.type, .pin)
        XCTAssertEqual(directRoute.immediateTarget?.location, pin)
    }

    func testRoutePlannerCreatesPositionalRouteForLandingZone() throws {
        let landingZone = LandingZone(
            centre: GeoCoordinate(
                latitude: -39.9330,
                longitude: 175.0470
            ),
            priority: 10,
            riskRating: 0.20,
            label: "Left fairway"
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            landingZones: [landingZone],
            greenCentre: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            )
        )

        let routes = RoutePlanner().generateRoutes(
            from: GeoCoordinate(
                latitude: -39.9360,
                longitude: 175.0440
            ),
            using: geometry
        )

        let positionalRoute = try XCTUnwrap(
            routes.first(where: { $0.strategy == .positional })
        )

        XCTAssertEqual(positionalRoute.targets.count, 2)
        XCTAssertEqual(
            positionalRoute.immediateTarget?.type,
            .landingZone
        )
        XCTAssertEqual(
            positionalRoute.immediateTarget?.location,
            landingZone.centre
        )
    }

    func testLandingZonesAreOrderedByPriority() throws {
        let lowerPriority = LandingZone(
            centre: GeoCoordinate(latitude: 1, longitude: 1),
            priority: 1,
            riskRating: 0.10,
            label: "Lower priority"
        )

        let higherPriority = LandingZone(
            centre: GeoCoordinate(latitude: 2, longitude: 2),
            priority: 10,
            riskRating: 0.20,
            label: "Higher priority"
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            landingZones: [lowerPriority, higherPriority],
            greenCentre: GeoCoordinate(latitude: 3, longitude: 3)
        )

        let routes = RoutePlanner().generateRoutes(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            using: geometry
        )

        let positionalRoutes = routes.filter {
            $0.strategy == .positional
        }

        XCTAssertEqual(positionalRoutes.count, 2)
        XCTAssertEqual(
            positionalRoutes.first?.immediateTarget?.location,
            higherPriority.centre
        )
    }

    // MARK: - Obstacle Evaluator

    func testObstacleEvaluatorDetectsWaterIntersection() {
        let water = HoleArea(
            type: .water,
            boundary: squareBoundary(
                minimumLatitude: 4,
                minimumLongitude: 4,
                maximumLatitude: 6,
                maximumLongitude: 6
            )
        )

        let evaluation = ObstacleEvaluator().evaluate(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            to: GeoCoordinate(latitude: 10, longitude: 10),
            hazards: [water]
        )

        XCTAssertTrue(
            evaluation.intersectedAreas.contains(.water)
        )
        XCTAssertGreaterThan(evaluation.riskScore, 0)
        XCTAssertFalse(evaluation.isBlocked)
    }

    func testObstacleEvaluatorTreatsTreesAsBlocked() {
        let trees = HoleArea(
            type: .trees,
            boundary: squareBoundary(
                minimumLatitude: 4,
                minimumLongitude: 4,
                maximumLatitude: 6,
                maximumLongitude: 6
            )
        )

        let evaluation = ObstacleEvaluator().evaluate(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            to: GeoCoordinate(latitude: 10, longitude: 10),
            hazards: [trees]
        )

        XCTAssertTrue(evaluation.isBlocked)
        XCTAssertTrue(
            evaluation.intersectedAreas.contains(.trees)
        )
    }

    func testObstacleEvaluatorReturnsLowRiskForClearRoute() {
        let bunker = HoleArea(
            type: .bunker,
            boundary: squareBoundary(
                minimumLatitude: 20,
                minimumLongitude: 20,
                maximumLatitude: 25,
                maximumLongitude: 25
            )
        )

        let evaluation = ObstacleEvaluator().evaluate(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            to: GeoCoordinate(latitude: 10, longitude: 10),
            hazards: [bunker]
        )

        XCTAssertFalse(evaluation.isBlocked)
        XCTAssertTrue(evaluation.intersectedAreas.isEmpty)
        XCTAssertEqual(evaluation.riskScore, 0)
    }

    // MARK: - Target Selector

    func testTargetSelectorPrefersLowerRiskPositionalRoute() throws {
        let directTarget = TargetPoint(
            location: GeoCoordinate(latitude: 10, longitude: 10),
            type: .greenCentre,
            label: "Green"
        )

        let safeTarget = TargetPoint(
            location: GeoCoordinate(latitude: 4, longitude: 1),
            type: .landingZone,
            label: "Safe fairway"
        )

        let directRoute = PlayingRoute(
            targets: [directTarget],
            strategy: .direct,
            rationale: "Direct to green.",
            estimatedRisk: 0.60
        )

        let positionalRoute = PlayingRoute(
            targets: [safeTarget, directTarget],
            strategy: .positional,
            rationale: "Play to safe fairway first.",
            estimatedRisk: 0.15
        )

        let selection = TargetSelector().selectTarget(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            routes: [directRoute, positionalRoute],
            hazards: []
        )

        let result = try XCTUnwrap(selection)

        XCTAssertEqual(result.route.strategy, .positional)
        XCTAssertEqual(result.target.location, safeTarget.location)
    }

    func testTargetSelectorPenalisesHazardIntersection() throws {
        let directTarget = TargetPoint(
            location: GeoCoordinate(latitude: 10, longitude: 10),
            type: .pin,
            label: "Pin"
        )

        let safeTarget = TargetPoint(
            location: GeoCoordinate(latitude: 10, longitude: 0),
            type: .landingZone,
            label: "Safe right side"
        )

        let directRoute = PlayingRoute(
            targets: [directTarget],
            strategy: .direct,
            rationale: "Direct route.",
            estimatedRisk: 0.10
        )

        let positionalRoute = PlayingRoute(
            targets: [safeTarget, directTarget],
            strategy: .positional,
            rationale: "Avoid water.",
            estimatedRisk: 0.15
        )

        let water = HoleArea(
            type: .water,
            boundary: squareBoundary(
                minimumLatitude: 4,
                minimumLongitude: 4,
                maximumLatitude: 6,
                maximumLongitude: 6
            )
        )

        let selection = TargetSelector().selectTarget(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            routes: [directRoute, positionalRoute],
            hazards: [water]
        )

        let result = try XCTUnwrap(selection)

        XCTAssertEqual(result.route.strategy, .positional)
        XCTAssertFalse(
            result.obstacleEvaluation.intersectedAreas.contains(.water)
        )
    }

    func testTargetSelectorReturnsNilWhenThereAreNoTargets() {
        let emptyRoute = PlayingRoute(
            targets: [],
            strategy: .positional,
            rationale: "Incomplete route.",
            estimatedRisk: 0
        )

        let selection = TargetSelector().selectTarget(
            from: GeoCoordinate(latitude: 0, longitude: 0),
            routes: [emptyRoute],
            hazards: []
        )

        XCTAssertNil(selection)
    }

    // MARK: - Model Behaviour

    func testPlayingRouteImmediateTargetReturnsFirstTarget() {
        let first = TargetPoint(
            location: GeoCoordinate(latitude: 1, longitude: 1),
            type: .landingZone
        )

        let second = TargetPoint(
            location: GeoCoordinate(latitude: 2, longitude: 2),
            type: .greenCentre
        )

        let route = PlayingRoute(
            targets: [first, second],
            strategy: .positional,
            rationale: "Two-stage route."
        )

        XCTAssertEqual(route.immediateTarget, first)
    }

    func testHoleStrategyGeometryUsesGreenCentreWithoutPin() {
        let greenCentre = GeoCoordinate(
            latitude: 5,
            longitude: 5
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: greenCentre
        )

        XCTAssertEqual(geometry.finalTarget, greenCentre)
    }

    func testHoleStrategyGeometryUsesPinWhenAvailable() {
        let greenCentre = GeoCoordinate(
            latitude: 5,
            longitude: 5
        )

        let pin = GeoCoordinate(
            latitude: 5.1,
            longitude: 5.1
        )

        let geometry = HoleStrategyGeometry(
            holeID: HoleID(),
            greenCentre: greenCentre,
            pinLocation: pin
        )

        XCTAssertEqual(geometry.finalTarget, pin)
    }

    // MARK: - Helpers

    private func squareBoundary(
        minimumLatitude: Double,
        minimumLongitude: Double,
        maximumLatitude: Double,
        maximumLongitude: Double
    ) -> [GeoCoordinate] {
        [
            GeoCoordinate(
                latitude: minimumLatitude,
                longitude: minimumLongitude
            ),
            GeoCoordinate(
                latitude: minimumLatitude,
                longitude: maximumLongitude
            ),
            GeoCoordinate(
                latitude: maximumLatitude,
                longitude: maximumLongitude
            ),
            GeoCoordinate(
                latitude: maximumLatitude,
                longitude: minimumLongitude
            )
        ]
    }
}
