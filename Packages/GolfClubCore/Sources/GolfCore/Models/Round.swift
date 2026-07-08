//
//  Round.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Round: Identifiable, Codable, Equatable {
    public let id: UUID
    public var player: Player
    public var course: Course
    public var shots: [Shot]
    public var startedAt: Date
    public var completedAt: Date?

    public init(
        id: UUID = UUID(),
        player: Player,
        course: Course,
        shots: [Shot] = [],
        startedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.player = player
        self.course = course
        self.shots = shots
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}
