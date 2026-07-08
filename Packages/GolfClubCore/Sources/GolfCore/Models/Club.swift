//
//  Club.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public enum ClubType: String, Codable, CaseIterable {
    case driver
    case fairwayWood
    case hybrid
    case iron
    case wedge
    case putter
}

public struct Club: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var type: ClubType
    public var averageCarryMeters: Double?

    public init(
        id: UUID = UUID(),
        name: String,
        type: ClubType,
        averageCarryMeters: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.averageCarryMeters = averageCarryMeters
    }
}
