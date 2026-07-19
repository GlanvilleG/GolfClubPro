//
//  GeoBoundingBox.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct GeoBoundingBox:
    Codable,
    Equatable,
    Sendable {

    public let minimumLatitude: Double
    public let maximumLatitude: Double
    public let minimumLongitude: Double
    public let maximumLongitude: Double

    public init(
        minimumLatitude: Double,
        maximumLatitude: Double,
        minimumLongitude: Double,
        maximumLongitude: Double
    ) {
        self.minimumLatitude =
            min(minimumLatitude, maximumLatitude)

        self.maximumLatitude =
            max(minimumLatitude, maximumLatitude)

        self.minimumLongitude =
            min(minimumLongitude, maximumLongitude)

        self.maximumLongitude =
            max(minimumLongitude, maximumLongitude)
    }

    public init?(
        coordinates: [GeoCoordinate]
    ) {
        guard let firstCoordinate =
            coordinates.first
        else {
            return nil
        }

        var minimumLatitude =
            firstCoordinate.latitude

        var maximumLatitude =
            firstCoordinate.latitude

        var minimumLongitude =
            firstCoordinate.longitude

        var maximumLongitude =
            firstCoordinate.longitude

        for coordinate in coordinates.dropFirst() {
            minimumLatitude =
                min(
                    minimumLatitude,
                    coordinate.latitude
                )

            maximumLatitude =
                max(
                    maximumLatitude,
                    coordinate.latitude
                )

            minimumLongitude =
                min(
                    minimumLongitude,
                    coordinate.longitude
                )

            maximumLongitude =
                max(
                    maximumLongitude,
                    coordinate.longitude
                )
        }

        self.init(
            minimumLatitude:
                minimumLatitude,
            maximumLatitude:
                maximumLatitude,
            minimumLongitude:
                minimumLongitude,
            maximumLongitude:
                maximumLongitude
        )
    }

    public func contains(
        _ coordinate: GeoCoordinate
    ) -> Bool {
        coordinate.latitude >= minimumLatitude &&
        coordinate.latitude <= maximumLatitude &&
        coordinate.longitude >= minimumLongitude &&
        coordinate.longitude <= maximumLongitude
    }

    public func intersects(
        _ other: GeoBoundingBox
    ) -> Bool {
        maximumLatitude >= other.minimumLatitude &&
        minimumLatitude <= other.maximumLatitude &&
        maximumLongitude >= other.minimumLongitude &&
        minimumLongitude <= other.maximumLongitude
    }
}
