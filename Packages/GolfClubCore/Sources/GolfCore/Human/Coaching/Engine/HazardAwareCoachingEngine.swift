//
//  HazardAwareCoachingEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//
//
//  HazardAwareCoachingEngine.swift
//  GolfClubCore
//

import Foundation


public struct HazardAwareCoachingEngine:
    Sendable {


    public init() {}


    public func evaluate(
        shotStart:
            GeoCoordinate,
        target:
            GeoCoordinate,
        expectedDistanceMeters:
            Double,
        playerBiasMeters:
            Double,
        hazard:
            HazardZone
    ) -> HazardAdjustment {


        let hazardDistance =
            DistanceCalculator.distanceMeters(
                from:
                    shotStart,
                to:
                    hazard.location
            )


        guard hazardDistance <=
                expectedDistanceMeters + 20
        else {

            return noAdjustment(
                hazard:
                    hazard,
                reason:
                    "Hazard is outside expected landing area."
            )
        }


        let hazardOffset =
            lateralOffset(
                start:
                    shotStart,
                target:
                    target,
                point:
                    hazard.location
            )


        guard hazardOffset != 0
        else {

            return noAdjustment(
                hazard:
                    hazard,
                reason:
                    "Hazard is not offset from target line."
            )
        }


        let sameSide =
            hazardOffset.sign ==
            playerBiasMeters.sign


        guard sameSide
        else {

            return noAdjustment(
                hazard:
                    hazard,
                reason:
                    "Hazard is opposite to normal miss pattern."
            )
        }

        // DEBUG
        print("Hazard offset:", hazardOffset)
        print("Player bias:", playerBiasMeters)
        // DEBUG END
        
        
        return HazardAdjustment(
            additionalAdjustmentMeters:
                5,
            hazard:
                hazard,
            reason:
                "Additional margin applied because hazard overlaps player's normal miss pattern.",
            confidence:
                0.75
        )
    }


    private func noAdjustment(
        hazard:
            HazardZone,
        reason:
            String
    ) -> HazardAdjustment {

        HazardAdjustment(
            additionalAdjustmentMeters:
                0,
            hazard:
                hazard,
            reason:
                reason,
            confidence:
                0
        )
    }
}
private func lateralOffset(
    start:
        GeoCoordinate,
    target:
        GeoCoordinate,
    point:
        GeoCoordinate
) -> Double {


    let lineBearing =
        bearing(
            from:
                start,
            to:
                target
        )


    let pointBearing =
        bearing(
            from:
                start,
            to:
                point
        )


    let angle =
        (
            pointBearing -
            lineBearing
        )
        *
        .pi /
        180


    let distance =
        DistanceCalculator.distanceMeters(
            from:
                start,
            to:
                point
        )


    return sin(angle) * distance
}
private func bearing(
    from:
        GeoCoordinate,
    to:
        GeoCoordinate
) -> Double {

    let latitude1 =
        from.latitude *
        .pi /
        180

    let latitude2 =
        to.latitude *
        .pi /
        180


    let longitudeDelta =
        (
            to.longitude -
            from.longitude
        )
        *
        .pi /
        180


    let y =
        sin(longitudeDelta)
        *
        cos(latitude2)


    let x =
        cos(latitude1)
        *
        sin(latitude2)
        -
        sin(latitude1)
        *
        cos(latitude2)
        *
        cos(longitudeDelta)


    return atan2(
        y,
        x
    )
    *
    180 /
    .pi
}
