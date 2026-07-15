//
//  ActualShotOutcome.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

import Foundation

public struct ActualShotOutcome:
    Codable,
    Equatable,
    Sendable {

    public let shotID:
        ShotID

    public let landingLocation:
        GeoCoordinate

    public let distanceMeters:
        Double

    public let recordedAt:
        Date

    public init(
        shotID:
            ShotID,
        landingLocation:
            GeoCoordinate,
        distanceMeters:
            Double,
        recordedAt:
            Date = Date()
    ) {
        self.shotID =
            shotID

        self.landingLocation =
            landingLocation

        self.distanceMeters =
            max(
                0,
                distanceMeters
            )

        self.recordedAt =
            recordedAt
    }
}
public extension ActualShotOutcome {

    func distanceFrom(
        _ location:
            GeoCoordinate
    ) -> Double {

        DistanceCalculator.distanceMeters(
            from:
                location,
            to:
                landingLocation
        )
    }
}
