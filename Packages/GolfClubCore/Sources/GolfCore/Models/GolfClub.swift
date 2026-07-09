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

    public init(
        id: GolfClubID = GolfClubID(),
        name: String,
        location: GeoCoordinate,
        courses: [Course] = []
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.courses = courses
    }
}
