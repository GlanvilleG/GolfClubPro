//
//  PersistentOfflineRoundCoordinator.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct PersistentOfflineRoundCoordinator:
    Sendable {

    private let coordinator:
        OfflineRoundCoordinator

    private let store:
        any ActiveRoundSnapshotStore

    public init(
        coordinator:
            OfflineRoundCoordinator =
                OfflineRoundCoordinator(),
        store:
            any ActiveRoundSnapshotStore
    ) {
        self.coordinator = coordinator
        self.store = store
    }

    public func startRound(
        playerID: PlayerID,
        golfClubID: GolfClubID,
        courseID: CourseID,
        deviceID: DeviceID
    ) async throws -> ActiveRoundSnapshot {
        let snapshot = try coordinator.startRound(
            playerID: playerID,
            golfClubID: golfClubID,
            courseID: courseID,
            deviceID: deviceID
        )

        try await store.save(snapshot)

        return snapshot
    }

    public func confirmTeeSet(
        _ teeSetID: TeeSetID,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.confirmTeeSet(
                teeSetID,
                in: snapshot
            )

        return try await save(updated)
    }

    public func confirmHole(
        _ holeID: HoleID,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.confirmHole(
                holeID,
                in: snapshot
            )

        return try await save(updated)
    }

    public func announceClub(
        _ clubID: ClubID,
        currentLocation:
            GeoCoordinate? = nil,
        courseGeometry:
            CourseGeometry? = nil,
        in snapshot:
            ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.announceClub(
                clubID,
                currentLocation:
                    currentLocation,
                courseGeometry:
                    courseGeometry,
                in: snapshot
            )

        return try await save(updated)
    }

    public func changeClub(
        to clubID: ClubID,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.changeClub(
                to: clubID,
                in: snapshot
            )

        return try await save(updated)
    }

    public func markShotHit(
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.markShotHit(
                in: snapshot
            )

        return try await save(updated)
    }

    public func recordShotFeedback(
        transcript: String,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.recordShotFeedback(
                transcript: transcript,
                in: snapshot
            )

        return try await save(updated)
    }

    public func confirmLie(
        _ playableLie: PlayableLie,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.confirmLie(
                playableLie,
                in: snapshot
            )

        return try await save(updated)
    }

    public func correctLie(
        _ playableLie: PlayableLie,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.correctLie(
                playableLie,
                in: snapshot
            )

        return try await save(updated)
    }

    public func recordPutts(
        _ putts: Int,
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.recordPutts(
                putts,
                in: snapshot
            )

        return try await save(updated)
    }

    public func leaveHolePending(
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.leaveHolePending(
                in: snapshot
            )

        return try await save(updated)
    }

    public func completeCurrentHole(
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.completeCurrentHole(
                in: snapshot
            )

        return try await save(updated)
    }

    public func finishRound(
        in snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        let updated =
            try coordinator.finishRound(
                in: snapshot
            )

        try await store.save(updated)

        return updated
    }

    public func restoreMostRecentActiveRound()
        async throws -> ActiveRoundSnapshot? {

        try await store
            .loadMostRecentActiveRound()
    }

    public func restoreRound(
        roundID: RoundID
    ) async throws -> ActiveRoundSnapshot? {

        try await store.loadActiveRound(
            roundID: roundID
        )
    }

    private func save(
        _ snapshot: ActiveRoundSnapshot
    ) async throws -> ActiveRoundSnapshot {
        try await store.save(snapshot)
        return snapshot
    }
}
