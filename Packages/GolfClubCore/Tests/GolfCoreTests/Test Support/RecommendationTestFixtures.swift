//
//  RecommendationTestFixtures.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation
@testable import GolfCore

enum RecommendationTestFixtures {

    static func makeShotContext(
        targetDistanceMeters: Double = 150,
        clubs: [Club] = [
            Club(
                name: "7 Iron",
                type: .iron,
                averageCarryMeters: 150
            )
        ],
        lie: PlayableLie = .fairway,
        courseArea: HoleAreaType = .fairway,
        history: [RecentShotSummary] = []
    ) -> ShotContext {

        let player =
            Player(name: "Gerard")

        let hole =
            Hole(
                number: 1,
                par: 4,
                lengthMeters:
                    targetDistanceMeters
            )

        let currentPosition =
            GeoCoordinate(
                latitude: 0,
                longitude: 0
            )

        let targetLocation =
            GeoCoordinate(
                latitude:
                    targetDistanceMeters / 111_320,
                longitude: 0
            )

        let target =
            TargetPoint(
                location:
                    targetLocation,
                type: .greenCentre,
                label:
                    "Green centre"
            )

        let shotPlan =
            ShotPlan(
                aimPoint:
                    target,
                targetBearingDegrees:
                    0,
                targetDistanceMeters:
                    targetDistanceMeters,
                routeStrategy:
                    .direct,
                riskLevel:
                    .low,
                confidence:
                    0.90,
                rationale:
                    "Clear direct route."
            )

        let strategyGeometry =
            HoleStrategyGeometry(
                holeID:
                    hole.id,
                greenCentre:
                    targetLocation
            )

        return ShotContext(
            player:
                player,
            roundID:
                RoundID(),
            hole:
                hole,
            currentPosition:
                currentPosition,
            playableLie:
                lie,
            courseArea:
                courseArea,
            availableClubs:
                clubs,
            recentShotHistory:
                history,
            strategyGeometry:
                strategyGeometry,
            currentShotPlan:
                shotPlan
        )
    }
}
