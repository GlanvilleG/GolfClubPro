//
//  RecommendationAuditTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class RecommendationAuditTests:
    XCTestCase {

    func testAuditRecordIsCreatedWhenEnabled()
        throws {

        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let player = Player(
            name: "Gerard",
            recommendationAuditEnabled: true
        )

        let context = makeContext(
            player: player,
            clubs: [club]
        )

        let result =
            try RecommendationEngine()
                .recommend(for: context)

        XCTAssertNotNil(result.auditRecord)
        XCTAssertEqual(
            result.auditRecord?.playerID,
            player.id
        )
        XCTAssertEqual(
            result.auditRecord?
                .preferredClubID,
            club.id
        )
    }

    func testAuditRecordIsNotCreatedWhenDisabled()
        throws {

        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let player = Player(
            name: "Gerard",
            recommendationAuditEnabled: false
        )

        let context = makeContext(
            player: player,
            clubs: [club]
        )

        let result =
            try RecommendationEngine()
                .recommend(for: context)

        XCTAssertNil(result.auditRecord)
    }

    func testAuditServiceRecordsModifiedChoice() {
        let recommendedClubID = ClubID()
        let selectedClubID = ClubID()

        let record = makeAuditRecord(
            preferredClubID:
                recommendedClubID
        )

        let updated =
            RecommendationAuditService()
                .recordModified(
                    selectedClubID:
                        selectedClubID,
                    for: record
                )

        XCTAssertEqual(
            updated.golferDecision,
            .modified
        )
        XCTAssertEqual(
            updated.selectedClubID,
            selectedClubID
        )
    }

    func testAuditServiceLinksActualShot() {
        let shotID = ShotID()
        let record = makeAuditRecord()

        let updated =
            RecommendationAuditService()
                .linkShot(
                    shotID,
                    to: record
                )

        XCTAssertEqual(
            updated.actualShotID,
            shotID
        )
    }

    private func makeContext(
        player: Player,
        clubs: [Club]
    ) -> ShotContext {
        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 145
        )

        let targetLocation = GeoCoordinate(
            latitude: 145 / 111_320,
            longitude: 0
        )

        let target = TargetPoint(
            location: targetLocation,
            type: .greenCentre
        )

        let plan = ShotPlan(
            aimPoint: target,
            targetBearingDegrees: 0,
            targetDistanceMeters: 145,
            routeStrategy: .direct,
            riskLevel: .low,
            confidence: 0.9,
            rationale: "Clear route."
        )

        return ShotContext(
            player: player,
            roundID: RoundID(),
            hole: hole,
            currentPosition:
                GeoCoordinate(
                    latitude: 0,
                    longitude: 0
                ),
            playableLie: .fairway,
            courseArea: .fairway,
            availableClubs: clubs,
            strategyGeometry:
                HoleStrategyGeometry(
                    holeID: hole.id,
                    greenCentre:
                        targetLocation
                ),
            currentShotPlan: plan
        )
    }

    private func makeAuditRecord(
        preferredClubID: ClubID? = nil
    ) -> RecommendationAuditRecord {
        RecommendationAuditRecord(
            playerID: PlayerID(),
            roundID: RoundID(),
            holeID: HoleID(),
            currentPosition:
                GeoCoordinate(
                    latitude: 0,
                    longitude: 0
                ),
            playableLie: .fairway,
            courseArea: .fairway,
            targetPoint: TargetPoint(
                location: GeoCoordinate(
                    latitude: 1,
                    longitude: 1
                ),
                type: .greenCentre
            ),
            targetBearingDegrees: 0,
            targetDistanceMeters: 145,
            preferredClubID:
                preferredClubID,
            aimOffsetDegrees: 0,
            riskLevel: .low,
            recommendationConfidence: 0.9,
            explanation:
                "Test recommendation."
        )
    }
}
