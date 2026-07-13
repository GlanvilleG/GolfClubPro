//
//  TargetSelector.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct TargetSelection: Codable, Equatable, Sendable {
    public var route: PlayingRoute
    public var target: TargetPoint
    public var obstacleEvaluation: ObstacleEvaluation
    public var score: Double

    public init(
        route: PlayingRoute,
        target: TargetPoint,
        obstacleEvaluation: ObstacleEvaluation,
        score: Double
    ) {
        self.route = route
        self.target = target
        self.obstacleEvaluation = obstacleEvaluation
        self.score = score
    }
}

public struct TargetSelector: Sendable {

    private let obstacleEvaluator: ObstacleEvaluator

    public init(
        obstacleEvaluator: ObstacleEvaluator = ObstacleEvaluator()
    ) {
        self.obstacleEvaluator = obstacleEvaluator
    }

    public func selectTarget(
        from currentPosition: GeoCoordinate,
        routes: [PlayingRoute],
        hazards: [HoleArea]
    ) -> TargetSelection? {
        let candidates = routes.compactMap { route -> TargetSelection? in
            guard let target = route.immediateTarget else {
                return nil
            }

            let evaluation = obstacleEvaluator.evaluate(
                from: currentPosition,
                to: target.location,
                hazards: hazards
            )

            let strategyPenalty = penalty(for: route.strategy)
            let score =
                route.estimatedRisk +
                evaluation.riskScore +
                strategyPenalty

            return TargetSelection(
                route: route,
                target: target,
                obstacleEvaluation: evaluation,
                score: score
            )
        }

        return candidates.min { $0.score < $1.score }
    }

    private func penalty(
        for strategy: RouteStrategy
    ) -> Double {
        switch strategy {
        case .conservative:
            return 0
        case .positional:
            return 0.05
        case .direct:
            return 0.10
        case .recovery:
            return 0.15
        case .aggressive:
            return 0.25
        }
    }
}
