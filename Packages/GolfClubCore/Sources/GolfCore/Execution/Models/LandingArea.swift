//
//  LandingArea.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct LandingArea:
    Codable,
    Equatable,
    Sendable {

    public let centre:
        GeoCoordinate

    public let radiusMeters:
        Double

    public init(
        centre:
            GeoCoordinate,
        radiusMeters:
            Double
    ) {
        self.centre =
            centre

        self.radiusMeters =
            max(
                0,
                radiusMeters
            )
    }
}
public extension LandingArea {

    func contains(
        _ location: GeoCoordinate
    ) -> Bool {

        DistanceCalculator.distanceMeters(
            from: centre,
            to: location
        ) <= radiusMeters
    }
}
