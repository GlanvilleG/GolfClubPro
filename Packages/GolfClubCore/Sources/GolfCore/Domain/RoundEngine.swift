//
//  RoundEngine.swift
//  GolfCore
//
//  Created by Dragon Development on 08/07/2026.
//

import Foundation

public enum RoundEngineError: Error, Equatable, Sendable {
    case roundAlreadyCompleted
    case noActiveHole
    case noClubSelected
    case noShotInProgress
    case invalidPuttCount
}

public struct RoundEngine: Sendable {

    public init() {}

    public func startRound(
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID
    ) -> Round {
        Round(
            playerID: playerID,
            golfClubID: golfClubID,
            courseID: courseID,
            state: .roundActive
        )
    }

    public func confirmTeeSet(
        _ teeSetID: TeeSetID,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round
        updatedRound.teeSetID = teeSetID
        updatedRound.state = .awaitingHoleConfirmation
        return updatedRound
    }

    public func confirmHole(
        holeID: HoleID,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        let holeSession = HoleSession(
            roundID: round.id,
            holeID: holeID,
            status: .active
        )

        updatedRound.currentHoleSession = holeSession
        updatedRound.holeSessions.append(holeSession)
        updatedRound.state = .awaitingClub

        return updatedRound
    }

    public func announceClub(
        clubID: ClubID,
        currentLocation: GeoCoordinate? = nil,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        if let lastShotIndex = currentHole.shots.lastIndex(where: { $0.completedAt == nil }) {
            var completedShot = currentHole.shots[lastShotIndex]
            completedShot.endLocation = currentLocation
            completedShot.completedAt = Date()

            if let start = completedShot.startLocation, let end = currentLocation {
                completedShot.distanceMeters = DistanceCalculator.distanceMeters(
                    from: start,
                    to: end
                )
            }

            currentHole.shots[lastShotIndex] = completedShot
        }

        let newShot = Shot(
            roundID: updatedRound.id,
            holeID: currentHole.holeID,
            clubID: clubID,
            startLocation: currentLocation,
            lie: nil
        )

        currentHole.shots.append(newShot)
        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceCurrentHoleSession(in: updatedRound, with: currentHole)

        updatedRound.state = .clubSelected

        return updatedRound
    }

    public func changeClub(
        to clubID: ClubID,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        guard let lastShotIndex = currentHole.shots.indices.last else {
            throw RoundEngineError.noClubSelected
        }

        var shot = currentHole.shots[lastShotIndex]
        shot.clubID = clubID
        currentHole.shots[lastShotIndex] = shot

        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceCurrentHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .clubSelected

        return updatedRound
    }

    public func markShotHit(
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard updatedRound.currentHoleSession != nil else {
            throw RoundEngineError.noActiveHole
        }

        updatedRound.state = .awaitingShotFeedback
        return updatedRound
    }

    public func recordShotFeedback(
        rawTranscript: String,
        classifiedErrors: [ShotError] = [],
        sentiment: ShotSentiment? = nil,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        guard let lastShotIndex = currentHole.shots.indices.last else {
            throw RoundEngineError.noShotInProgress
        }

        var shot = currentHole.shots[lastShotIndex]
        shot.feedback = ShotFeedback(
            rawTranscript: rawTranscript,
            classifiedErrors: classifiedErrors,
            sentiment: sentiment
        )

        currentHole.shots[lastShotIndex] = shot
        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceCurrentHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .awaitingBallPosition

        return updatedRound
    }

    public func recordPutts(
        _ putts: Int,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        guard putts >= 0 else {
            throw RoundEngineError.invalidPuttCount
        }

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        currentHole.putts = putts
        currentHole.status = .pendingCompletion

        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceCurrentHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .holePendingCompletion

        return updatedRound
    }

    public func completeCurrentHole(
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        currentHole.status = .completed
        updatedRound.currentHoleSession = nil
        updatedRound = replaceHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .holeCompleted

        return updatedRound
    }

    public func leaveHolePending(
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        currentHole.status = .pendingCompletion
        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceCurrentHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .holePendingCompletion

        return updatedRound
    }

    public func finishRound(
        _ round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round
        updatedRound.completedAt = Date()
        updatedRound.state = .roundCompleted

        return updatedRound
    }

    private func ensureRoundIsOpen(_ round: Round) throws {
        if round.state == .roundCompleted {
            throw RoundEngineError.roundAlreadyCompleted
        }
    }

    private func replaceCurrentHoleSession(
        in round: Round,
        with holeSession: HoleSession
    ) -> Round {
        replaceHoleSession(in: round, with: holeSession)
    }

    private func replaceHoleSession(
        in round: Round,
        with holeSession: HoleSession
    ) -> Round {
        var updatedRound = round

        if let index = updatedRound.holeSessions.firstIndex(where: { $0.id == holeSession.id }) {
            updatedRound.holeSessions[index] = holeSession
        } else {
            updatedRound.holeSessions.append(holeSession)
        }

        return updatedRound
    }
}
