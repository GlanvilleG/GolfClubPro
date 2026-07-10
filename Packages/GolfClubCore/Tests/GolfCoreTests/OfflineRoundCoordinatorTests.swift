//
//  OfflineRoundCoordinatorTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class OfflineRoundCoordinatorTests:
    XCTestCase {

    private let coordinator =
        OfflineRoundCoordinator()

    private let deviceID = DeviceID()

    func testStartingRoundCreatesSnapshotAndEvent()
        throws {

        let snapshot = try coordinator.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID(),
            deviceID: deviceID
        )

        XCTAssertEqual(
            snapshot.round.state,
            .roundActive
        )

        XCTAssertEqual(
            snapshot.pendingEvents.count,
            1
        )

        XCTAssertEqual(
            snapshot.pendingEvents.first?.type,
            .roundStarted
        )

        XCTAssertEqual(
            snapshot.pendingEvents.first?.sequenceNumber,
            1
        )
    }

    func testConfirmingTeeSetUpdatesSnapshot()
        throws {

        var snapshot = try makeSnapshot()
        let teeSetID = TeeSetID()

        snapshot = try coordinator.confirmTeeSet(
            teeSetID,
            in: snapshot
        )

        XCTAssertEqual(
            snapshot.round.teeSetID,
            teeSetID
        )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingHoleConfirmation
        )

        XCTAssertEqual(
            snapshot.pendingEvents.last?.type,
            .teeSetConfirmed
        )

        XCTAssertEqual(
            snapshot.pendingEvents.last?.sequenceNumber,
            2
        )
    }

    func testFullShotWorkflowCreatesOrderedEvents()
        throws {

        var snapshot = try makeActiveHoleSnapshot()

        snapshot = try coordinator.announceClub(
            ClubID(),
            currentLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            in: snapshot
        )

        snapshot = try coordinator.markShotHit(
            in: snapshot
        )

        snapshot =
            try coordinator.recordShotFeedback(
                transcript: "I pushed it",
                in: snapshot
            )

        XCTAssertEqual(
            snapshot.round.state,
            .awaitingBallPosition
        )

        XCTAssertEqual(
            snapshot.pendingEvents.map(\.type),
            [
                .roundStarted,
                .teeSetConfirmed,
                .holeConfirmed,
                .clubSelected,
                .shotStarted,
                .shotFeedbackRecorded
            ]
        )

        XCTAssertEqual(
            snapshot.pendingEvents.compactMap(
                \.sequenceNumber
            ),
            [1, 2, 3, 4, 5, 6]
        )
    }

    func testAnnouncingNextClubCompletesPriorShot()
        throws {

        var snapshot = try makeActiveHoleSnapshot()

        snapshot = try coordinator.announceClub(
            ClubID(),
            currentLocation: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            in: snapshot
        )

        snapshot = try coordinator.markShotHit(
            in: snapshot
        )

        snapshot =
            try coordinator.recordShotFeedback(
                transcript: "Good strike",
                in: snapshot
            )

        snapshot = try coordinator.announceClub(
            ClubID(),
            currentLocation: GeoCoordinate(
                latitude: 0.001,
                longitude: 0
            ),
            in: snapshot
        )

        let shots = try XCTUnwrap(
            snapshot.round
                .currentHoleSession?
                .shots
        )

        XCTAssertEqual(shots.count, 2)
        XCTAssertNotNil(shots[0].completedAt)
        XCTAssertNotNil(shots[0].distanceMeters)
        XCTAssertNil(shots[1].completedAt)
    }

    func testRecordingPuttsCreatesOfflineEvent()
        throws {

        var snapshot = try makeActiveHoleSnapshot()

        snapshot = try coordinator.recordPutts(
            2,
            in: snapshot
        )

        XCTAssertEqual(
            snapshot.round.state,
            .holePendingCompletion
        )

        XCTAssertEqual(
            snapshot.pendingEvents.last?.type,
            .puttsRecorded
        )
    }

    func testCompletingRoundCreatesFinalEvent()
        throws {

        var snapshot = try makeActiveHoleSnapshot()

        snapshot = try coordinator.recordPutts(
            2,
            in: snapshot
        )

        snapshot =
            try coordinator.completeCurrentHole(
                in: snapshot
            )

        snapshot = try coordinator.finishRound(
            in: snapshot
        )

        XCTAssertEqual(
            snapshot.round.state,
            .roundCompleted
        )

        XCTAssertEqual(
            snapshot.pendingEvents.last?.type,
            .roundCompleted
        )

        XCTAssertNotNil(
            snapshot.round.completedAt
        )
    }

    func testSnapshotRevisionIncrements()
        throws {

        var snapshot = try makeSnapshot()
        let originalRevision =
            snapshot.localRevision

        snapshot = try coordinator.confirmTeeSet(
            TeeSetID(),
            in: snapshot
        )

        XCTAssertEqual(
            snapshot.localRevision,
            originalRevision + 1
        )
    }

    func testCourseGeometryCanBeCached()
        throws {

        let snapshot = try makeSnapshot()

        let geometry = CourseGeometry(
            areas: []
        )

        let updated =
            coordinator.cacheCourseGeometry(
                geometry,
                in: snapshot
            )

        XCTAssertEqual(
            updated.cachedCourseGeometry,
            geometry
        )

        XCTAssertEqual(
            updated.localRevision,
            snapshot.localRevision + 1
        )
    }

    private func makeSnapshot()
        throws -> ActiveRoundSnapshot {

        try coordinator.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID(),
            deviceID: deviceID
        )
    }

    private func makeActiveHoleSnapshot()
        throws -> ActiveRoundSnapshot {

        var snapshot = try makeSnapshot()

        snapshot = try coordinator.confirmTeeSet(
            TeeSetID(),
            in: snapshot
        )

        snapshot = try coordinator.confirmHole(
            HoleID(),
            in: snapshot
        )

        return snapshot
    }
}
