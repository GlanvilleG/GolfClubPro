//
//  Hole.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Hole: Codable, Equatable, Sendable {
    public let id: HoleID
    public var number: Int
    public var par: Int
    public var strokeIndex: Int?
    public var lengthMeters: Double
    public var teeLocation: GeoCoordinate?
    public var greenLocation: GeoCoordinate?

    public init(
        id: HoleID = HoleID(),
        number: Int,
        par: Int,
        strokeIndex: Int? = nil,
        lengthMeters: Double,
        teeLocation: GeoCoordinate? = nil,
        greenLocation: GeoCoordinate? = nil
    ) {
        self.id = id
        self.number = number
        self.par = par
        self.strokeIndex = strokeIndex
        self.lengthMeters = lengthMeters
        self.teeLocation = teeLocation
        self.greenLocation = greenLocation
    }
}
