//
//  SwiftDataRoundOrchestratorSnapshotStoreTests.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//
import GolfCore
import SwiftData
import XCTest
@testable import GolfClubPro

final class SwiftDataRoundOrchestratorSnapshotStoreTests:
    XCTestCase {

    func testSnapshotCanBeSavedAndLoaded()
        async throws {

        let setup = try makeStore()

        let snapshot =
            RoundOrchestratorSnapshot(
                roundID: RoundID(),
                state:
                    .awaitingShotConfirmation,
                candidateSwing:
                    makeCandidateSwing()
            )

        try await setup.store.save(snapshot)

        let restored =
            try await setup.store.load(
                roundID: snapshot.roundID
            )

        XCTAssertEqual(
            restored,
            snapshot
        )
    }

    func testSavingAgainUpdatesExistingRecord()
        async throws {

        let setup = try makeStore()
        let roundID = RoundID()

        let original =
            RoundOrchestratorSnapshot(
                roundID: roundID,
                state: .clubSelected,
                localRevision: 1
            )

        let updated =
            RoundOrchestratorSnapshot(
                roundID: roundID,
                state:
                    .awaitingShotConfirmation,
                candidateSwing:
                    makeCandidateSwing(),
                localRevision: 2
            )

        try await setup.store.save(original)
        try await setup.store.save(updated)

        let restored =
            try await setup.store.load(
                roundID: roundID
            )

        XCTAssertEqual(
            restored?.state,
            .awaitingShotConfirmation
        )

        XCTAssertEqual(
            restored?.localRevision,
            2
        )

        XCTAssertNotNil(
            restored?.candidateSwing
        )
    }

    func testSnapshotCanBeDeleted()
        async throws {

        let setup = try makeStore()

        let snapshot =
            RoundOrchestratorSnapshot(
                roundID: RoundID(),
                state: .walkingToBall
            )

        try await setup.store.save(snapshot)

        try await setup.store.delete(
            roundID: snapshot.roundID
        )

        let restored =
            try await setup.store.load(
                roundID: snapshot.roundID
            )

        XCTAssertNil(restored)
    }

    private func makeStore() throws -> (
        container: ModelContainer,
        store:
            SwiftDataRoundOrchestratorSnapshotStore
    ) {
        let configuration =
            ModelConfiguration(
                isStoredInMemoryOnly: true
            )

        let container = try ModelContainer(
            for:
                ActiveRoundSnapshotRecord.self,
                RoundOrchestratorSnapshotRecord.self,
            configurations: configuration
        )

        let store =
            SwiftDataRoundOrchestratorSnapshotStore(
                modelContainer: container
            )

        return (
            container,
            store
        )
    }

    private func makeCandidateSwing()
        -> CandidateSwing {

        CandidateSwing(
            observation:
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                ),
            impactDetected: true,
            impactConfidence: 0.8,
            computedConfidence: 0.44,
            classification: .uncertain
        )
    }
}
