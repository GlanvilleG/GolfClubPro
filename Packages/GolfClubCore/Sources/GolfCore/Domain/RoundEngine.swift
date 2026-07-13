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
    case invalidState(expected: [RoundState], actual: RoundState)
    case noCompletedShot
    case invalidLieConfirmation
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

    public func confirmLie(
        _ playableLie: PlayableLie,
        forLastCompletedShotIn round: Round
    ) throws -> Round {
        try updateLastCompletedShot(
            in: round,
            playableLie: playableLie,
            source: .golferConfirmed
        )
    }

    public func correctLie(
        _ playableLie: PlayableLie,
        forLastCompletedShotIn round: Round
    ) throws -> Round {
        try updateLastCompletedShot(
            in: round,
            playableLie: playableLie,
            source: .golferCorrected
        )
    }
    
    private func updateLastCompletedShot(
        in round: Round,
        playableLie: PlayableLie,
        source: LieSource
    ) throws -> Round {
        try ensureRoundIsOpen(round)

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        guard let shotIndex = currentHole.shots.lastIndex(
            where: { $0.completedAt != nil }
        ) else {
            throw RoundEngineError.noCompletedShot
        }

        currentHole.shots[shotIndex].confirmedPlayableLie = playableLie
        currentHole.shots[shotIndex].lieSource = source

        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceHoleSession(
            in: updatedRound,
            with: currentHole
        )

        return updatedRound
    }
    
    public func confirmTeeSet(
        _ teeSetID: TeeSetID,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.roundActive, .awaitingHoleConfirmation])

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
        try ensure(round, isIn: [.roundActive, .awaitingHoleConfirmation, .holeCompleted, .holePendingCompletion])

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
        courseGeometry: HoleGeometry? = nil,
        using lieDetector: LieDetector = LieDetector(),
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(
            round,
            isIn: [.awaitingClub, .clubSelected, .awaitingBallPosition]
        )

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        if let lastShotIndex = currentHole.shots.lastIndex(
            where: { $0.completedAt == nil }
        ) {
            var completedShot = currentHole.shots[lastShotIndex]

            completedShot.endLocation = currentLocation
            completedShot.completedAt = Date()

            if let start = completedShot.startLocation,
               let end = currentLocation {
                completedShot.distanceMeters =
                    DistanceCalculator.distanceMeters(
                        from: start,
                        to: end
                    )
            }

            if let location = currentLocation,
               let geometry = courseGeometry {
                let result = lieDetector.detectLie(
                    at: location,
                    using: geometry
                )

                completedShot.inferredCourseArea = result.holeArea
                completedShot.inferredPlayableLie = result.playableLie
                completedShot.lieSource = result.source
                completedShot.lieDetectionConfidence = result.confidence
                completedShot.lieConfirmationRequirement = lieDetector.confirmationRequirement(for: result)
            }

            currentHole.shots[lastShotIndex] = completedShot
        }

        let newShot = Shot(
            roundID: updatedRound.id,
            holeID: currentHole.holeID,
            clubID: clubID,
            startLocation: currentLocation
        )

        currentHole.shots.append(newShot)
        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceHoleSession(
            in: updatedRound,
            with: currentHole
        )
        updatedRound.state = .clubSelected

        return updatedRound
    }

    public func changeClub(
        to clubID: ClubID,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.clubSelected])

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        guard let lastShotIndex = currentHole.shots.indices.last else {
            throw RoundEngineError.noClubSelected
        }

        guard currentHole.shots[lastShotIndex].completedAt == nil else {
            throw RoundEngineError.noShotInProgress
        }

        currentHole.shots[lastShotIndex].clubID = clubID

        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .clubSelected

        return updatedRound
    }

    public func markShotHit(
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.clubSelected])

        guard round.currentHoleSession != nil else {
            throw RoundEngineError.noActiveHole
        }

        var updatedRound = round
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
        try ensure(round, isIn: [.awaitingShotFeedback])

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
        updatedRound = replaceHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .awaitingBallPosition

        return updatedRound
    }
    public func recordShotFeedbackTranscript(
        _ transcript: String,
        using normalizer: ShotFeedbackNormalizer = ShotFeedbackNormalizer(),
        for round: Round
    ) throws -> Round {
        let feedback = normalizer.normalize(transcript)

        return try recordShotFeedback(
            rawTranscript: feedback.rawTranscript,
            classifiedErrors: feedback.classifiedErrors,
            sentiment: feedback.sentiment,
            for: round
        )
    }
    public func recordPutts(
        _ putts: Int,
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.awaitingClub, .clubSelected, .awaitingBallPosition, .putting])

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
        updatedRound = replaceHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .holePendingCompletion

        return updatedRound
    }

    public func completeCurrentHole(
        for round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.holePendingCompletion, .putting, .awaitingClub])

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
        try ensure(round, isIn: [.putting, .holePendingCompletion, .awaitingClub, .awaitingBallPosition])

        var updatedRound = round

        guard var currentHole = updatedRound.currentHoleSession else {
            throw RoundEngineError.noActiveHole
        }

        currentHole.status = .pendingCompletion
        updatedRound.currentHoleSession = currentHole
        updatedRound = replaceHoleSession(in: updatedRound, with: currentHole)
        updatedRound.state = .holePendingCompletion

        return updatedRound
    }

    public func finishRound(
        _ round: Round
    ) throws -> Round {
        try ensureRoundIsOpen(round)
        try ensure(round, isIn: [.holeCompleted, .holePendingCompletion, .roundActive, .awaitingHoleConfirmation])

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

    private func ensure(
        _ round: Round,
        isIn validStates: [RoundState]
    ) throws {
        guard validStates.contains(round.state) else {
            throw RoundEngineError.invalidState(
                expected: validStates,
                actual: round.state
            )
        }
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
