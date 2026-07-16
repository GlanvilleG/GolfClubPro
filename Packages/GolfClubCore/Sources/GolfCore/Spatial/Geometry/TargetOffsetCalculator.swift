//
//  TargetOffsetCalculator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct TargetOffsetCalculator:
    Sendable {


    private static let earthRadiusMeters:
        Double = 6_371_000


    public static func offset(
        target:
            GeoCoordinate,
        bearingDegrees:
            Double,
        offsetMeters:
            Double
    ) -> GeoCoordinate {


        guard offsetMeters != 0
        else {
            return target
        }


        let bearingRadians =
            bearingDegrees *
            .pi /
            180


        let angularDistance =
            offsetMeters /
            earthRadiusMeters


        let latitude =
            target.latitude *
            .pi /
            180


        let longitude =
            target.longitude *
            .pi /
            180


        let newLatitude =
            asin(
                sin(latitude)
                *
                cos(angularDistance)
                +
                cos(latitude)
                *
                sin(angularDistance)
                *
                cos(bearingRadians)
            )


        let newLongitude =
            longitude +
            atan2(
                sin(bearingRadians)
                *
                sin(angularDistance)
                *
                cos(latitude),
                
                cos(angularDistance)
                -
                sin(latitude)
                *
                sin(newLatitude)
            )


        return GeoCoordinate(
            latitude:
                newLatitude *
                180 /
                .pi,

            longitude:
                newLongitude *
                180 /
                .pi
        )
    }
}
