//
//  PlayingRoute.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum RouteStrategy: String, Codable, CaseIterable, Sendable {
    case direct
    case positional
    case conservative
    case aggressive
    case recovery
}

public struct PlayingRoute: Codable, Equatable, Sendable {
    public let id: PlayingRouteID
    public var targets: [TargetPoint]
    public var strategy: RouteStrategy
    public var rationale: String
    public var estimatedRisk: Double

    public init(
        id: PlayingRouteID = PlayingRouteID(),
        targets: [TargetPoint],
        strategy: RouteStrategy,
        rationale: String,
        estimatedRisk: Double = 0.5
    ) {
        self.id = id
        self.targets = targets
        self.strategy = strategy
        self.rationale = rationale
        self.estimatedRisk = min(1, max(0, estimatedRisk))
    }

    public var immediateTarget: TargetPoint? {
        targets.first
    }
}
