//
//  SwiftDataActiveRoundSnapshotStoreTests.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
import SwiftData
import GolfCore
@testable import GolfClubPro

final class SwiftDataActiveRoundSnapshotStoreTests:
    XCTestCase {

    func testSnapshotPersistsAndRestores()
        async throws {

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: ActiveRoundSnapshotRecord.self,
            configurations: configuration
        )

        let store =
            SwiftDataActiveRoundSnapshotStore(
                modelContainer: container
            )

        let snapshot =
            try OfflineRoundCoordinator()
                .startRound(
                    playerID: PlayerID(),
                    golfClubID: GolfClubID(),
                    courseID: CourseID(),
                    deviceID: DeviceID()
                )

        try await store.save(snapshot)

        let restored =
            try await store.loadActiveRound(
                roundID: snapshot.round.id
            )

        XCTAssertEqual(restored, snapshot)
    }

    func testMostRecentActiveRoundIsRestored()
        async throws {

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: ActiveRoundSnapshotRecord.self,
            configurations: configuration
        )

        let store =
            SwiftDataActiveRoundSnapshotStore(
                modelContainer: container
            )

        var older =
            try OfflineRoundCoordinator()
                .startRound(
                    playerID: PlayerID(),
                    golfClubID: GolfClubID(),
                    courseID: CourseID(),
                    deviceID: DeviceID()
                )

        older.capturedAt =
            Date().addingTimeInterval(-60)

        var newer =
            try OfflineRoundCoordinator()
                .startRound(
                    playerID: PlayerID(),
                    golfClubID: GolfClubID(),
                    courseID: CourseID(),
                    deviceID: DeviceID()
                )

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

    func testSnapshotCanBeDeleted()
        async throws {

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: ActiveRoundSnapshotRecord.self,
            configurations: configuration
        )

        let store =
            SwiftDataActiveRoundSnapshotStore(
                modelContainer: container
            )

        let snapshot =
            try OfflineRoundCoordinator()
                .startRound(
                    playerID: PlayerID(),
                    golfClubID: GolfClubID(),
                    courseID: CourseID(),
                    deviceID: DeviceID()
                )

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
}
