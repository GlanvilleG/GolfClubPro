//
//  ActiveRoundSnapshotStoreTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class ActiveRoundSnapshotStoreTests:
    XCTestCase {

    func testSnapshotCanBeSavedAndLoaded()
        async throws {

        let store =
            InMemoryActiveRoundSnapshotStore()

        let snapshot = try makeSnapshot()

        try await store.save(snapshot)

        let restored =
            try await store.loadActiveRound(
                roundID: snapshot.round.id
            )

        XCTAssertEqual(restored, snapshot)
    }

    func testMostRecentActiveRoundIsReturned()
        async throws {

        let store =
            InMemoryActiveRoundSnapshotStore()

        var older = try makeSnapshot()
        older.capturedAt =
            Date().addingTimeInterval(-60)

        var newer = try makeSnapshot()
        newer.capturedAt = Date()

        try await store.save(older)
        try await store.save(newer)

        let restored =
            try await store
                .loadMostRecentActiveRound()

        XCTAssertEqual(
            restored?.round.id,
            newer.round.id
        )
    }

    func testCompletedRoundIsNotReturnedAsActive()
        async throws {

        let store =
            InMemoryActiveRoundSnapshotStore()

        var snapshot = try makeSnapshot()
        snapshot.round.state =
            .roundCompleted

        try await store.save(snapshot)

        let restored =
            try await store
                .loadMostRecentActiveRound()

        XCTAssertNil(restored)
    }

    func testSnapshotCanBeDeleted()
        async throws {

        let store =
            InMemoryActiveRoundSnapshotStore()

        let snapshot = try makeSnapshot()

        try await store.save(snapshot)

        try await store.deleteActiveRound(
            roundID: snapshot.round.id
        )

        let restored =
            try await store.loadActiveRound(
                roundID: snapshot.round.id
            )

        XCTAssertNil(restored)
    }

    func testPersistentCoordinatorSavesTransitions()
        async throws {

        let store =
            InMemoryActiveRoundSnapshotStore()

        let coordinator =
            PersistentOfflineRoundCoordinator(
                store: store
            )

        var snapshot =
            try await coordinator.startRound(
                playerID: PlayerID(),
                golfClubID: GolfClubID(),
                courseID: CourseID(),
                deviceID: DeviceID()
            )

        snapshot =
            try await coordinator.confirmTeeSet(
                TeeSetID(),
                in: snapshot
            )

        let restored =
            try await coordinator.restoreRound(
                roundID: snapshot.round.id
            )

        XCTAssertEqual(
            restored?.round.state,
            .awaitingHoleConfirmation
        )

        XCTAssertEqual(
            restored?.localRevision,
            snapshot.localRevision
        )
    }

    private func makeSnapshot()
        throws -> ActiveRoundSnapshot {

        try OfflineRoundCoordinator()
            .startRound(
                playerID: PlayerID(),
                golfClubID: GolfClubID(),
                courseID: CourseID(),
                deviceID: DeviceID()
            )
    }
}
