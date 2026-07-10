//
//  RoutePlanner.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct RoutePlanner: Sendable {

    public init() {}

    public func generateRoutes(
        from currentPosition: GeoCoordinate,
        using geometry: HoleStrategyGeometry
    ) -> [PlayingRoute] {
        var routes: [PlayingRoute] = []

        let finalTarget = TargetPoint(
            location: geometry.finalTarget,
            type: geometry.pinLocation == nil ? .greenCentre : .pin,
            label: geometry.pinLocation == nil ? "Green centre" : "Pin"
        )

        routes.append(
            PlayingRoute(
                targets: [finalTarget],
                strategy: .direct,
                rationale: "Play directly toward the final target.",
                estimatedRisk: 0.5
            )
        )

        let orderedZones = geometry.landingZones.sorted {
            if $0.priority == $1.priority {
                return $0.riskRating < $1.riskRating
            }

            return $0.priority > $1.priority
        }

        for zone in orderedZones {
            let target = TargetPoint(
                location: zone.centre,
                type: .landingZone,
                label: zone.label ?? "Landing zone"
            )

            routes.append(
                PlayingRoute(
                    targets: [target, finalTarget],
                    strategy: .positional,
                    rationale:
                        "Play to \(target.label ?? "the landing zone") before approaching the green.",
                    estimatedRisk: zone.riskRating
                )
            )
        }

        return routes
    }
}
