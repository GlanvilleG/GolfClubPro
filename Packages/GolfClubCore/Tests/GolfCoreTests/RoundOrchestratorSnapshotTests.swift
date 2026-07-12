//
//  RoundOrchestratorSnapshotTests.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import XCTest
@testable import GolfCore

final class RoundOrchestratorSnapshotTests:
    XCTestCase {

    func testSnapshotStoresCurrentState()
        async throws {

        let setup = try await makeSetup()

        _ = try await setup.orchestrator.process(
            .clubSelected(ClubID())
        )

        let snapshot =
            await setup.orchestrator.makeSnapshot()

        XCTAssertEqual(
            snapshot.state,
            .clubSelected
        )

        XCTAssertEqual(
            snapshot.roundID,
            setup.activeSnapshot.round.id
        )
    }

    func testUnresolvedCandidateSwingIsPersisted()
        async throws {

        let setup = try await makeSetup()

        _ = try await setup.orchestrator.process(
            .clubSelected(ClubID())
        )

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .impactDetected(
                ImpactObservation(
                    confidence: 0.8
                )
            )
        )

       let stored = try await setup.snapshotStore.load(
                roundID: setup.activeSnapshot.round.id
            )

            let candidate = try XCTUnwrap(
                stored?.candidateSwing
            )

            XCTAssertEqual(
                candidate.classification,
                .uncertain
            )

            XCTAssertEqual(
                candidate.computedConfidence,
                0.44,
                accuracy: 0.0001
            )

            XCTAssertEqual(
                stored?.state,
                .awaitingShotConfirmation
            )
            

        XCTAssertEqual(
            stored?.state,
            .awaitingShotConfirmation
        )

        XCTAssertTrue(
            stored?
                .hasUnresolvedCandidateSwing ==
            true
        )
    }

    func testRestoredOrchestratorRecoversCandidate()
        async throws {

        let setup = try await makeSetup()

        _ = try await setup.orchestrator.process(
            .clubSelected(ClubID())
        )

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .impactDetected(
                ImpactObservation(
                    confidence: 0.8
                )
            )
        )

        let restored =
            try await RoundOrchestrator.restoring(
                activeSnapshot:
                    await setup.orchestrator
                        .currentSnapshot(),
                coordinator:
                    setup.coordinator,
                snapshotStore:
                    setup.snapshotStore
            )

        let restoredState =
            await restored.currentState()

        let restoredCandidate =
            await restored.currentCandidateSwing()

        XCTAssertEqual(
            restoredState,
            .awaitingShotConfirmation
        )

        XCTAssertNotNil(restoredCandidate)
    }

    func testPracticeSwingClearsCandidateBeforePersistence()
        async throws {

        let setup = try await makeSetup()

        _ = try await setup.orchestrator.process(
            .clubSelected(ClubID())
        )

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 0.8,
                    returnedToAddress: true,
                    confidence: 0.4
                )
            )
        )

        let stored =
            try await setup.snapshotStore.load(
                roundID:
                    setup.activeSnapshot.round.id
            )

        XCTAssertNil(stored?.candidateSwing)

        XCTAssertEqual(
            stored?.state,
            .awaitingCommittedSwing
        )
    }

    func testRestoreRejectsDifferentRound()
        async throws {

        let setup = try await makeSetup()

        let invalidSnapshot =
            RoundOrchestratorSnapshot(
                roundID: RoundID(),
                state: .recovering
            )

        do {
            try await setup.orchestrator.restore(
                from: invalidSnapshot
            )

            XCTFail(
                "Expected roundIdentifierMismatch"
            )
        } catch let error
            as RoundOrchestratorError {

            XCTAssertEqual(
                error,
                .roundIdentifierMismatch
            )
        }
    }

    private func makeSetup()
        async throws -> (
            orchestrator: RoundOrchestrator,
            coordinator:
                PersistentOfflineRoundCoordinator,
            snapshotStore:
                InMemoryRoundOrchestratorSnapshotStore,
            activeSnapshot:
                ActiveRoundSnapshot
        ) {

        let roundStore =
            InMemoryActiveRoundSnapshotStore()

        let coordinator =
            PersistentOfflineRoundCoordinator(
                store: roundStore
            )

        var activeSnapshot =
            try await coordinator.startRound(
                playerID: PlayerID(),
                golfClubID: GolfClubID(),
                courseID: CourseID(),
                deviceID: DeviceID()
            )

        activeSnapshot =
            try await coordinator.confirmTeeSet(
                TeeSetID(),
                in: activeSnapshot
            )

        activeSnapshot =
            try await coordinator.confirmHole(
                HoleID(),
                in: activeSnapshot
            )

        let snapshotStore =
            InMemoryRoundOrchestratorSnapshotStore()

        let orchestrator =
            RoundOrchestrator(
                snapshot: activeSnapshot,
                coordinator: coordinator,
                snapshotStore: snapshotStore
            )

        return (
            orchestrator,
            coordinator,
            snapshotStore,
            activeSnapshot
        )
    }
}
