//
//  BearingCalculator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
//

import Foundation

public struct BearingCalculator:
    Sendable {

    public static func bearingDegrees(
        from start: GeoCoordinate,
        to end: GeoCoordinate
    ) -> Double {

        let startLatitude =
            start.latitude * .pi / 180

        let endLatitude =
            end.latitude * .pi / 180

        let longitudeDelta =
            (end.longitude - start.longitude) *
            .pi / 180

        let y =
            sin(longitudeDelta) *
            cos(endLatitude)

        let x =
            cos(startLatitude) *
            sin(endLatitude) -
            sin(startLatitude) *
            cos(endLatitude) *
            cos(longitudeDelta)

        let bearing =
            atan2(y, x) *
            180 / .pi

        return bearing >= 0
            ? bearing
            : bearing + 360
    }
}
