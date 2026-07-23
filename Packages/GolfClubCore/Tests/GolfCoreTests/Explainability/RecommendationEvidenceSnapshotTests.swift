//
//  RecommendationEvidenceSnapshotTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import XCTest
@testable import GolfCore

final class RecommendationEvidenceSnapshotTests: XCTestCase {
    func testCodableRoundTripAndEquatable() throws {
        // Arrange minimal decision
        let club = Club(name: "PW", type: .wedge, averageCarryMeters: 110)
        let context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 110,
            clubs: [club],
            lie: .fairway
        )
        let preferred = ClubRecommendation(
            clubID: club.id,
            score: 0.88,
            adjustedCarryMeters: 110,
            distanceDifferenceMeters: 0,
            confidence: 0.75,
            reasons: ["Distance fit"]
        )
        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: preferred,
            alternatives: [],
            aimOffsetDegrees: 0.0
        )

        let candidate = RecommendationEvidenceSnapshot.CandidateSummary(
            clubID: String(describing: club.id),
            score: preferred.score,
            confidence: preferred.confidence
        )

        let snapshot = RecommendationEvidenceSnapshot(
            schemaVersion: "1",
            decision: decision,
            environmentalAssessment: nil,
            strategicOptionID: nil,
            riskRewardSummary: ["expectedScore": "par"],
            holeHazardSummary: ["water": "low"],
            shotDispersionSummary: ["lateralSD": "8m"],
            adaptiveAdjustmentSummary: ["meters": "0"],
            weatherAdjustmentSummary: ["along": "0.0", "cross": "0.0"],
            candidates: [candidate],
            snapshotID: "test-snapshot",
            producedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )

        // Act
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(RecommendationEvidenceSnapshot.self, from: data)

        // Assert
        XCTAssertEqual(snapshot, decoded)
        XCTAssertEqual(decoded.schemaVersion, "1")
        XCTAssertEqual(decoded.candidates.count, 1)
        XCTAssertEqual(decoded.candidates.first?.clubID, String(describing: club.id))
    }
    func testAuditRecordStoresSnapshotCodable() throws {
        // Arrange minimal decision and snapshot
        let club = Club(name: "PW", type: .wedge, averageCarryMeters: 110)
        let context = GolfCoreTestFactory.makeShotContext(
            targetDistanceMeters: 110,
            clubs: [club],
            lie: .fairway
        )
        let preferred = ClubRecommendation(
            clubID: club.id,
            score: 0.88,
            adjustedCarryMeters: 110,
            distanceDifferenceMeters: 0,
            confidence: 0.75,
            reasons: ["Distance fit"]
        )
        let decision = RecommendationDecision(
            shotPlan: try XCTUnwrap(context.currentShotPlan),
            preferredClub: preferred,
            alternatives: [],
            aimOffsetDegrees: 0.0
        )
        let snapshot = RecommendationEvidenceSnapshot(decision: decision)

        var record = RecommendationAuditRecord(
            playerID: PlayerID(),
            roundID: RoundID(),
            holeID: HoleID(),
            currentPosition: GeoCoordinate(latitude: 0, longitude: 0),
            playableLie: .fairway,
            courseArea: .fairway,
            targetPoint: decision.shotPlan.aimPoint,
            targetBearingDegrees: decision.shotPlan.targetBearingDegrees,
            targetDistanceMeters: decision.shotPlan.targetDistanceMeters,
            preferredClubID: preferred.clubID,
            candidateClubs: [],
            aimOffsetDegrees: decision.aimOffsetDegrees,
            riskLevel: decision.shotPlan.riskLevel,
            recommendationConfidence: preferred.confidence,
            explanation: "test"
        )
        record.explainabilitySnapshot = snapshot

        // Act
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(RecommendationAuditRecord.self, from: data)

        // Assert
        XCTAssertNotNil(decoded.explainabilitySnapshot)
        XCTAssertEqual(decoded.explainabilitySnapshot?.decision.preferredClub?.clubID, preferred.clubID)
    }
}


