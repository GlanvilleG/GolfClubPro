//
//  PlannedShotOutcome.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct PlannedShotOutcome:
    Codable,
    Equatable,
    Sendable {

    public let shotID:
        ShotID

    public let clubID:
        ClubID

    public let targetLocation:
        GeoCoordinate

    public let expectedDistanceMeters:
        Double

    public let acceptableDistanceVarianceMeters:
        Double

    public let landingArea:
        LandingArea

    public let avoidZones:
        [HazardZone]

    public init(
        shot:
            Shot,
        targetLocation:
            GeoCoordinate,
        expectedDistanceMeters:
            Double,
        acceptableDistanceVarianceMeters:
            Double = 15,
        landingArea:
            LandingArea,
        avoidZones:
            [HazardZone] = []
    ) {

        self.shotID =
            shot.id

        self.clubID =
            shot.clubID

        self.targetLocation =
            targetLocation

        self.expectedDistanceMeters =
            expectedDistanceMeters

        self.acceptableDistanceVarianceMeters =
            acceptableDistanceVarianceMeters

        self.landingArea =
            landingArea

        self.avoidZones =
            avoidZones
    }
}
