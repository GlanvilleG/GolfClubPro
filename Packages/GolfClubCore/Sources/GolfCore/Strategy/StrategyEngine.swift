//
//  StrategyEngine.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum StrategyEngineError: Error, Equatable, Sendable {
    case noRoutesAvailable
    case noTargetAvailable
}

public struct StrategyEngine: Sendable {

    private let routePlanner: RoutePlanner
    private let targetSelector: TargetSelector
    private let shotPlanner: ShotPlanner

    public init(
        routePlanner: RoutePlanner = RoutePlanner(),
        targetSelector: TargetSelector = TargetSelector(),
        shotPlanner: ShotPlanner = ShotPlanner()
    ) {
        self.routePlanner = routePlanner
        self.targetSelector = targetSelector
        self.shotPlanner = shotPlanner
    }

    public func makeShotPlan(
        from currentPosition: GeoCoordinate,
        using geometry: HoleStrategyGeometry,
        preferredClubID: ClubID? = nil,
        alternativeClubIDs: [ClubID] = []
    ) throws -> ShotPlan {
        let routes = routePlanner.generateRoutes(
            from: currentPosition,
            using: geometry
        )

        guard !routes.isEmpty else {
            throw StrategyEngineError.noRoutesAvailable
        }

        guard let selection = targetSelector.selectTarget(
            from: currentPosition,
            routes: routes,
            hazards: geometry.hazards
        ) else {
            throw StrategyEngineError.noTargetAvailable
        }

        return shotPlanner.makePlan(
            from: currentPosition,
            selection: selection,
            preferredClubID: preferredClubID,
            alternativeClubIDs: alternativeClubIDs
        )
    }
}
