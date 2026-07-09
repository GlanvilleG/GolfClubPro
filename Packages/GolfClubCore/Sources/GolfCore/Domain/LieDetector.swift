//
//  LieDetector.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct LieDetector: Sendable {

    public init() {}

    public func detectLie(
        at coordinate: GeoCoordinate,
        using geometry: CourseGeometry
    ) -> LieDetectionResult {
        for area in geometry.areas {
            guard area.boundary.count >= 3 else {
                continue
            }

            if contains(coordinate, in: area.boundary) {
                return LieDetectionResult(
                    courseArea: area.type,
                    playableLie: playableLie(for: area.type),
                    source: .inferredFromCourseGeometry,
                    confidence: 0.75
                )
            }
        }

        return LieDetectionResult(
            courseArea: .unknown,
            playableLie: .unknown,
            source: .unknown,
            confidence: nil
        )
    }

    private func playableLie(for areaType: CourseAreaType) -> PlayableLie {
        switch areaType {
        case .tee:
            return .tee
        case .fairway:
            return .fairway
        case .rough:
            return .lightRough
        case .green:
            return .green
        case .fringe:
            return .fringe
        case .bunker:
            return .greensideBunker
        case .water:
            return .water
        case .trees:
            return .trees
        case .outOfBounds:
            return .outOfBounds
        case .penaltyArea:
            return .penaltyArea
        case .cartPath:
            return .cartPath
        case .nativeArea:
            return .recovery
        case .unknown:
            return .unknown
        }
    }

    private func contains(
        _ point: GeoCoordinate,
        in polygon: [GeoCoordinate]
    ) -> Bool {
        var isInside = false
        var j = polygon.count - 1

        for i in 0..<polygon.count {
            let xi = polygon[i].longitude
            let yi = polygon[i].latitude
            let xj = polygon[j].longitude
            let yj = polygon[j].latitude

            let intersects =
                ((yi > point.latitude) != (yj > point.latitude)) &&
                (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)

            if intersects {
                isInside.toggle()
            }

            j = i
        }

        return isInside
    }
}
