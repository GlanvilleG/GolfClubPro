//
//  HoleArea+Contains.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public extension HoleArea {

    func contains(
        _ coordinate: GeoCoordinate
    ) -> Bool {

        guard boundary.count >= 3 else {
            return false
        }

        if let boundingBox,
           !boundingBox.contains(coordinate) {

            return false
        }

        var isInside =
            false

        var previousIndex =
            boundary.count - 1

        for currentIndex in boundary.indices {

            let currentPoint =
                boundary[currentIndex]

            let previousPoint =
                boundary[previousIndex]

            let latitudeIntersects =
                (
                    currentPoint.latitude >
                    coordinate.latitude
                ) != (
                    previousPoint.latitude >
                    coordinate.latitude
                )

            if latitudeIntersects {

                let longitudeIntersection =
                    (
                        previousPoint.longitude -
                        currentPoint.longitude
                    ) *
                    (
                        coordinate.latitude -
                        currentPoint.latitude
                    ) /
                    (
                        previousPoint.latitude -
                        currentPoint.latitude
                    ) +
                    currentPoint.longitude

                if coordinate.longitude <
                    longitudeIntersection {

                    isInside.toggle()
                }
            }

            previousIndex =
                currentIndex
        }

        return isInside
    }
}
