//
//  OfflineRoundCoordinator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum OfflineRoundCoordinatorError:
    Error,
    Equatable,
    Sendable {

    case roundIdentifierMismatch
    case unableToEncodePayload
}

public struct OfflineRoundCoordinator: Sendable {

    private let roundEngine: RoundEngine
    private let eventQueue: OfflineEventQueue

    public init(
        roundEngine: RoundEngine = RoundEngine(),
        eventQueue: OfflineEventQueue = OfflineEventQueue()
    ) {
        self.roundEngine = roundEngine
        self.eventQueue = eventQueue
    }

    // MARK: - Round Start

    public func startRound(
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID,
        deviceID: DeviceID
    ) throws -> ActiveRoundSnapshot {
        let round = roundEngine.startRound(
            playerID: playerID,
            golfClubID: golfClubID,
            courseID: courseID
        )

        let payload = try encode(round)

        let events = eventQueue.enqueue(
            type: .roundStarted,
            roundID: round.id,
            entityID: round.id.value.uuidString,
            deviceID: deviceID,
            payload: payload,
            into: []
        )

        return ActiveRoundSnapshot(
            round: round,
            deviceID: deviceID,
            pendingEvents: events
        )
    }

    // MARK: - Tee Set

    public func confirmTeeSet(
        _ teeSetID: TeeSetID,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.confirmTeeSet(
            teeSetID,
            for: snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .teeSetConfirmed,
            entityID: teeSetID.value.uuidString,
            payload: teeSetID
        )
    }

    // MARK: - Hole

    public func confirmHole(
        _ holeID: HoleID,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.confirmHole(
            holeID: holeID,
            for: snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .holeConfirmed,
            entityID: holeID.value.uuidString,
            payload: holeID
        )
    }

    // MARK: - Club Selection

    public func announceClub(
        _ clubID: ClubID,
        currentLocation: GeoCoordinate? = nil,
        courseGeometry: HoleGeometry? = nil,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let previousShotIDs = currentShotIDs(
            in: snapshot.round
        )

        let updatedRound = try roundEngine.announceClub(
            clubID: clubID,
            currentLocation: currentLocation,
            courseGeometry: courseGeometry,
            for: snapshot.round
        )

        let newShotID = newlyCreatedShotID(
            before: previousShotIDs,
            after: currentShotIDs(in: updatedRound)
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .clubSelected,
            entityID:
                newShotID?.value.uuidString ??
                clubID.value.uuidString,
            payload: updatedRound.currentHoleSession
        )
    }

    public func changeClub(
        to clubID: ClubID,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.changeClub(
            to: clubID,
            for: snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .clubChanged,
            entityID: clubID.value.uuidString,
            payload: updatedRound.currentHoleSession
        )
    }

    // MARK: - Shot

