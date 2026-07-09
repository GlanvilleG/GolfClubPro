//
//  GeoCoordinate.swift
//  GolfCore
//
//  Created by Dragon Development on 09/07/2026.
//

import Foundation

public struct GeoCoordinate: Codable, Equatable, Sendable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
