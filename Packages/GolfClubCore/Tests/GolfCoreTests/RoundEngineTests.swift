//
//  RoundEngineTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class RoundEngineTests: XCTestCase {

    private let engine = RoundEngine()

    private func sampleRound() throws -> Round {
        var round = engine.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        round = try engine.confirmTeeSet(TeeSetID(), for: round)
        round = try engine.confirmHole(holeID: HoleID(), for: round)

        return round
    }

    func testStartRoundCreatesActiveRound() {
        let round = engine.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        XCTAssertEqual(round.state, .roundActive)
        XCTAssertNil(round.completedAt)
        XCTAssertNil(round.currentHoleSession)
        XCTAssertTrue(round.holeSessions.isEmpty)
    }

    func testConfirmTeeSetUpdatesRound() throws {
        let teeSetID = TeeSetID()
        var round = engine.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        round = try engine.confirmTeeSet(teeSetID, for: round)

        XCTAssertEqual(round.teeSetID, teeSetID)
        XCTAssertEqual(round.state, .awaitingHoleConfirmation)
    }

    func testConfirmHoleCreatesHoleSession() throws {
        let holeID = HoleID()
        var round = engine.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        round = try engine.confirmHole(holeID: holeID, for: round)

        XCTAssertEqual(round.state, .awaitingClub)
        XCTAssertEqual(round.currentHoleSession?.holeID, holeID)
        XCTAssertEqual(round.holeSessions.count, 1)
        XCTAssertEqual(round.currentHoleSession?.status, .active)
    }

    func testAnnounceClubCreatesShot() throws {
        let clubID = ClubID()
        var round = try sampleRound()

        round = try engine.announceClub(
            clubID: clubID,
            currentLocation: GeoCoordinate(latitude: -39.9300, longitude: 175.0500),
            for: round
        )

        let shot = try XCTUnwrap(round.currentHoleSession?.shots.first)

        XCTAssertEqual(round.state, .clubSelected)
        XCTAssertEqual(shot.clubID, clubID)
        XCTAssertNil(shot.completedAt)
        XCTAssertNotNil(shot.startLocation)
    }

    func testChangeClubUpdatesSelectedShot() throws {
        let replacementClubID = ClubID()

        var round = try sampleRound()
        round = try engine.announceClub(clubID: ClubID(), for: round)
        round = try engine.changeClub(to: replacementClubID, for: round)

        let shot = try XCTUnwrap(round.currentHoleSession?.shots.first)

        XCTAssertEqual(round.state, .clubSelected)
        XCTAssertEqual(shot.clubID, replacementClubID)
    }

    func testMarkShotHitMovesState() throws {
        var round = try sampleRound()
        round = try engine.announceClub(clubID: ClubID(), for: round)
        round = try engine.markShotHit(for: round)

        XCTAssertEqual(round.state, .awaitingShotFeedback)
    }

    func testRecordShotFeedbackStoresFeedback() throws {
        var round = try sampleRound()
        round = try engine.announceClub(clubID: ClubID(), for: round)
        round = try engine.markShotHit(for: round)

        round = try engine.recordShotFeedback(
            rawTranscript: "I pushed it right into the bunker",
            classifiedErrors: [.push, .bunker],
            sentiment: .negative,
            for: round
        )

        let shot = try XCTUnwrap(round.currentHoleSession?.shots.first)

        XCTAssertEqual(round.state, .awaitingBallPosition)
        XCTAssertEqual(shot.feedback?.rawTranscript, "I pushed it right into the bunker")
        XCTAssertEqual(shot.feedback?.classifiedErrors, [.push, .bunker])
        XCTAssertEqual(shot.feedback?.sentiment, .negative)
    }

    func testNextClubCompletesPreviousShot() throws {
        let firstClubID = ClubID()
        let secondClubID = ClubID()

        let start = GeoCoordinate(latitude: -39.9300, longitude: 175.0500)
        let ball = GeoCoordinate(latitude: -39.9290, longitude: 175.0510)

        var round = try sampleRound()
        round = try engine.announceClub(clubID: firstClubID, currentLocation: start, for: round)
        round = try engine.markShotHit(for: round)
        round = try engine.recordShotFeedback(rawTranscript: "good strike", sentiment: .positive, for: round)
        round = try engine.announceClub(clubID: secondClubID, currentLocation: ball, for: round)

        let shots = try XCTUnwrap(round.currentHoleSession?.shots)

        XCTAssertEqual(shots.count, 2)
        XCTAssertEqual(shots[0].clubID, firstClubID)
        XCTAssertNotNil(shots[0].completedAt)
        XCTAssertEqual(shots[0].endLocation, ball)
        XCTAssertGreaterThan(shots[0].distanceMeters ?? 0, 0)
        XCTAssertEqual(shots[1].clubID, secondClubID)
        XCTAssertNil(shots[1].completedAt)
    }

    func testRecordPuttsMarksHolePendingCompletion() throws {
        var round = try sampleRound()

        round = try engine.recordPutts(2, for: round)

        XCTAssertEqual(round.state, .holePendingCompletion)
        XCTAssertEqual(round.currentHoleSession?.putts, 2)
        XCTAssertEqual(round.currentHoleSession?.status, .pendingCompletion)
    }

    func testLeaveHolePendingKeepsHoleOpen() throws {
        var round = try sampleRound()

        round = try engine.leaveHolePending(for: round)

        XCTAssertEqual(round.state, .holePendingCompletion)
        XCTAssertNotNil(round.currentHoleSession)
        XCTAssertEqual(round.currentHoleSession?.status, .pendingCompletion)
    }

    func testCompleteCurrentHoleClosesSession() throws {
        var round = try sampleRound()
        round = try engine.recordPutts(2, for: round)
        round = try engine.completeCurrentHole(for: round)

        XCTAssertEqual(round.state, .holeCompleted)
        XCTAssertNil(round.currentHoleSession)
        XCTAssertEqual(round.holeSessions.first?.status, .completed)
    }

    func testFinishRoundCompletesRound() throws {
        var round = try sampleRound()
        round = try engine.recordPutts(2, for: round)
        round = try engine.completeCurrentHole(for: round)
        round = try engine.finishRound(round)

        XCTAssertEqual(round.state, .roundCompleted)
        XCTAssertNotNil(round.completedAt)
    }

    func testInvalidTransitionThrowsError() {
        let round = engine.startRound(
            playerID: PlayerID(),
            golfClubID: GolfClubID(),
            courseID: CourseID()
        )

        XCTAssertThrowsError(try engine.markShotHit(for: round))
    }
    
    func testRecordShotFeedbackTranscriptNormalizesFeedback() throws {
        var round = try sampleRound()
        round = try engine.announceClub(clubID: ClubID(), for: round)
        round = try engine.markShotHit(for: round)

        round = try engine.recordShotFeedbackTranscript(
            "I pushed it right into the bunker",
            for: round
        )

        let shot = try XCTUnwrap(round.currentHoleSession?.shots.first)

        XCTAssertEqual(round.state, .awaitingBallPosition)
        XCTAssertEqual(shot.feedback?.rawTranscript, "I pushed it right into the bunker")
        XCTAssertTrue(shot.feedback?.classifiedErrors.contains(.push) == true)
        XCTAssertTrue(shot.feedback?.classifiedErrors.contains(.bunker) == true)
        XCTAssertEqual(shot.feedback?.sentiment, .negative)
    }
    func testNextClubInfersPreviousShotLie() throws {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .fairway,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 0, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 0)
                    ]
                )
            ]
        )

        var round = try sampleRound()

        round = try engine.announceClub(
            clubID: ClubID(),
            currentLocation: GeoCoordinate(latitude: 1, longitude: 1),
            for: round
        )

        round = try engine.markShotHit(for: round)

        round = try engine.recordShotFeedbackTranscript(
            "Good strike",
            for: round
        )

        round = try engine.announceClub(
            clubID: ClubID(),
            currentLocation: GeoCoordinate(latitude: 5, longitude: 5),
            courseGeometry: geometry,
            for: round
        )

        let shots = try XCTUnwrap(
            round.currentHoleSession?.shots
        )

        XCTAssertEqual(shots[0].inferredCourseArea, .fairway)
        XCTAssertEqual(shots[0].inferredPlayableLie, .fairway)
        XCTAssertEqual(
            shots[0].lieSource,
            .inferredFromCourseGeometry
        )
        XCTAssertEqual(shots[0].effectivePlayableLie, .fairway)
    }
    func testGolferCanCorrectInferredLie() throws {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .rough,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 0, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 0)
                    ]
                )
            ]
        )

        var round = try sampleRound()

        round = try engine.announceClub(
            clubID: ClubID(),
            currentLocation: GeoCoordinate(latitude: 1, longitude: 1),
            for: round
        )

        round = try engine.markShotHit(for: round)

        round = try engine.recordShotFeedbackTranscript(
            "Pulled it",
            for: round
        )

        round = try engine.announceClub(
            clubID: ClubID(),
            currentLocation: GeoCoordinate(latitude: 5, longitude: 5),
            courseGeometry: geometry,
            for: round
        )

        round = try engine.correctLie(
            .deepRough,
            forLastCompletedShotIn: round
        )

        let completedShot = try XCTUnwrap(
            round.currentHoleSession?.shots.first
        )

        XCTAssertEqual(
            completedShot.inferredPlayableLie,
            .lightRough
        )
        XCTAssertEqual(
            completedShot.confirmedPlayableLie,
            .deepRough
        )
        XCTAssertEqual(
            completedShot.lieSource,
            .golferCorrected
        )
        XCTAssertEqual(
            completedShot.effectivePlayableLie,
            .deepRough
        )
    }
}
