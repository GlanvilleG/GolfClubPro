//
//  ExplainabilityCompositionFacadeTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import XCTest
@testable import GolfCore

final class ExplainabilityCompositionFacadeTests: XCTestCase {

    func testFacadeProducesDeterministicPublicEvidence() throws {
        // Arrange: minimal context and decision
        let club = Club(name: "7 Iron", type: .iron, averageCarryMeters: 145)
        let context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 145,
            clubs: [club],
            lie: .fairway
        )

        let preferred = ClubRecommendation(
            clubID: club.id,
            score: 0.92,
            adjustedCarryMeters: 145,
            distanceDifferenceMeters: 0,
            confidence: 0.80,
            reasons: ["Distance fit", "Lie suitability"]
        )

        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: preferred,
            alternatives: [],
            aimOffsetDegrees: 1.0
        )

        let facade = ExplainabilityCompositionFacade()

        // Act: produce structured and public evidence
        let structured = facade.structuredEvidence(from: decision)
        let publicEvidence = facade.publicEvidence(from: decision)

        // Assert: structured evidence is non-empty and contains primaryClub and aimRoute categories
        XCTAssertFalse(structured.isEmpty)
        let categories = Set(structured.map { $0.category })
        XCTAssertTrue(categories.contains(.primaryClub))
        XCTAssertTrue(categories.contains(.aimRoute))

        // Assert: public evidence is ordered deterministically (order = 0..n-1) and includes preferred -> aim
        XCTAssertFalse(publicEvidence.isEmpty)
        let orders = publicEvidence.map { $0.order }
        XCTAssertEqual(orders, Array(0..<orders.count))

        // Preferred should appear before aim given the priority policy
        let kinds = publicEvidence.map { $0.kind }
        let prefIndex = kinds.firstIndex(of: .preferredClub)
        let aimIndex = kinds.firstIndex(of: .aim)
        if let prefIndex, let aimIndex {
            XCTAssertLessThan(prefIndex, aimIndex)
        } else {
            XCTFail("Expected preferredClub and aim kinds in public evidence")
        }
    }
    
       func testFacadeOrdersAlternativesBeforeAim() throws {
            // Arrange
            let clubA = Club(name: "7 Iron", type: .iron, averageCarryMeters: 145)
            let clubB = Club(name: "6 Iron", type: .iron, averageCarryMeters: 155)
            let context = GolfCoreTestFactory.makeShotContext(
                targetDistanceMeters: 150,
                clubs: [clubA, clubB],
                lie: .fairway
            )

            let preferred = ClubRecommendation(
                clubID: clubA.id,
                score: 0.95,
                adjustedCarryMeters: 150,
                distanceDifferenceMeters: 0,
                confidence: 0.82,
                reasons: ["Distance fit"]
            )
            let alternative = ClubRecommendation(
                clubID: clubB.id,
                score: 0.90,
                adjustedCarryMeters: 155,
                distanceDifferenceMeters: 5,
                confidence: 0.78,
                reasons: ["Slightly longer"]
            )

            let decision = RecommendationDecision(
                shotPlan: try XCTUnwrap(context.currentShotPlan),
                preferredClub: preferred,
                alternatives: [alternative],
                aimOffsetDegrees: 2.0
            )

            // Act
            let facade = ExplainabilityCompositionFacade()
            let publicEvidence = facade.publicEvidence(from: decision)
            let kinds = publicEvidence.map { $0.kind }

            // Assert
            XCTAssertTrue(kinds.contains(.alternatives))
            XCTAssertTrue(kinds.contains(.aim))
            if let altIndex = kinds.firstIndex(of: .alternatives), let aimIndex = kinds.firstIndex(of: .aim) {
                XCTAssertLessThan(altIndex, aimIndex)
            } else {
                XCTFail("Expected alternatives and aim kinds in public evidence")
            }

            // Confidence entries should exist (preferred and/or alternative)
            XCTAssertTrue(publicEvidence.contains { $0.kind == .confidence })
        }
    func testLowConfidenceFlagsAreEmitted() throws {
        // Arrange
        let clubA = Club(name: "8 Iron", type: .iron, averageCarryMeters: 135)
        let clubB = Club(name: "9 Iron", type: .iron, averageCarryMeters: 125)
        var context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 130,
            clubs: [clubA, clubB],
            lie: .fairway
        )
        // Force a low-confidence shot plan by modifying confidence on the plan
        if var plan = context.currentShotPlan {
            plan = ShotPlan(
                id: plan.id,
                aimPoint: plan.aimPoint,
                targetBearingDegrees: plan.targetBearingDegrees,
                targetDistanceMeters: plan.targetDistanceMeters,
                preferredClubID: plan.preferredClubID,
                alternativeClubIDs: plan.alternativeClubIDs,
                routeStrategy: plan.routeStrategy,
                riskLevel: plan.riskLevel,
                confidence: 0.1,
                rationale: plan.rationale
            )
            context = GolfCoreTestFactory.makeShotContext(
                base: context,
                overriding: plan
            )
        }

        let preferred = ClubRecommendation(
            clubID: clubA.id,
            score: 0.50,
            adjustedCarryMeters: 130,
            distanceDifferenceMeters: -5,
            confidence: 0.15,
            reasons: ["Uncertain distance"]
        )
        let alternative = ClubRecommendation(
            clubID: clubB.id,
            score: 0.45,
            adjustedCarryMeters: 125,
            distanceDifferenceMeters: -10,
            confidence: 0.10,
            reasons: ["Short carry"]
        )

        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: preferred,
            alternatives: [alternative],
            aimOffsetDegrees: 0.0
        )

        // Act
        let facade = ExplainabilityCompositionFacade()
        let publicEvidence = facade.publicEvidence(from: decision)

        // Assert: expect confidence entries, including ones representing low flags (mapped as .confidence kind)
        let confidenceItems = publicEvidence.filter { $0.kind == .confidence }
        XCTAssertFalse(confidenceItems.isEmpty)
    }
}



