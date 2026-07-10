//
//  ShotPlan.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum ShotRiskLevel: String, Codable, CaseIterable, Sendable {
    case low
    case moderate
    case high
    case extreme
}

public struct ShotPlan: Codable, Equatable, Sendable {
    public let id: ShotPlanID
    public var aimPoint: TargetPoint
    public var targetBearingDegrees: Double
    public var targetDistanceMeters: Double
    public var preferredClubID: ClubID?
    public var alternativeClubIDs: [ClubID]
    public var routeStrategy: RouteStrategy
    public var riskLevel: ShotRiskLevel
    public var confidence: Double
    public var rationale: String

    public init(
        id: ShotPlanID = ShotPlanID(),
        aimPoint: TargetPoint,
        targetBearingDegrees: Double,
        targetDistanceMeters: Double,
        preferredClubID: ClubID? = nil,
        alternativeClubIDs: [ClubID] = [],
        routeStrategy: RouteStrategy,
        riskLevel: ShotRiskLevel,
        confidence: Double,
        rationale: String
    ) {
        self.id = id
        self.aimPoint = aimPoint
        self.targetBearingDegrees = targetBearingDegrees
        self.targetDistanceMeters = targetDistanceMeters
        self.preferredClubID = preferredClubID
        self.alternativeClubIDs = alternativeClubIDs
        self.routeStrategy = routeStrategy
        self.riskLevel = riskLevel
        self.confidence = min(1, max(0, confidence))
        self.rationale = rationale
    }
}
