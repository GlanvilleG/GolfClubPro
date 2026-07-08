//
//  Player.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Player: Identifiable, Codable, Equatable {
    public let id: UUID
    public var dotGolfNumber: String?
    public var name: String
    public var handicapIndex: Double?

    public init(
        id: UUID = UUID(),
        dotGolfNumber: String? = nil,
        name: String,
        handicapIndex: Double? = nil
    ) {
        self.id = id
        self.dotGolfNumber = dotGolfNumber
        self.name = name
        self.handicapIndex = handicapIndex
    }
}
