//
//  RecommendationAuditBuilderTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class RecommendationAuditBuilderTests:
    XCTestCase {

    private let builder =
        RecommendationAuditBuilder()

    func testReturnsNilWhenAuditIsDisabled()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                false

        let decision =
            try makeDecision(
                context: context
            )

        let result =
            builder.build(
                decision: decision,
                explanation:
                    makeExplanation(),
                context: context,
                candidates: []
            )

        XCTAssertNil(
            result
        )
    }

    func testCreatesAuditWhenEnabled()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                true

        let recommendation =
            makeRecommendation(
                clubID:
                    context
                        .availableClubs[0]
                        .id
            )

        let decision =
            try makeDecision(
                context: context,
                preferredClub:
                    recommendation
            )

        let result =
            try XCTUnwrap(
                builder.build(
                    decision:
                        decision,
                    explanation:
                        makeExplanation(),
                    context:
                        context,
                    candidates: [
                        recommendation
                    ]
                )
            )

        XCTAssertEqual(
            result.playerID,
            context.player.id
        )

        XCTAssertEqual(
            result.roundID,
            context.roundID
        )

        XCTAssertEqual(
            result.holeID,
            context.hole.id
        )
    }

    func testStoresPreferredClub()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                true

        let recommendation =
            makeRecommendation(
                clubID:
                    context
                        .availableClubs[0]
                        .id
            )

        let decision =
            try makeDecision(
                context: context,
                preferredClub:
                    recommendation
            )

        let result =
            try XCTUnwrap(
                builder.build(
                    decision:
                        decision,
                    explanation:
                        makeExplanation(),
                    context:
                        context,
                    candidates: [
                        recommendation
                    ]
                )
            )

        XCTAssertEqual(
            result.preferredClubID,
            recommendation.clubID
        )
    }

    func testStoresAlternativeClubs()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                true

        let preferred =
            makeRecommendation(
                clubID: ClubID()
            )

        let alternative =
            makeRecommendation(
                clubID: ClubID()
            )

        let decision =
            try makeDecision(
                context: context,
                preferredClub:
                    preferred,
                alternatives: [
                    alternative
                ]
            )

        let result =
            try XCTUnwrap(
                builder.build(
                    decision:
                        decision,
                    explanation:
                        makeExplanation(),
                    context:
                        context,
                    candidates: [
                        preferred,
                        alternative
                    ]
                )
            )

        XCTAssertEqual(
            result.alternativeClubIDs,
            [
                alternative.clubID
            ]
        )
    }

    func testCreatesCandidateSnapshots()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                true

        let recommendation =
            makeRecommendation(
                clubID: ClubID()
            )

        let decision =
            try makeDecision(
                context: context,
                preferredClub:
                    recommendation
            )

        let result =
            try XCTUnwrap(
                builder.build(
                    decision:
                        decision,
                    explanation:
                        makeExplanation(),
                    context:
                        context,
                    candidates: [
                        recommendation
                    ]
                )
            )

        XCTAssertEqual(
            result.candidateClubs.count,
            1
        )

        XCTAssertEqual(
            result
                .candidateClubs
                .first?
                .clubID,
            recommendation.clubID
        )
    }

    func testStoresExplanationSummary()
        throws {

        var context =
            GolfCoreTestFactory
                .makeShotContext()

        context.player
            .recommendationAuditEnabled =
                true

        let explanation =
            RecommendationExplanation(
                summary:
                    "Use the 7 Iron."
            )

        let decision =
            try makeDecision(
                context: context
            )

        let result =
            try XCTUnwrap(
                builder.build(
                    decision:
                        decision,
                    explanation:
                        explanation,
                    context:
                        context,
                    candidates: []
                )
            )

        XCTAssertEqual(
            result.explanation,
            explanation.summary
        )
    }

    private func makeDecision(
        context: ShotContext,
        preferredClub:
            ClubRecommendation? = nil,
        alternatives:
            [ClubRecommendation] = []
    ) throws -> RecommendationDecision {

        RecommendationDecision(
            shotPlan:
                try XCTUnwrap(
                    context.currentShotPlan
                ),
            preferredClub:
                preferredClub,
            alternatives:
                alternatives,
            aimOffsetDegrees:
                0
        )
    }

    private func makeRecommendation(
        clubID: ClubID
    ) -> ClubRecommendation {

        ClubRecommendation(
            clubID:
                clubID,
            score:
                0.90,
            adjustedCarryMeters:
                150,
            distanceDifferenceMeters:
                2,
            confidence:
                0.85,
            reasons:
                [
                    "Distance fit"
                ]
        )
    }

    private func makeExplanation()
        -> RecommendationExplanation {

        RecommendationExplanation(
            summary:
                "Recommended club."
        )
    }
}
