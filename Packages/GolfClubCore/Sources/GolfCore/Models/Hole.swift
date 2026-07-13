//
//  Hole.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//

import Foundation

public struct Hole:
    Codable,
    Equatable,
    Sendable {

    public let id: HoleID

    public var number: Int
    public var par: Int
    public var strokeIndex: Int?
    public var lengthMeters: Double

    public var teeLocation: GeoCoordinate?
    public var greenLocation: GeoCoordinate?

    public var teeDetectionRadiusMeters: Double

    /// Spatial representation of the hole.
    /// Contains fairway, green, bunker, rough, water,
    /// penalty areas and other mapped geometry used by
    /// the AI Caddie and Lie Detector.
    /// Spatial representation of this hole.
    public var geometry: HoleGeometry?

    public init(
        id: HoleID = HoleID(),
        number: Int,
        par: Int,
        strokeIndex: Int? = nil,
        lengthMeters: Double,
        teeLocation: GeoCoordinate? = nil,
        greenLocation: GeoCoordinate? = nil,
        teeDetectionRadiusMeters: Double = 35,
        geometry: HoleGeometry? = nil
    ) {
        self.id = id
        self.number = number
        self.par = par
        self.strokeIndex = strokeIndex
        self.lengthMeters = lengthMeters

        self.teeLocation = teeLocation
        self.greenLocation = greenLocation

        self.teeDetectionRadiusMeters =
            max(0, teeDetectionRadiusMeters)

        self.geometry = geometry
    }
}
