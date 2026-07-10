//
//  RoundOrchestratorTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class RoundOrchestratorTests:
    XCTestCase {

    func testClubSelectionUpdatesRoundAndState()
        async throws {

        let setup = try await makeOrchestrator()

        let clubID = ClubID()

        let output =
            try await setup.orchestrator.process(
                .clubSelected(clubID)
            )

        let state =
            await setup.orchestrator
                .currentState()

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        XCTAssertEqual(
            output,
            .stateChanged(.clubSelected)
        )

        XCTAssertEqual(
            state,
            .clubSelected
        )

        XCTAssertEqual(
            snapshot.round.state,
            .clubSelected
        )

        XCTAssertEqual(
            snapshot.round
                .currentHoleSession?
                .shots.last?
                .clubID,
            clubID
        )
    }

    func testLowConfidenceSwingIsIgnoredAsPractice()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        let output =
            try await setup.orchestrator.process(
                .swingDetected(
                    SwingObservation(
                        durationSeconds: 0.8,
                        returnedToAddress: true,
                        confidence: 0.4
                    )
                )
            )

        let state =
            await setup.orchestrator
                .currentState()

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        guard case .practiceSwingIgnored =
                output else {
            return XCTFail(
                "Expected practice swing output"
            )
        }

        XCTAssertEqual(
            state,
            .awaitingCommittedSwing
        )

        XCTAssertEqual(
            snapshot.round.state,
            .clubSelected
        )
    }

    func testMediumConfidenceSwingRequestsConfirmation()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                )
            )
        )

        let output =
            try await setup.orchestrator.process(
                .impactDetected(
                    ImpactObservation(
                        confidence: 0.8
                    )
                )
            )

        XCTAssertEqual(
            output,
            .requestShotConfirmation(
                confidence: 0.44
            )
        )

        let currentState =
            await setup.orchestrator.currentState()

        XCTAssertEqual(
            currentState,
            .awaitingShotConfirmation
        )
    }

    func testGolferCanConfirmAmbiguousSwing()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

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

        let output =
            try await setup.orchestrator.process(
                .shotConfirmedByGolfer
            )

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        XCTAssertEqual(
            output,
            .shotConfirmed
        )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingShotFeedback
        )
    }

    func testHighConfidenceSwingIsAutomaticallyConfirmed()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1.2,
                    returnedToAddress: false,
                    confidence: 1
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .impactDetected(
                ImpactObservation(
                    confidence: 1
                )
            )
        )

        let output =
            try await setup.orchestrator.process(
                .golferDepartedShotOrigin
            )

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        XCTAssertEqual(
            output,
            .shotConfirmed
        )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingShotFeedback
        )
    }

    func testVoiceFeedbackIsRecordedAfterConfirmedShot()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1.2,
                    returnedToAddress: false,
                    confidence: 1
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .impactDetected(
                ImpactObservation(
                    confidence: 1
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .golferDepartedShotOrigin
        )

        let output =
            try await setup.orchestrator.process(
                .voiceFeedbackReceived(
                    "I pushed it into the rough"
                )
            )

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        let shot = try XCTUnwrap(
            snapshot.round
                .currentHoleSession?
                .shots.last
        )

        XCTAssertEqual(
            output,
            .shotFeedbackRecorded
        )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingBallPosition
        )

        XCTAssertEqual(
            shot.feedback?.rawTranscript,
            "I pushed it into the rough"
        )

        XCTAssertTrue(
            shot.feedback?
                .classifiedErrors
                .contains(.push) == true
        )
    }

    func testRejectedCandidateDoesNotCreateShotTransition()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1,
                    returnedToAddress: false,
                    confidence: 0.8
                )
            )
        )

        let output =
            try await setup.orchestrator.process(
                .practiceSwingConfirmedByGolfer
            )

        let snapshot =
            await setup.orchestrator
                .currentSnapshot()

        guard case .practiceSwingIgnored =
                output else {
            return XCTFail(
                "Expected practice swing output"
            )
        }

        XCTAssertEqual(
            snapshot.round.state,
            .clubSelected
        )
    }

    func testSwingIsIgnoredWhileAwaitingFeedback()
        async throws {

        let setup = try await
            makeClubSelectedOrchestrator()

        _ = try await setup.orchestrator.process(
            .swingDetected(
                SwingObservation(
                    durationSeconds: 1.2,
                    returnedToAddress: false,
                    confidence: 1
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .impactDetected(
                ImpactObservation(
                    confidence: 1
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .golferDepartedShotOrigin
        )

        let output =
            try await setup.orchestrator.process(
                .swingDetected(
                    SwingObservation(
                        durationSeconds: 1,
                        returnedToAddress: false,
                        confidence: 1
                    )
                )
            )

        XCTAssertEqual(output, .noAction)
    }

    private func makeOrchestrator()
        async throws -> (
            orchestrator: RoundOrchestrator,
            coordinator:
                PersistentOfflineRoundCoordinator
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

        snapshot =
            try await coordinator.confirmHole(
                HoleID(),
                in: snapshot
            )

        let orchestrator =
            RoundOrchestrator(
                snapshot: snapshot,
                coordinator: coordinator
            )

        return (
            orchestrator,
            coordinator
        )
    }

    private func makeClubSelectedOrchestrator()
        async throws -> (
            orchestrator: RoundOrchestrator,
            coordinator:
                PersistentOfflineRoundCoordinator
        ) {

        let setup =
            try await makeOrchestrator()

        _ = try await setup.orchestrator.process(
            .locationUpdated(
                LocationObservation(
                    coordinate:
                        GeoCoordinate(
                            latitude: 0,
                            longitude: 0
                        ),
                    horizontalAccuracyMeters: 3
                )
            )
        )

        _ = try await setup.orchestrator.process(
            .clubSelected(ClubID())
        )

        return setup
    }
}
