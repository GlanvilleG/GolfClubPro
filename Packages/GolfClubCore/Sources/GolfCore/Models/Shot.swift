//
//  Shot.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public enum Lie: String, Codable, CaseIterable, Sendable {
    case tee
    case fairway
    case rough
    case sand
    case fringe
    case green
    case recovery
    case penalty
    case unknown
}

public struct Shot: Codable, Equatable, Sendable {
    public let id: ShotID
    public var roundID: RoundID
    public var holeID: HoleID
    public var clubID: ClubID
    public var startedAt: Date
    public var completedAt: Date?
    public var startLocation: GeoCoordinate?
    public var endLocation: GeoCoordinate?
    public var distanceMeters: Double?
    public var lie: Lie?
    public var feedback: ShotFeedback?

    public init(
        id: ShotID = ShotID(),
        roundID: RoundID,
        holeID: HoleID,
        clubID: ClubID,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        startLocation: GeoCoordinate? = nil,
        endLocation: GeoCoordinate? = nil,
        distanceMeters: Double? = nil,
        lie: Lie? = nil,
        feedback: ShotFeedback? = nil
    ) {
        self.id = id
        self.roundID = roundID
        self.holeID = holeID
        self.clubID = clubID
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.distanceMeters = distanceMeters
        self.lie = lie
        self.feedback = feedback
    }
}
