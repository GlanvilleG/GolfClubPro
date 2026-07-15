//
//  HazardZone.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct HazardZone:
    Codable,
    Equatable,
    Sendable {

    public let name:
        String

    public let location:
        GeoCoordinate

    public let radiusMeters:
        Double

    public init(
        name:
            String,
        location:
            GeoCoordinate,
        radiusMeters:
            Double
    ) {
        self.name =
            name

        self.location =
            location

        self.radiusMeters =
            max(
                0,
                radiusMeters
            )
    }
}

public extension HazardZone {

    func contains(
        _ location:
            GeoCoordinate
    ) -> Bool {

        DistanceCalculator.distanceMeters(
            from:
                self.location,
            to:
                location
        ) <= radiusMeters
    }
}
