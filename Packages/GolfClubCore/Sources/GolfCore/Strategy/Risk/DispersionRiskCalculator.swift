//
//  DispersionRiskCalculator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct DispersionRiskCalculator:
    Sendable {


    public init() {}


    public func evaluate(
        profile:
            ShotDispersionProfile,
        target:
            GeoCoordinate,
        shotStart:
            GeoCoordinate,
        hazard:
            HazardZone
    ) -> DispersionRiskAssessment {


        let offset =
            lateralOffset(
                start:
                    shotStart,
                target:
                    target,
                point:
                    hazard.location
            )


        let dispersionWidth =
            abs(
                profile.lateralBiasMeters
            )
            +
            10


        let risk =
            calculateRisk(
                hazardOffset:
                    offset,
                dispersionWidth:
                    dispersionWidth
            )


        return DispersionRiskAssessment(
            riskProbability:
                risk,
            lateralOffsetMeters:
                offset,
            dispersionWidthMeters:
                dispersionWidth,
            confidence:
                profile.confidence
        )
    }


    private func calculateRisk(
        hazardOffset:
            Double,
        dispersionWidth:
            Double
    ) -> Double {


        let distance =
            abs(
                hazardOffset
            )


        guard distance <=
                dispersionWidth
        else {
            return 0
        }


        return max(
            0,
            min(
                1,
                1 -
                (
                    distance /
                    dispersionWidth
                )
            )
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


    let targetBearing =
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
            targetBearing
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


    return sin(angle)
    *
    distance
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
