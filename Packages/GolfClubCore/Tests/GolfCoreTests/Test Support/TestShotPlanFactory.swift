//
//  TestShotPlanFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation
@testable import GolfCore

enum TestShotPlanFactory {

    static func makeShotPlan(
        id: ShotPlanID = ShotPlanID(),
        aimPoint: TargetPoint = TestStrategyGeometryFactory.targetPoint(),
        targetBearingDegrees: Double = 0,
        targetDistanceMeters: Double = 150,
        preferredClubID: ClubID? = nil,
        alternativeClubIDs: [ClubID] = [],
        routeStrategy: RouteStrategy = .positional,
        riskLevel: ShotRiskLevel = .low,
        confidence: Double = 0.85,
        rationale: String = "Test shot plan"
    ) -> ShotPlan {
        ShotPlan(
            id: id,
            aimPoint: aimPoint,
            targetBearingDegrees: targetBearingDegrees,
            targetDistanceMeters: targetDistanceMeters,
            preferredClubID: preferredClubID,
            alternativeClubIDs: alternativeClubIDs,
            routeStrategy: routeStrategy,
            riskLevel: riskLevel,
            confidence: confidence,
            rationale: rationale
        )
    }
}
