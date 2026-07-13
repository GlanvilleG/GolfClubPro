//
//  DistanceCalculator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct DistanceCalculator:
    Sendable {

    public static func distanceMeters(
        from start: GeoCoordinate,
        to end: GeoCoordinate
    ) -> Double {
        let earthRadiusMeters =
            6_371_000.0

        let startLatitude =
            start.latitude * .pi / 180

        let endLatitude =
            end.latitude * .pi / 180

        let latitudeDelta =
            (end.latitude - start.latitude) *
            .pi / 180

        let longitudeDelta =
            (end.longitude - start.longitude) *
            .pi / 180

        let haversine =
            sin(latitudeDelta / 2) *
            sin(latitudeDelta / 2) +
            cos(startLatitude) *
            cos(endLatitude) *
            sin(longitudeDelta / 2) *
            sin(longitudeDelta / 2)

        let clampedHaversine =
            min(
                1,
                max(0, haversine)
            )

        let angularDistance =
            2 * atan2(
                sqrt(clampedHaversine),
                sqrt(1 - clampedHaversine)
            )

        return earthRadiusMeters *
            angularDistance
    }
}
