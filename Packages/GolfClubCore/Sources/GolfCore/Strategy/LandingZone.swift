//
//  LandingZone.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct LandingZone: Codable, Equatable, Sendable {
    public let id: LandingZoneID
    public var centre: GeoCoordinate
    public var boundary: [GeoCoordinate]
    public var priority: Int
    public var recommendedForShotNumber: Int?
    public var riskRating: Double
    public var label: String?

    public init(
        id: LandingZoneID = LandingZoneID(),
        centre: GeoCoordinate,
        boundary: [GeoCoordinate] = [],
        priority: Int = 0,
        recommendedForShotNumber: Int? = nil,
        riskRating: Double = 0.5,
        label: String? = nil
    ) {
        self.id = id
        self.centre = centre
        self.boundary = boundary
        self.priority = priority
        self.recommendedForShotNumber = recommendedForShotNumber
        self.riskRating = min(1, max(0, riskRating))
        self.label = label
    }
}
