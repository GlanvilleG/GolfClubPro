//
//  HoleGeometryIndexConfiguratio.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct HoleGeometryIndexConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var teeRadiusMeters:
        Double

    public var greenRadiusMeters:
        Double

    public var maximumHoleDistanceMeters:
        Double

    public init(
        teeRadiusMeters: Double = 35,
        greenRadiusMeters: Double = 25,
        maximumHoleDistanceMeters: Double = 250
    ) {
        self.teeRadiusMeters =
            max(0, teeRadiusMeters)

        self.greenRadiusMeters =
            max(0, greenRadiusMeters)

        self.maximumHoleDistanceMeters =
            max(0, maximumHoleDistanceMeters)
    }
}
