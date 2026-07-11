//
//  RoundOrchestratorDetectionTests.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import XCTest
@testable import GolfCore

final class RoundOrchestratorDetectionTests:
    XCTestCase {

    func testDetectedHoleRequestsConfirmation()
        async throws {

        let setup = try await makeSetup()
        let holeID = HoleID()

        let result = HoleDetectionResult(
            status: .detected,
            selectedHoleID: holeID,
            confidence: 0.88,
            candidates: [
                HoleDetectionCandidate(
                    holeID: holeID,
                    distanceToTeeMeters: 4,
                    confidence: 0.88
                )
            ]
        )

        let output =
            try await setup.orchestrator.process(
                .holeDetectionCompleted(result)
            )

        XCTAssertEqual(
            output,
            .requestHoleConfirmation(
                holeID,
                confidence: 0.88
            )
        )

        let state =
            await setup.orchestrator.currentState()

        XCTAssertEqual(
            state,
            .awaitingHoleConfirmation
        )
    }

    func testConfirmedHoleUpdatesRound()
        async throws {

        let setup = try await makeSetup()
        let holeID = HoleID()

        _ = try await setup.orchestrator.process(
            .holeDetectionCompleted(
                HoleDetectionResult(
                    status: .detected,
                    selectedHoleID: holeID,
                    confidence: 0.90
                )
            )
        )

        let output =
            try await setup.orchestrator.process(
                .holeConfirmedByGolfer(holeID)
            )

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        XCTAssertEqual(
            output,
            .holeDetected(
                holeID,
                confidence: 1
            )
        )

        XCTAssertEqual(
            snapshot.round
                .currentHoleSession?
                .holeID,
            holeID
        )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingClub
        )
    }

    func testAmbiguousHoleDoesNotCreateHoleSession()
        async throws {

        let setup = try await makeSetup()

        let result = HoleDetectionResult(
            status: .ambiguous,
            candidates: [
                HoleDetectionCandidate(
                    holeID: HoleID(),
                    distanceToTeeMeters: 8,
                    confidence: 0.75
                ),
                HoleDetectionCandidate(
                    holeID: HoleID(),
                    distanceToTeeMeters: 10,
                    confidence: 0.72
                )
            ]
        )

        let output =
            try await setup.orchestrator.process(
                .holeDetectionCompleted(result)
            )

        guard case .holeDetectionAmbiguous =
                output else {
            return XCTFail(
                "Expected ambiguous-hole output"
            )
        }

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        XCTAssertNil(
            snapshot.round.currentHoleSession
        )
    }

    func testPoorLocationAccuracyProducesWarning()
        async throws {

        let setup = try await makeSetup()

        let output =
            try await setup.orchestrator.process(
                .holeDetectionCompleted(
                    HoleDetectionResult(
                        status:
                            .insufficientAccuracy
                    )
                )
            )

        XCTAssertEqual(
            output,
            .locationAccuracyInsufficient
        )
    }

    func testMatchingGolfClubCanBeAcceptedAutomatically()
        async throws {

        let setup = try await makeSetup()

        let golfClubID =
            setup.activeSnapshot.round.golfClubID

        let output =
            try await setup.orchestrator.process(
                .golfClubDetectionCompleted(
                    GolfClubDetectionResult(
                        status: .detected,
                        selectedGolfClubID:
                            golfClubID,
                        confidence: 0.90
                    )
                )
            )

        XCTAssertEqual(
            output,
            .golfClubDetected(
                golfClubID,
                confidence: 0.90
            )
        )

        let state =
            await setup.orchestrator.currentState()

        XCTAssertEqual(
            state,
            .awaitingHoleDetection
        )
    }

    func testDifferentDetectedClubRequiresConfirmation()
        async throws {

        let setup = try await makeSetup()
        let detectedClubID = GolfClubID()

        let output =
            try await setup.orchestrator.process(
                .golfClubDetectionCompleted(
                    GolfClubDetectionResult(
                        status: .detected,
                        selectedGolfClubID:
                            detectedClubID,
                        confidence: 0.80
                    )
                )
            )

        XCTAssertEqual(
            output,
            .requestGolfClubConfirmation(
                detectedClubID,
                confidence: 0.80
            )
        )
    }

    private func makeSetup()
        async throws -> (
            orchestrator: RoundOrchestrator,
            activeSnapshot: ActiveRoundSnapshot
        ) {

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

        let orchestrator =
            RoundOrchestrator(
                snapshot: snapshot,
                coordinator: coordinator
            )

        return (
            orchestrator,
            snapshot
        )
    }
}
