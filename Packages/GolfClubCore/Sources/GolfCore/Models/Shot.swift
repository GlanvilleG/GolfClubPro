//
//  Shot.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Shot: Identifiable, Codable, Equatable {
    public let id: UUID
    public var holeNumber: Int
    public var club: Club
    public var distanceMeters: Double?
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        holeNumber: Int,
        club: Club,
        distanceMeters: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.holeNumber = holeNumber
        self.club = club
        self.distanceMeters = distanceMeters
        self.timestamp = timestamp
    }
}
