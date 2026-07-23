//
//  SnapshotToStructuredEvidenceMapperTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//
import XCTest
@testable import GolfCore

final class SnapshotToStructuredEvidenceMapperTests: XCTestCase {

    func testMappingDeterminism() throws {
        // Arrange minimal snapshot
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
        let candidate = RecommendationEvidenceSnapshot.CandidateSummary(
            clubID: String(describing: club.id),
            score: preferred.score,
            confidence: preferred.confidence
        )
        let env = EnvironmentalAssessment(
            weather: WeatherAssessment(
                windSpeedMetersPerSecond: 3.0,
                windDirectionDegrees: 90,
                crosswindMetersPerSecond: 2.0,
                alongWindMetersPerSecond: -1.0,
                carryAdjustmentFactor: 1.0,
                ageSeconds: 600,
                providerQuality: 0.9
            ),
            terrain: nil,
            lie: nil,
            course: nil,
            hazard: nil,
            confidence: EnvironmentalConfidence(
                overall: 0.8,
                gpsQuality: 0.9,
                weatherFreshness: 0.7,
                dataCompleteness: 1.0
            )
        )
        let snapshot = RecommendationEvidenceSnapshot(
            decision: decision,
            environmentalAssessment: env,
            strategicOptionID: "opt-123",
            riskRewardSummary: ["expectedScore": "par"],
            holeHazardSummary: ["water": "low"],
            shotDispersionSummary: ["lateralSD": "8m"],
            adaptiveAdjustmentSummary: ["meters": "0"],
            weatherAdjustmentSummary: ["along": "-1.0", "cross": "2.0"],
            candidates: [] //[candidate]
        )

        let mapper = SnapshotToStructuredEvidenceMapper()

        // Act
        let first = mapper.map(snapshot)
        let second = mapper.map(snapshot)

        // Assert determinism
        XCTAssertEqual(first, second)
        XCTAssertFalse(first.isEmpty)

        // Contains environment and confidence entries
        let categories = Set(first.map { $0.category })
        XCTAssertTrue(categories.contains(.environment))
        XCTAssertTrue(categories.contains(.confidence))

        // Check for a specific fact key presence
        XCTAssertTrue(first.contains { $0.factKey == "environment.weather.crosswind.mps" })
        XCTAssertTrue(first.contains { $0.factKey == "environment.confidence.overall" })

        // Alternatives category may be absent because we passed none
        XCTAssertFalse(categories.contains(.alternatives))
    }
    func testSnapshotToPublicEvidenceDeterminismAndContent() throws {
        // Arrange snapshot with environment and candidates
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
            aimOffsetDegrees: 1.2
        )
        let candidate = RecommendationEvidenceSnapshot.CandidateSummary(
            clubID: String(describing: club.id),
            score: preferred.score,
            confidence: preferred.confidence
        )
        let env = EnvironmentalAssessment(
            weather: WeatherAssessment(
                windSpeedMetersPerSecond: 4.0,
                windDirectionDegrees: 180,
                crosswindMetersPerSecond: 3.0,
                alongWindMetersPerSecond: 1.0,
                carryAdjustmentFactor: 1.0,
                ageSeconds: 300,
                providerQuality: 0.9
            ),
            terrain: nil,
            lie: nil,
            course: nil,
            hazard: nil,
            confidence: EnvironmentalConfidence(
                overall: 0.85,
                gpsQuality: 0.9,
                weatherFreshness: 0.8,
                dataCompleteness: 1.0
            )
        )
        let snapshot = RecommendationEvidenceSnapshot(
            decision: decision,
            environmentalAssessment: env,
            strategicOptionID: "opt-xyz",
            riskRewardSummary: ["expectedScore": "par"],
            holeHazardSummary: ["water": "low"],
            shotDispersionSummary: ["lateralSD": "8m"],
            adaptiveAdjustmentSummary: ["meters": "0"],
            weatherAdjustmentSummary: ["along": "1.0", "cross": "3.0"],
            candidates: [candidate]
        )

        let mapper = SnapshotToStructuredEvidenceMapper()

        // Act
        let first = mapper.mapToPublicEvidence(snapshot)
        let second = mapper.mapToPublicEvidence(snapshot)

        // Assert determinism
        XCTAssertEqual(first.map { $0.code }, second.map { $0.code })
        XCTAssertEqual(first.map { $0.kind }, second.map { $0.kind })
        XCTAssertEqual(first.map { $0.order }, second.map { $0.order })

        // Check expected kinds are present
        let kinds = Set(first.map { $0.kind })
        XCTAssertTrue(kinds.contains(.preferredClub))
        XCTAssertTrue(kinds.contains(.aim))
        XCTAssertTrue(kinds.contains(.weather))
        XCTAssertTrue(kinds.contains(.confidence))
    }
}


