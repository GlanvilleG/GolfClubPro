//
//  Player.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Player: Codable, Equatable, Sendable {
    public let id: PlayerID
    public var dotGolfMemberID: DotGolfMemberID?
    public var name: String
    public var handicapIndex: Double?

    public init(
        id: PlayerID = PlayerID(),
        dotGolfMemberID: DotGolfMemberID? = nil,
        name: String,
        handicapIndex: Double? = nil
    ) {
        self.id = id
        self.dotGolfMemberID = dotGolfMemberID
        self.name = name
        self.handicapIndex = handicapIndex
    }
}
