//
//  PolygonGeometry.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

enum PolygonGeometry {

    static func contains(
        point: GeometryPoint,
        polygon: [GeometryPoint]
    ) -> Bool {
        guard polygon.count >= 3 else {
            return false
        }

        var isInside = false
        var previousIndex =
            polygon.count - 1

        for currentIndex in polygon.indices {
            let current =
                polygon[currentIndex]

            let previous =
                polygon[previousIndex]

            let crossesVerticalRange =
                (current.y > point.y) !=
                (previous.y > point.y)

            if crossesVerticalRange {
                let denominator =
                    previous.y - current.y

                if abs(denominator) >
                    Double.ulpOfOne {

                    let intersectionX =
                        (
                            previous.x -
                            current.x
                        ) *
                        (
                            point.y -
                            current.y
                        ) /
                        denominator +
                        current.x

                    if point.x < intersectionX {
                        isInside.toggle()
                    }
                }
            }

            previousIndex = currentIndex
        }

        return isInside
    }

    static func distanceToBoundary(
        point: GeometryPoint,
        polygon: [GeometryPoint]
    ) -> Double? {
        guard polygon.count >= 2 else {
            return nil
        }

        var minimumDistance =
            Double.greatestFiniteMagnitude

        for index in polygon.indices {
            let nextIndex =
                polygon.index(
                    after: index
                ) == polygon.endIndex
                ? polygon.startIndex
                : polygon.index(after: index)

            let distance =
                distance(
                    from: point,
                    toSegmentFrom:
                        polygon[index],
                    to: polygon[nextIndex]
                )

            minimumDistance =
                min(
                    minimumDistance,
                    distance
                )
        }

        return minimumDistance
    }

    private static func distance(
        from point: GeometryPoint,
        toSegmentFrom start: GeometryPoint,
        to end: GeometryPoint
    ) -> Double {
        let segmentX =
            end.x - start.x

        let segmentY =
            end.y - start.y

        let segmentLengthSquared =
            segmentX * segmentX +
            segmentY * segmentY

        guard segmentLengthSquared > 0 else {
            return hypot(
                point.x - start.x,
                point.y - start.y
            )
        }

        let projection =
            (
                (point.x - start.x) *
                segmentX +
                (point.y - start.y) *
                segmentY
            ) /
            segmentLengthSquared

        let clampedProjection =
            min(
                1,
                max(0, projection)
            )

        let closestX =
            start.x +
            clampedProjection * segmentX

        let closestY =
            start.y +
            clampedProjection * segmentY

        return hypot(
            point.x - closestX,
            point.y - closestY
        )
    }
}
