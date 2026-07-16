//
//  ShotSituationEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotSituationEngineTests:
    XCTestCase {

    private let engine =
        ShotSituationEngine()

    func testClassifiesDriverTeeShot()
        throws {

        let club =
            Club(
                name: "Driver",
                type: .driver,
                averageCarryMeters: 220
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 220,
                clubs: [club],
                lie: .tee
            )

        let decision =
            try makeDecision(
                context: context,
                clubID: club.id
            )

        let result =
            engine.classify(
                recommendation: decision,
                context: context
            )

        XCTAssertEqual(
            result.situation,
            .driverTeeShot
        )
    }
    func testClassifiesFairwayWoodTeeShot()
        throws {

        let club =
            Club(
                name: "3 Wood",
                type: .fairwayWood,
                averageCarryMeters: 200
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 200,
                clubs: [club],
                lie: .tee
            )

        let decision =
            try makeDecision(
                context: context,
                clubID: club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .fairwayWoodTeeShot
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.9
        )

        XCTAssertTrue(
            result.rationale.contains(
                "fairway wood"
            )
        )
    }
    func testClassifiesShortPutt()
        throws {

        let club =
            Club(
                name: "Putter",
                type: .putter,
                averageCarryMeters: 0
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 3,
                clubs: [club],
                lie: .green
            )

        let decision =
            try makeDecision(
                context: context,
                clubID: club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .shortPutt
        )

        XCTAssertEqual(
            result.confidence,
            1.0
        )

        XCTAssertTrue(
            result.rationale.contains(
                "short-putt"
            )
        )
    }
    
    func testClassifiesLongPutt()
        throws {

        let club =
            Club(
                name: "Putter",
                type: .putter,
                averageCarryMeters: 0
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 15,
                clubs: [club],
                lie: .green
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .longPutt
        )

        XCTAssertEqual(
            result.confidence,
            1.0
        )

        XCTAssertTrue(
            result.rationale.contains(
                "exceeds the short-putt threshold"
            )
        )
    }
    func testClassifiesGreensideBunker()
        throws {

        let club =
            Club(
                name: "Sand Wedge",
                type: .wedge,
                averageCarryMeters: 80
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 25,
                clubs: [club],
                lie: .greensideBunker
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .greensideBunker
        )

        XCTAssertEqual(
            result.confidence,
            1.0
        )

        XCTAssertTrue(
            result.rationale.contains(
                "greenside bunker"
            )
        )
    }
    
    func testClassifiesFairwayBunker()
        throws {

        let club =
            Club(
                name: "5 Iron",
                type: .iron,
                averageCarryMeters: 170
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 170,
                clubs: [club],
                lie: .fairwayBunker
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .fairwayBunker
        )

        XCTAssertEqual(
            result.confidence,
            1.0
        )

        XCTAssertTrue(
            result.rationale.contains(
                "fairway bunker"
            )
        )
    }
    func testClassifiesPunchShotFromTrees()
        throws {

        let club =
            Club(
                name: "7 Iron",
                type: .iron,
                averageCarryMeters: 140
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 120,
                clubs: [club],
                lie: .trees
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .punchShot
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.9
        )

        XCTAssertTrue(
            result.rationale.contains(
                "obstruction"
            )
        )
    }

    func testClassifiesChip()
        throws {

        let club =
            Club(
                name: "Sand Wedge",
                type: .wedge,
                averageCarryMeters: 60
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 15,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .chip
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.8
        )

        XCTAssertTrue(
            result.rationale.contains(
                "short shot near the green"
            )
        )
    }
    
    func testClassifiesPitch()
        throws {

        let club =
            Club(
                name: "Sand Wedge",
                type: .wedge,
                averageCarryMeters: 80
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 60,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .pitch
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.8
        )

        XCTAssertTrue(
            result.rationale.contains(
                "controlled pitch"
            )
        )
    }
    func testClassifiesLongApproach()
        throws {

        let club =
            Club(
                name: "5 Iron",
                type: .iron,
                averageCarryMeters: 180
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 190,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .longApproach
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.8
        )

        XCTAssertTrue(
            result.rationale.contains(
                "long-approach threshold"
            )
        )
    }
    
    func testClassifiesMidIronApproach()
        throws {

        let club =
            Club(
                name: "7 Iron",
                type: .iron,
                averageCarryMeters: 145
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 145,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .midIronApproach
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.8
        )

        XCTAssertTrue(
            result.rationale.contains(
                "mid-iron approach range"
            )
        )
    }
    func testClassifiesShortIronApproach()
        throws {

        let club =
            Club(
                name: "9 Iron",
                type: .iron,
                averageCarryMeters: 120
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 105,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .shortIronApproach
        )

        XCTAssertGreaterThan(
            result.confidence,
            0.8
        )

        XCTAssertTrue(
            result.rationale.contains(
                "short-iron approach range"
            )
        )
    }
    func testShortIronBoundary()
    throws {

        let club =
            Club(
                name:
                    "9 Iron",
                type:
                    .iron,
                averageCarryMeters:
                    120
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters:
                    105,
                clubs:
                    [club],
                lie:
                    .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .shortIronApproach
        )

        XCTAssertEqual(
            result.confidence,
            0.85
        )

        XCTAssertTrue(
            result.rationale.contains(
                "short-iron approach range"
            )
        )
    }


    func testMidIronBoundary()
    throws {

        let club =
            Club(
                name:
                    "6 Iron",
                type:
                    .iron,
                averageCarryMeters:
                    140
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters:
                    160,
                clubs:
                    [club],
                lie:
                    .fairway
            )

        let decision =
            try makeDecision(
                context:
                    context,
                clubID:
                    club.id
            )

        let result =
            engine.classify(
                recommendation:
                    decision,
                context:
                    context
            )

        XCTAssertEqual(
            result.situation,
            .midIronApproach
        )

        XCTAssertEqual(
            result.confidence,
            0.85
        )

        XCTAssertTrue(
            result.rationale.contains(
                "mid-iron approach range"
            )
        )
    }
    func testReturnsUnknownWhenNoPreferredClub()
        throws {

        let club =
            Club(
                name: "7 Iron",
                type: .iron,
                averageCarryMeters: 145
            )

        let context =
            GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 145,
                clubs: [club],
                lie: .fairway
            )

        let decision =
            try makeDecision(
                context: context,
                clubID: nil
            )

        let result =
            engine.classify(
                recommendation: decision,
                context: context
            )

        XCTAssertEqual(
            result,
            .unknown
        )
    }
    private func makeDecision(
        context: ShotContext,
        clubID: ClubID?
    ) throws -> RecommendationDecision {

        let preferredClub =
            clubID.map {
                ClubRecommendation(
                    clubID: $0,
                    score: 0.90,
                    adjustedCarryMeters:
                        context.currentShotPlan?
                            .targetDistanceMeters ?? 0,
                    distanceDifferenceMeters: 0,
                    confidence: 0.90,
                    reasons: []
                )
            }

        return RecommendationDecision(
            shotPlan:
                try XCTUnwrap(
                    context.currentShotPlan
                ),
            preferredClub:
                preferredClub,
            alternatives: [],
            aimOffsetDegrees: 0
        )
    }
}
