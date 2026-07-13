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

        let result = try engine.recommend(
            for: context
        )

        let preferredClub = try XCTUnwrap(
            result.preferredClub
        )

        XCTAssertEqual(
            preferredClub.clubID,
            iron.id,
            "A 7 iron should be preferred over a driver from deep rough at 150 metres."
        )

        XCTAssertNotEqual(
            preferredClub.clubID,
            driver.id,
            "Deep rough should strongly penalise the driver."
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
        courseArea: HoleAreaType = .fairway,
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
    func testHighDispersionReducesClubScore() throws {
        let consistentClub = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let inconsistentClub = Club(
            name: "7 Iron Backup",
            type: .iron,
            averageCarryMeters: 145
        )

        let consistentSummary = ClubDispersionSummary(
            clubID: consistentClub.id,
            sampleSize: 10,
            directionalSampleSize: 10,
            averageDistanceMeters: 145,
            distanceStandardDeviationMeters: 4,
            averageDirectionalErrorDegrees: 1,
            meanAbsoluteDirectionalErrorDegrees: 2,
            leftMissPercentage: 20,
            rightMissPercentage: 20,
            centredPercentage: 60,
            directionalTendency: .centred
        )

        let inconsistentSummary = ClubDispersionSummary(
            clubID: inconsistentClub.id,
            sampleSize: 10,
            directionalSampleSize: 10,
            averageDistanceMeters: 145,
            distanceStandardDeviationMeters: 22,
            averageDirectionalErrorDegrees: 10,
            meanAbsoluteDirectionalErrorDegrees: 12,
            leftMissPercentage: 10,
            rightMissPercentage: 80,
            centredPercentage: 10,
            directionalTendency: .right
        )

        var context = makeContext(
            targetDistanceMeters: 145,
            clubs: [consistentClub, inconsistentClub]
        )

        context.dispersionSummaries = [
            consistentSummary,
            inconsistentSummary
        ]

        let result = try engine.recommend(for: context)

        XCTAssertEqual(
            result.preferredClub?.clubID,
            consistentClub.id
        )
    }
    func testRightDispersionProducesLeftAimOffset() throws {
        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        let dispersion = ClubDispersionSummary(
            clubID: club.id,
            sampleSize: 10,
            directionalSampleSize: 10,
            averageDistanceMeters: 145,
            distanceStandardDeviationMeters: 5,
            averageDirectionalErrorDegrees: 8,
            meanAbsoluteDirectionalErrorDegrees: 8,
            leftMissPercentage: 10,
            rightMissPercentage: 80,
            centredPercentage: 10,
            directionalTendency: .right
        )

        var context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club]
        )

        context.dispersionSummaries = [dispersion]

        let result = try engine.recommend(for: context)

        XCTAssertLessThan(
            result.aimOffsetDegrees,
            0
        )
    }
    func testStaleWeatherReducesConfidence() throws {
        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        var liveContext = makeContext(
            targetDistanceMeters: 145,
            clubs: [club]
        )

        liveContext.environment = EnvironmentalContext(
            weatherSnapshot: WeatherSnapshot(
                observedAt: Date(),
                location: liveContext.currentPosition,
                wind: WindContext(
                    speedMetersPerSecond: 4,
                    directionDegrees: 180
                ),
                availability: .live,
                source: .weatherKit
            )
        )

        var staleContext = liveContext

        staleContext.environment = EnvironmentalContext(
            weatherSnapshot: WeatherSnapshot(
                observedAt: Date()
                    .addingTimeInterval(-60 * 60),
                location: staleContext.currentPosition,
                wind: WindContext(
                    speedMetersPerSecond: 4,
                    directionDegrees: 180
                ),
                availability: .stale,
                source: .cachedWeatherKit
            )
        )

        let liveResult =
            try engine.recommend(
                for: liveContext
            )

        let staleResult =
            try engine.recommend(
                for: staleContext
            )

        XCTAssertGreaterThan(
            liveResult.preferredClub?.confidence ?? 0,
            staleResult.preferredClub?.confidence ?? 0
        )
    }
    func testUnavailableWeatherStillProducesRecommendation()
        throws {

        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        var context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club]
        )

        context.environment =
            EnvironmentalContext()

        let result =
            try engine.recommend(
                for: context
            )

        XCTAssertEqual(
            result.preferredClub?.clubID,
            club.id
        )

        XCTAssertTrue(
            result.explanation.contains(
                "Live weather was unavailable"
            )
        )
    }
    func testCachedWeatherIsMentionedInExplanation()
        throws {

        let club = Club(
            name: "7 Iron",
            type: .iron,
            averageCarryMeters: 145
        )

        var context = makeContext(
            targetDistanceMeters: 145,
            clubs: [club]
        )

        context.environment = EnvironmentalContext(
            weatherSnapshot: WeatherSnapshot(
                observedAt:
                    Date().addingTimeInterval(
                        -30 * 60
                    ),
                location:
                    context.currentPosition,
                wind: WindContext(
                    speedMetersPerSecond: 3,
                    directionDegrees: 90
                ),
                availability: .cached,
                source: .cachedWeatherKit
            )
        )

        let result =
            try engine.recommend(
                for: context
            )

        XCTAssertTrue(
            result.explanation.contains(
                "Recent cached weather data was used"
            )
        )
    }
}
