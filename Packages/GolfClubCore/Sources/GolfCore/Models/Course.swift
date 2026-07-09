//
//  Course.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Course: Codable, Equatable, Sendable {
    public let id: CourseID
    public var name: String
    public var holes: [Hole]
    public var teeSets: [TeeSet]

    public init(
        id: CourseID = CourseID(),
        name: String,
        holes: [Hole] = [],
        teeSets: [TeeSet] = []
    ) {
        self.id = id
        self.name = name
        self.holes = holes
        self.teeSets = teeSets
    }
}
