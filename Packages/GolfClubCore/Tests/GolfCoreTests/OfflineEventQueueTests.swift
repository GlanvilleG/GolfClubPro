//
//  OfflineEventQueueTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class OfflineEventQueueTests:
    XCTestCase {

    private let queue = OfflineEventQueue()
    private let deviceID = DeviceID()

    func testEnqueueAddsPendingEvent() throws {
        let roundID = RoundID()

        let events = queue.enqueue(
            type: .roundStarted,
            roundID: roundID,
            deviceID: deviceID,
            into: []
        )

        let event = try XCTUnwrap(events.first)

        XCTAssertEqual(event.type, .roundStarted)
        XCTAssertEqual(event.status, .pending)
        XCTAssertEqual(event.roundID, roundID)
        XCTAssertEqual(event.sequenceNumber, 1)
    }

    func testSequenceNumbersIncrementPerRound() {
        let roundID = RoundID()

        var events = queue.enqueue(
            type: .roundStarted,
            roundID: roundID,
            deviceID: deviceID,
            into: []
        )

        events = queue.enqueue(
            type: .holeConfirmed,
            roundID: roundID,
            deviceID: deviceID,
            into: events
        )

        XCTAssertEqual(
            events.map(\.sequenceNumber),
            [1, 2]
        )
    }

    func testMarkProcessingIncrementsAttemptCount()
        throws {

        let events = queue.enqueue(
            type: .roundStarted,
            roundID: RoundID(),
            deviceID: deviceID,
            into: []
        )

        let eventID = try XCTUnwrap(
            events.first?.id
        )

        let updated = try queue.markProcessing(
            eventID: eventID,
            in: events
        )

        XCTAssertEqual(
            updated.first?.status,
            .processing
        )

        XCTAssertEqual(
            updated.first?.attemptCount,
            1
        )

        XCTAssertNotNil(
            updated.first?.lastAttemptAt
        )
    }

    func testMarkCompletedRemovesEventFromPending()
        throws {

        let events = queue.enqueue(
            type: .shotCompleted,
            roundID: RoundID(),
            deviceID: deviceID,
            into: []
        )

        let eventID = try XCTUnwrap(
            events.first?.id
        )

        let completed = try queue.markCompleted(
            eventID: eventID,
            in: events
        )

        XCTAssertTrue(
            queue.pendingEvents(
                from: completed
            ).isEmpty
        )
    }

    func testFailedEventCanBeRetriedLater()
        throws {

        let events = queue.enqueue(
            type: .recommendationAuditCreated,
            roundID: RoundID(),
            deviceID: deviceID,
            into: []
        )

        let eventID = try XCTUnwrap(
            events.first?.id
        )

        let retryDate = Date()
            .addingTimeInterval(60)

        let failed = try queue.markFailed(
            eventID: eventID,
            errorDescription: "Network unavailable",
            retryAt: retryDate,
            in: events
        )

        XCTAssertTrue(
            queue.pendingEvents(
                from: failed,
                at: Date()
            ).isEmpty
        )

        XCTAssertEqual(
            queue.pendingEvents(
                from: failed,
                at: retryDate
                    .addingTimeInterval(1)
            ).count,
            1
        )
    }

    func testDuplicateEventIsDetected() throws {
        let roundID = RoundID()

        let events = queue.enqueue(
            type: .holeConfirmed,
            roundID: roundID,
            sequenceNumber: 2,
            deviceID: deviceID,
            into: []
        )

        let duplicate = OfflineEvent(
            type: .holeConfirmed,
            roundID: roundID,
            sequenceNumber: 2,
            deviceID: deviceID
        )

        XCTAssertTrue(
            queue.containsDuplicate(
                duplicate,
                in: events
            )
        )
    }

    func testActiveRoundSnapshotReportsPendingEvents()
        throws {

        let round = RoundEngine().startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        let events = queue.enqueue(
            type: .roundStarted,
            roundID: round.id,
            deviceID: deviceID,
            into: []
        )

        let snapshot = ActiveRoundSnapshot(
            round: round,
            deviceID: deviceID,
            pendingEvents: events
        )

        XCTAssertTrue(snapshot.hasPendingEvents)
        XCTAssertEqual(
            snapshot.nextSequenceNumber,
            2
        )
    }

    func testCompletedEventsAreNotPending()
        throws {

        let round = RoundEngine().startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        var events = queue.enqueue(
            type: .roundStarted,
            roundID: round.id,
            deviceID: deviceID,
            into: []
        )

        let eventID = try XCTUnwrap(
            events.first?.id
        )

        events = try queue.markCompleted(
            eventID: eventID,
            in: events
        )

        let snapshot = ActiveRoundSnapshot(
            round: round,
            deviceID: deviceID,
            pendingEvents: events
        )

        XCTAssertFalse(snapshot.hasPendingEvents)
    }
}
