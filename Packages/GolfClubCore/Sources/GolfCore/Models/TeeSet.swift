//
//  TeeSet.swift
//  GolfCore
//
//  Created by Dragon Development on 09/07/2026.
//
import Foundation

public enum TeeColour: String, Codable, CaseIterable, Sendable {
    case black
    case blue
    case white
    case yellow
    case red
    case green
    case other
}

public struct TeeSet: Codable, Equatable, Sendable {
    public let id: TeeSetID
    public var colour: TeeColour
    public var name: String

    public init(
        id: TeeSetID = TeeSetID(),
        colour: TeeColour,
        name: String
    ) {
        self.id = id
        self.colour = colour
        self.name = name
    }
}
