//
//  Club.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public enum ClubType: String, Codable, CaseIterable, Sendable {
    case driver
    case fairwayWood
    case hybrid
    case iron
    case wedge
    case putter
}

public struct Club: Codable, Equatable, Sendable {
    public let id: ClubID
    public var name: String
    public var type: ClubType
    public var loftDegrees: Double?
    public var averageCarryMeters: Double?

    public init(
        id: ClubID = ClubID(),
        name: String,
        type: ClubType,
        loftDegrees: Double? = nil,
        averageCarryMeters: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.loftDegrees = loftDegrees
        self.averageCarryMeters = averageCarryMeters
    }
}