    public func markShotHit(
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.markShotHit(
            for: snapshot.round
        )

        let shotID = updatedRound
            .currentHoleSession?
            .shots
            .last?
            .id

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .shotStarted,
            entityID: shotID?.value.uuidString,
            payload: updatedRound.currentHoleSession?.shots.last
        )
    }

    public func recordShotFeedback(
        transcript: String,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound =
            try roundEngine.recordShotFeedbackTranscript(
                transcript,
                for: snapshot.round
            )

        let shot = updatedRound
            .currentHoleSession?
            .shots
            .last

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .shotFeedbackRecorded,
            entityID: shot?.id.value.uuidString,
            payload: shot?.feedback
        )
    }

    // MARK: - Lie

    public func confirmLie(
        _ playableLie: PlayableLie,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.confirmLie(
            playableLie,
            forLastCompletedShotIn: snapshot.round
        )

        let shot = lastCompletedShot(
            in: updatedRound
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .lieConfirmed,
            entityID: shot?.id.value.uuidString,
            payload: shot
        )
    }

    public func correctLie(
        _ playableLie: PlayableLie,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.correctLie(
            playableLie,
            forLastCompletedShotIn: snapshot.round
        )

        let shot = lastCompletedShot(
            in: updatedRound
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .lieCorrected,
            entityID: shot?.id.value.uuidString,
            payload: shot
        )
    }

    // MARK: - Putting and Hole Completion

    public func recordPutts(
        _ putts: Int,
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.recordPutts(
            putts,
            for: snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .puttsRecorded,
            entityID:
                updatedRound.currentHoleSession?
                    .id.value.uuidString,
            payload: updatedRound.currentHoleSession
        )
    }

    public func leaveHolePending(
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.leaveHolePending(
            for: snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .holePending,
            entityID:
                updatedRound.currentHoleSession?
                    .id.value.uuidString,
            payload: updatedRound.currentHoleSession
        )
    }

    public func completeCurrentHole(
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let previousHoleSession =
            snapshot.round.currentHoleSession

        let updatedRound =
            try roundEngine.completeCurrentHole(
                for: snapshot.round
            )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .holeCompleted,
            entityID:
                previousHoleSession?
                    .id.value.uuidString,
            payload: previousHoleSession
        )
    }

    // MARK: - Round Completion

    public func finishRound(
        in snapshot: ActiveRoundSnapshot
    ) throws -> ActiveRoundSnapshot {
        let updatedRound = try roundEngine.finishRound(
            snapshot.round
        )

        return try updateSnapshot(
            snapshot,
            with: updatedRound,
            eventType: .roundCompleted,
            entityID: updatedRound.id.value.uuidString,
            payload: updatedRound
        )
    }

    // MARK: - Snapshot Cache Updates

    public func cacheCourseGeometry(
        _ geometry: HoleGeometry,
        in snapshot: ActiveRoundSnapshot
    ) -> ActiveRoundSnapshot {
        var updated = snapshot
        updated.cachedCourseGeometry = geometry
        updated.capturedAt = Date()
        updated.localRevision += 1
        return updated
    }

    public func cacheStrategyGeometry(
        _ geometry: HoleStrategyGeometry,
        in snapshot: ActiveRoundSnapshot
    ) -> ActiveRoundSnapshot {
        var updated = snapshot
        updated.cachedStrategyGeometry = geometry
        updated.capturedAt = Date()
        updated.localRevision += 1
        return updated
    }

    public func cacheWeatherSnapshot(
        _ weatherSnapshot: WeatherSnapshot,
        in snapshot: ActiveRoundSnapshot
    ) -> ActiveRoundSnapshot {
        var updated = snapshot
        updated.cachedWeatherSnapshot = weatherSnapshot
        updated.capturedAt = Date()
        updated.localRevision += 1
        return updated
    }

    // MARK: - Private Helpers

    private func updateSnapshot<Payload: Encodable>(
        _ snapshot: ActiveRoundSnapshot,
        with updatedRound: Round,
        eventType: OfflineEventType,
        entityID: String?,
        payload: Payload?
    ) throws -> ActiveRoundSnapshot {
        guard updatedRound.id == snapshot.round.id else {
            throw OfflineRoundCoordinatorError
                .roundIdentifierMismatch
        }

        let encodedPayload: Data?

        if let payload {
            encodedPayload = try encode(payload)
        } else {
            encodedPayload = nil
        }

        let updatedEvents = eventQueue.enqueue(
            type: eventType,
            roundID: updatedRound.id,
            entityID: entityID,
            deviceID: snapshot.deviceID,
            payload: encodedPayload,
            into: snapshot.pendingEvents
        )

        var updatedSnapshot = snapshot
        updatedSnapshot.round = updatedRound
        updatedSnapshot.pendingEvents = updatedEvents
        updatedSnapshot.capturedAt = Date()
        updatedSnapshot.localRevision += 1

        return updatedSnapshot
    }

    private func encode<T: Encodable>(
        _ value: T
    ) throws -> Data {
        do {
            return try JSONEncoder().encode(value)
        } catch {
            throw OfflineRoundCoordinatorError
                .unableToEncodePayload
        }
    }

    private func currentShotIDs(
        in round: Round
    ) -> Set<ShotID> {
        Set(
            round.currentHoleSession?
                .shots
                .map(\.id) ?? []
        )
    }

    private func newlyCreatedShotID(
        before: Set<ShotID>,
        after: Set<ShotID>
    ) -> ShotID? {
        after.subtracting(before).first
    }

    private func lastCompletedShot(
        in round: Round
    ) -> Shot? {
        round.currentHoleSession?
            .shots
            .last(where: { $0.completedAt != nil })
    }
}
