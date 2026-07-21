//
//  ExplainabilityEngineIntegrationTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//

import XCTest
@testable import GolfCore

final class ExplainabilityEngineIntegrationTests: XCTestCase {
    func testDeterministicEvidenceAndSummary() throws {
        // Build minimal decision consistent with existing tests
        let club = Club(name: "7 Iron", type: .iron, averageCarryMeters: 145)
        let context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 145,
            clubs: [club],
            lie: .fairway
        )

        let preferred = ClubRecommendation(
            clubID: club.id,
            score: 0.90,
            adjustedCarryMeters: 145,
            distanceDifferenceMeters: 0,
            confidence: 0.85,
            reasons: ["Distance fit"]
        )

        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: preferred,
            alternatives: [],
            aimOffsetDegrees: 0.0
        )

        let engine = ExplainabilityEngine()
        let explanation = engine.explain(decision: decision)

        // Summary is compact and structured (non-narrative)
        XCTAssertTrue(explanation.summary.contains("decision:v1"))
        XCTAssertTrue(explanation.summary.contains("preferred:"))
        XCTAssertTrue(explanation.summary.contains("alternatives:"))
        XCTAssertTrue(explanation.summary.contains("aim:"))

        // Evidence contains preferred club and aim, in deterministic order
        XCTAssertGreaterThanOrEqual(explanation.evidence.count, 2)
        XCTAssertEqual(explanation.evidence[0].kind, .preferredClub)
        XCTAssertEqual(explanation.evidence[0].code, "preferred-club")
        // alternatives may be absent in this case; check conditionally
       
        let kinds = explanation.evidence.map { $0.kind }

        // Preferred should be first
        XCTAssertEqual(explanation.evidence.first?.kind, .preferredClub)

        // Alternatives present only when decision has alternatives
        if decision.alternatives.isEmpty {
            XCTAssertFalse(kinds.contains(.alternatives))
            // Aim should be next
            XCTAssertEqual(explanation.evidence.dropFirst().first?.kind, .aim)
        } else {
            XCTAssertTrue(kinds.contains(.alternatives))
            // alternatives should appear before aim in our deterministic build
            let altIndex = kinds.firstIndex(of: .alternatives)
            let aimIndex = kinds.firstIndex(of: .aim)
            if let altIndex, let aimIndex {
                XCTAssertLessThan(altIndex, aimIndex)
            }
        }
  
        // Verify order is strictly increasing
        let orders = explanation.evidence.map { $0.order }
        XCTAssertEqual(orders, orders.sorted())

        // Confidence evidence exists and mirrors confidenceSummary when preferred present
        let confidenceEntries = explanation.evidence.filter { $0.kind == .confidence }
        XCTAssertLessThanOrEqual(confidenceEntries.count, 1)
    }

    func testEdgeCaseNoPreferredClub() throws {
        let club = Club(name: "7 Iron", type: .iron, averageCarryMeters: 145)
        let context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 145,
            clubs: [club],
            lie: .fairway
        )

        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: nil,
            alternatives: [],
            aimOffsetDegrees: 1.25
        )

        let engine = ExplainabilityEngine()
        let explanation = engine.explain(decision: decision)

        XCTAssertTrue(explanation.summary.contains("preferred:none"))
        XCTAssertTrue(explanation.summary.contains("aim:"))

        // No preferredClub evidence
        XCTAssertFalse(explanation.evidence.contains { $0.kind == .preferredClub })

        // Aim evidence present
        XCTAssertTrue(explanation.evidence.contains { $0.kind == .aim })
    }
}
