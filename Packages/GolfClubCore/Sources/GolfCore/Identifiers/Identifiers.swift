//
//  Identifiers.swift
//  GolfCore
//
//  Created by Dragon Development on 08/07/2026.
//

import Foundation

public struct PlayerID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct DotGolfMemberID: Codable, Hashable, Sendable {
    public let value: String
    public init(_ value: String) { self.value = value }
}

public struct GolfClubID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct CourseID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct TeeSetID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct HoleID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct ClubID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct RoundID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct HoleSessionID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct ShotID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}
public struct TargetPointID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct LandingZoneID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct PlayingRouteID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}

public struct ShotPlanID: Codable, Hashable, Sendable {
    public let value: UUID
    public init(_ value: UUID = UUID()) { self.value = value }
}
public struct RecommendationAuditRecordID:
    Codable,
    Hashable,
    Sendable {

    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}
public struct OfflineEventID:
    Codable,
    Hashable,
    Sendable {

    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}

public struct DeviceID:
    Codable,
    Hashable,
    Sendable {

    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
}
