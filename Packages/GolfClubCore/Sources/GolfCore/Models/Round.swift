//
//  Round.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public enum RoundState: String, Codable, Sendable {
    case idle
    case golfClubDetected
    case roundReadyToStart
    case roundActive
    case awaitingHoleConfirmation
    case holeActive
    case awaitingClub
    case clubSelected
    case shotInProgress
    case awaitingShotFeedback
    case awaitingBallPosition
    case putting
    case holePendingCompletion
    case holeCompleted
    case roundCompleted
}

public enum HoleCompletionStatus: String, Codable, Sendable {
    case notStarted
    case active
    case pendingCompletion
    case completed
}

public struct HoleSession: Codable, Equatable, Sendable {
    public let id: HoleSessionID
    public var roundID: RoundID
    public var holeID: HoleID
    public var status: HoleCompletionStatus
    public var shots: [Shot]
    public var putts: Int?

    public init(
        id: HoleSessionID = HoleSessionID(),
        roundID: RoundID,
        holeID: HoleID,
        status: HoleCompletionStatus = .active,
        shots: [Shot] = [],
        putts: Int? = nil
    ) {
        self.id = id
        self.roundID = roundID
        self.holeID = holeID
        self.status = status
        self.shots = shots
        self.putts = putts
    }
}

public struct Round: Codable, Equatable, Sendable {
    public let id: RoundID
    public var playerID: PlayerID
    public var golfClubID: GolfClubID
    public var courseID: CourseID
    public var teeSetID: TeeSetID?
    public var state: RoundState
    public var startedAt: Date
    public var completedAt: Date?
    public var currentHoleSession: HoleSession?
    public var holeSessions: [HoleSession]

    public init(
        id: RoundID = RoundID(),
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID,
        teeSetID: TeeSetID? = nil,
        state: RoundState = .roundActive,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        currentHoleSession: HoleSession? = nil,
        holeSessions: [HoleSession] = []
    ) {
        self.id = id
        self.playerID = playerID
        self.golfClubID = golfClubID
        self.courseID = courseID
        self.teeSetID = teeSetID
        self.state = state
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.currentHoleSession = currentHoleSession
        self.holeSessions = holeSessions
    }
}
