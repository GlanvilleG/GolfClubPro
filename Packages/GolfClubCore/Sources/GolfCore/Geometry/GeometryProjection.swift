//
//  GeometryProjection.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

enum GeometryProjection {

    private static let earthRadiusMeters =
        6_371_000.0

    static func project(
        _ coordinate: GeoCoordinate,
        relativeTo origin: GeoCoordinate
    ) -> GeometryPoint {
        let latitude =
            coordinate.latitude * .pi / 180

        let longitude =
            coordinate.longitude * .pi / 180

        let originLatitude =
            origin.latitude * .pi / 180

        let originLongitude =
            origin.longitude * .pi / 180

        let x =
            (longitude - originLongitude) *
            cos(
                (latitude + originLatitude) / 2
            ) *
            earthRadiusMeters

        let y =
            (latitude - originLatitude) *
            earthRadiusMeters

        return GeometryPoint(
            x: x,
            y: y
        )
    }
}
