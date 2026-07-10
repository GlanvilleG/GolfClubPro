//
//  LocationObservation.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct LocationObservation:
    Codable,
    Equatable,
    Sendable {

    public var coordinate: GeoCoordinate
    public var observedAt: Date
    public var horizontalAccuracyMeters: Double?

    public init(
        coordinate: GeoCoordinate,
        observedAt: Date = Date(),
        horizontalAccuracyMeters: Double? = nil
    ) {
        self.coordinate = coordinate
        self.observedAt = observedAt
        self.horizontalAccuracyMeters =
            horizontalAccuracyMeters.map { max(0, $0) }
    }
}
