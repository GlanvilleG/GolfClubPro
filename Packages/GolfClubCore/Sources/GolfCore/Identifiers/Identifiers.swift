//
//  Identifiers.swift
//  GolfCore
//
//  Created by Dragon Development on 08/07/2026.
//

import Foundation

public struct PlayerID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct DotGolfMemberID: Codable, Hashable, Sendable {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}

public struct CourseID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct HoleID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct ClubID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct RoundID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct ShotID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}
