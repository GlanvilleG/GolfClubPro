//
//  HoleStrategyGeometry.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct HoleStrategyGeometry: Codable, Equatable, Sendable {
    public var holeID: HoleID
    public var centreLine: [GeoCoordinate]
    public var landingZones: [LandingZone]
    public var hazards: [HoleArea]
    public var greenCentre: GeoCoordinate
    public var pinLocation: GeoCoordinate?

    public init(
        holeID: HoleID,
        centreLine: [GeoCoordinate] = [],
        landingZones: [LandingZone] = [],
        hazards: [HoleArea] = [],
        greenCentre: GeoCoordinate,
        pinLocation: GeoCoordinate? = nil
    ) {
        self.holeID = holeID
        self.centreLine = centreLine
        self.landingZones = landingZones
        self.hazards = hazards
        self.greenCentre = greenCentre
        self.pinLocation = pinLocation
    }

    public var finalTarget: GeoCoordinate {
        pinLocation ?? greenCentre
    }
}
