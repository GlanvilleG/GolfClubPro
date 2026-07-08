//
//  Course.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Course: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var holes: [Hole]

    public init(
        id: UUID = UUID(),
        name: String,
        holes: [Hole]
    ) {
        self.id = id
        self.name = name
        self.holes = holes
    }
}
