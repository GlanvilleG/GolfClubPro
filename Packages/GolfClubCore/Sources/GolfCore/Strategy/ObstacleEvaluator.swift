//
//  ObstacleEvaluator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct ObstacleEvaluation: Codable, Equatable, Sendable {
    public var isBlocked: Bool
    public var intersectedAreas: [HoleAreaType]
    public var riskScore: Double
    public var rationale: String

    public init(
        isBlocked: Bool,
        intersectedAreas: [HoleAreaType],
        riskScore: Double,
        rationale: String
    ) {
        self.isBlocked = isBlocked
        self.intersectedAreas = intersectedAreas
        self.riskScore = min(1, max(0, riskScore))
        self.rationale = rationale
    }
}

public struct ObstacleEvaluator: Sendable {

    public init() {}

    public func evaluate(
        from start: GeoCoordinate,
        to target: GeoCoordinate,
        hazards: [HoleArea]
    ) -> ObstacleEvaluation {
        let intersected = hazards
            .filter { shotPathIntersectsArea(from: start, to: target, area: $0) }
            .map(\.type)

        let riskScore = intersected.reduce(0.0) {
            min(1, $0 + riskWeight(for: $1))
        }

        return ObstacleEvaluation(
            isBlocked: intersected.contains(.trees),
            intersectedAreas: intersected,
            riskScore: riskScore,
            rationale: rationale(for: intersected)
        )
    }

    private func riskWeight(for area: HoleAreaType) -> Double {
        switch area {
        case .water, .outOfBounds:
            return 0.60
        case .penaltyArea:
            return 0.50
        case .trees:
            return 0.45
        case .bunker:
            return 0.30
        case .rough, .nativeArea:
            return 0.15
        default:
            return 0
        }
    }

    private func rationale(for areas: [HoleAreaType]) -> String {
        guard !areas.isEmpty else {
            return "No mapped obstacle intersects the direct route."
        }

        let names = areas.map(\.rawValue).joined(separator: ", ")
        return "The planned route intersects: \(names)."
    }

    private func shotPathIntersectsArea(
        from start: GeoCoordinate,
        to target: GeoCoordinate,
        area: HoleArea
    ) -> Bool {
        guard area.boundary.count >= 3 else {
            return false
        }

        if contains(start, in: area.boundary) ||
            contains(target, in: area.boundary) {
            return true
        }

        for index in area.boundary.indices {
            let boundaryStart = area.boundary[index]
            let boundaryEnd =
                area.boundary[(index + 1) % area.boundary.count]

            if segmentsIntersect(
                start,
                target,
                boundaryStart,
                boundaryEnd
            ) {
                return true
            }
        }

        return false
    }

    private func contains(
        _ point: GeoCoordinate,
        in polygon: [GeoCoordinate]
    ) -> Bool {
        var inside = false
        var previousIndex = polygon.count - 1

        for currentIndex in polygon.indices {
            let current = polygon[currentIndex]
            let previous = polygon[previousIndex]

            let intersects =
                ((current.latitude > point.latitude) !=
                    (previous.latitude > point.latitude)) &&
                (
                    point.longitude <
                    (previous.longitude - current.longitude) *
                    (point.latitude - current.latitude) /
                    (previous.latitude - current.latitude) +
                    current.longitude
                )

            if intersects {
                inside.toggle()
            }

            previousIndex = currentIndex
        }

        return inside
    }

    private func segmentsIntersect(
        _ firstStart: GeoCoordinate,
        _ firstEnd: GeoCoordinate,
        _ secondStart: GeoCoordinate,
        _ secondEnd: GeoCoordinate
    ) -> Bool {
        let o1 = orientation(firstStart, firstEnd, secondStart)
        let o2 = orientation(firstStart, firstEnd, secondEnd)
        let o3 = orientation(secondStart, secondEnd, firstStart)
        let o4 = orientation(secondStart, secondEnd, firstEnd)

        return o1 != o2 && o3 != o4
    }

    private func orientation(
        _ a: GeoCoordinate,
        _ b: GeoCoordinate,
        _ c: GeoCoordinate
    ) -> Int {
        let value =
            (b.longitude - a.longitude) *
            (c.latitude - b.latitude) -
            (b.latitude - a.latitude) *
            (c.longitude - b.longitude)

        if abs(value) < 0.000000001 {
            return 0
        }

        return value > 0 ? 1 : 2
    }
}
