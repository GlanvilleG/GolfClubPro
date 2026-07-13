//
//  GeometryTestFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation
@testable import GolfCore

enum GeometryTestFactory {

    static let defaultCentre =
        GeoCoordinate(
            latitude: -39.9300,
            longitude: 175.0500
        )

    static func makeSquareArea(
        type: HoleAreaType,
        centre: GeoCoordinate = defaultCentre,
        size: Double = 0.0010
    ) -> HoleArea {
        let halfSize =
            size / 2

        return HoleArea(
            type: type,
            boundary: [
                GeoCoordinate(
                    latitude:
                        centre.latitude - halfSize,
                    longitude:
                        centre.longitude - halfSize
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude - halfSize,
                    longitude:
                        centre.longitude + halfSize
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude + halfSize,
                    longitude:
                        centre.longitude + halfSize
                ),
                GeoCoordinate(
                    latitude:
                        centre.latitude + halfSize,
                    longitude:
                        centre.longitude - halfSize
                )
            ]
        )
    }

    static func makeHole(
        number: Int = 1,
        par: Int = 4,
        lengthMeters: Double = 350,
        teeLocation: GeoCoordinate? =
            defaultCentre,
        greenLocation: GeoCoordinate? =
            GeoCoordinate(
                latitude: -39.9275,
                longitude: 175.0520
            ),
        geometry: HoleGeometry? = nil
    ) -> Hole {
        Hole(
            number: number,
            par: par,
            lengthMeters:
                lengthMeters,
            teeLocation:
                teeLocation,
            greenLocation:
                greenLocation,
            geometry:
                geometry
        )
    }

    static func makeGeometry(
        areas: [HoleArea]
    ) -> HoleGeometry {
        HoleGeometry(
            areas: areas
        )
    }
}
