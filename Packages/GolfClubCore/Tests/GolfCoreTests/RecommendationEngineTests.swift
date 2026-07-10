//
//  RecommendationEngineTests..swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class RecommendationEngineTests: XCTestCase {

    private let engine = RecommendationEngine()

    func testRecommendationChoosesClosestCarryClub() throws {
        let shortClub = Club(
            name: "8 Iron",
            type: .iron,
            averageCarryMeters: 130
        )

        let matchedClub = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let longClub = Club(
            name: "6 Iron",
            type: .iron,
            averageCarryMeters: 160
        )

        let context = makeContext(
            targetDistanceMeters: 145,
            clubs: [shortClub, matchedClub, longClub]
        )

        let result = try engine.recommend(for: context)

        XCTAssertEqual(
            result.preferredClub?.clubID,
            matchedClub.id
        )
    }

    func testDeepRoughPenalisesDriver() throws {
        let driver = Club(
            name: "Driver",
            type: .driver,
            averageCarryMeters: 210
        )

        let iron = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let context = makeContext(
            targetDistanceMeters: 150,
            clubs: [driver, iron],
            lie: .deepRough,
            courseArea: .rough
        )

        let result = try engine.recommend(for: context)

        XCTAssertEqual(
            result.preferredClub?.clubID,
            iron.id
        )
    }

    func testHistoricalCarryOverridesConfiguredCarry() throws {
        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 160
        )

        let history = RecentShotSummary(
            clubID: club.id,
            averageDistanceMeters: 145,
            sampleSize: 20
        )

        let context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club],
            history: [history]
        )

        let result = try engine.recommend(for: context)

        XCTAssertEqual(
            result.preferredClub?.adjustedCarryMeters ?? 0,
            145,
            accuracy: 0.001
        )
    }

    func testRecentPushProducesLeftAimOffset() throws {
        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let history = RecentShotSummary(
            clubID: club.id,
            averageDistanceMeters: 145,
            commonErrors: [.push],
            sampleSize: 10
        )

        let context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club],
            history: [history]
        )

        let result = try engine.recommend(for: context)

        XCTAssertLessThan(result.aimOffsetDegrees, 0)
    }

    func testNoClubsThrowsError() {
        let context = makeContext(
            targetDistanceMeters: 145,
            clubs: []
        )

        XCTAssertThrowsError(
            try engine.recommend(for: context)
        ) { error in
            XCTAssertEqual(
                error as? RecommendationEngineError,
                .noAvailableClubs
            )
        }
    }

    func testRecommendationIncludesExplanation() throws {
        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club]
        )

        let result = try engine.recommend(for: context)

        XCTAssertFalse(result.explanation.isEmpty)
        XCTAssertFalse(
            result.preferredClub?.reasons.isEmpty ?? true
        )
    }

    private func makeContext(
        targetDistanceMeters: Double,
        clubs: [Club],
        lie: PlayableLie = .fairway,
        courseArea: CourseAreaType = .fairway,
        history: [RecentShotSummary] = []
    ) -> ShotContext {
        let player = Player(name: "Gerard")

        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: targetDistanceMeters
        )

        let currentPosition = GeoCoordinate(
            latitude: 0,
            longitude: 0
        )

        let targetLocation = GeoCoordinate(
            latitude:
                targetDistanceMeters / 111_320,
            longitude: 0
        )

        let target = TargetPoint(
            location: targetLocation,
            type: .greenCentre,
            label: "Green centre"
        )

        let shotPlan = ShotPlan(
            aimPoint: target,
            targetBearingDegrees: 0,
            targetDistanceMeters:
                targetDistanceMeters,
            routeStrategy: .direct,
            riskLevel: .low,
            confidence: 0.90,
            rationale: "Clear direct route."
        )

        let strategyGeometry =
            HoleStrategyGeometry(
                holeID: hole.id,
                greenCentre: targetLocation
            )

        return ShotContext(
            player: player,
            roundID: RoundID(),
            hole: hole,
            currentPosition: currentPosition,
            playableLie: lie,
            courseArea: courseArea,
            availableClubs: clubs,
            recentShotHistory: history,
            strategyGeometry: strategyGeometry,
            currentShotPlan: shotPlan
        )
    }
}
