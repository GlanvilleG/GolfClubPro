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
                let boundaryDistance = minimumDistanceToBoundaryMeters(
                    from: coordinate,
                    polygon: area.boundary
                )

                return LieDetectionResult(
                    courseArea: area.type,
                    playableLie: playableLie(for: area.type),
                    source: .inferredFromCourseGeometry,
                    confidence: confidence(
                        for: area.type,
                        distanceToBoundaryMeters: boundaryDistance
                    ),
                    distanceToBoundaryMeters: boundaryDistance
                )
            }
        }

        return LieDetectionResult(
            courseArea: .unknown,
            playableLie: .unknown,
            source: .unknown,
            confidence: 0,
            distanceToBoundaryMeters: nil
        )
    }

    public func confirmationRequirement(
        for result: LieDetectionResult,
        confidenceThreshold: Double = 0.70,
        boundaryThresholdMeters: Double = 5
    ) -> LieConfirmationRequirement {
        var reasons: [LieConfirmationReason] = []

        if result.courseArea == .unknown ||
            result.playableLie == .unknown {
            reasons.append(.unknownArea)
        }

        if (result.confidence ?? 0) < confidenceThreshold {
            reasons.append(.lowConfidence)
        }

        if let distance = result.distanceToBoundaryMeters,
           distance <= boundaryThresholdMeters {
            reasons.append(.nearBoundary)
        }

        if isSensitiveArea(result.courseArea) {
            reasons.append(.sensitiveArea)
        }

        if reasons.contains(.unknownArea) {
            return .required(
                inferredLie: result.playableLie,
                reasons: reasons
            )
        }

        if reasons.contains(.sensitiveArea),
           reasons.contains(.nearBoundary) ||
            reasons.contains(.lowConfidence) {
            return .required(
                inferredLie: result.playableLie,
                reasons: reasons
            )
        }

        if !reasons.isEmpty {
            return .recommended(
                inferredLie: result.playableLie,
                reasons: reasons
            )
        }

        return .notRequired
    }

    private func playableLie(
        for areaType: CourseAreaType
    ) -> PlayableLie {
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

    private func confidence(
        for areaType: CourseAreaType,
        distanceToBoundaryMeters: Double
    ) -> Double {
        let baseConfidence: Double

        switch areaType {
        case .fairway, .green, .tee:
            baseConfidence = 0.90
        case .rough, .fringe, .bunker:
            baseConfidence = 0.82
        case .trees, .nativeArea, .cartPath:
            baseConfidence = 0.72
        case .water, .outOfBounds, .penaltyArea:
            baseConfidence = 0.70
        case .unknown:
            baseConfidence = 0
        }

        switch distanceToBoundaryMeters {
        case ..<2:
            return max(0, baseConfidence - 0.35)
        case 2..<5:
            return max(0, baseConfidence - 0.20)
        case 5..<10:
            return max(0, baseConfidence - 0.08)
        default:
            return baseConfidence
        }
    }

    private func isSensitiveArea(
        _ areaType: CourseAreaType
    ) -> Bool {
        switch areaType {
        case .water, .outOfBounds, .penaltyArea:
            return true
        default:
            return false
        }
    }

    private func contains(
        _ point: GeoCoordinate,
        in polygon: [GeoCoordinate]
    ) -> Bool {
        var isInside = false
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
                isInside.toggle()
            }

            previousIndex = currentIndex
        }

        return isInside
    }

    private func minimumDistanceToBoundaryMeters(
        from point: GeoCoordinate,
        polygon: [GeoCoordinate]
    ) -> Double {
        guard polygon.count >= 2 else {
            return .infinity
        }

        var minimumDistance = Double.infinity

        for index in polygon.indices {
            let start = polygon[index]
            let end = polygon[(index + 1) % polygon.count]

            minimumDistance = min(
                minimumDistance,
                distanceToSegmentMeters(
                    point: point,
                    start: start,
                    end: end
                )
            )
        }

        return minimumDistance
    }

    private func distanceToSegmentMeters(
        point: GeoCoordinate,
        start: GeoCoordinate,
        end: GeoCoordinate
    ) -> Double {
        let referenceLatitude =
            point.latitude * .pi / 180

        let metersPerLatitudeDegree = 111_320.0
        let metersPerLongitudeDegree =
            111_320.0 * cos(referenceLatitude)

        let pointX =
            point.longitude * metersPerLongitudeDegree
        let pointY =
            point.latitude * metersPerLatitudeDegree

        let startX =
            start.longitude * metersPerLongitudeDegree
        let startY =
            start.latitude * metersPerLatitudeDegree

        let endX =
            end.longitude * metersPerLongitudeDegree
        let endY =
            end.latitude * metersPerLatitudeDegree

        let deltaX = endX - startX
        let deltaY = endY - startY
        let segmentLengthSquared =
            deltaX * deltaX + deltaY * deltaY

        guard segmentLengthSquared > 0 else {
            return hypot(pointX - startX, pointY - startY)
        }

        let projection =
            ((pointX - startX) * deltaX +
             (pointY - startY) * deltaY) /
            segmentLengthSquared

        let clampedProjection = min(1, max(0, projection))

        let closestX = startX + clampedProjection * deltaX
        let closestY = startY + clampedProjection * deltaY

        return hypot(
            pointX - closestX,
            pointY - closestY
        )
    }
}
