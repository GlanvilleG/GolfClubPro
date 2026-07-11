//
//  GolfClub.swift
//  GolfCore
//
//  Created by Dragon Development on 09/07/2026.
//

import Foundation

public struct GolfClub: Codable, Equatable, Sendable {
    public let id: GolfClubID
    public var name: String
    public var location: GeoCoordinate
    public var courses: [Course]
    public var detectionRadiusMeters: Double

    public init(
        id: GolfClubID = GolfClubID(),
        name: String,
        location: GeoCoordinate,
        detectionRadiusMeters: Double = 1_000,
        courses: [Course] = []
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.detectionRadiusMeters =
            max(0, detectionRadiusMeters)
        self.courses = courses
    }
}
