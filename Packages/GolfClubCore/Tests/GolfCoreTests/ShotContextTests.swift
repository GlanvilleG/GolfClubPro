//
//  ShotContextTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotContextTests: XCTestCase {

    func testContextCalculatesRemainingDistance() {
        let player = Player(name: "Gerard")

        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350
        )

        let currentPosition = GeoCoordinate(
            latitude: -39.9300,
            longitude: 175.0500
        )

        let greenCentre = GeoCoordinate(
            latitude: -39.9290,
            longitude: 175.0510
        )

        let geometry = HoleStrategyGeometry(
            holeID: hole.id,
            greenCentre: greenCentre
        )

        let context = ShotContext(
            player: player,
            roundID: RoundID(),
            hole: hole,
            currentPosition: currentPosition,
            playableLie: .fairway,
            courseArea: .fairway,
            availableClubs: [],
            strategyGeometry: geometry
        )

        XCTAssertGreaterThan(
            context.remainingDistanceMeters,
            0
        )

        XCTAssertEqual(
            context.finalTarget,
            greenCentre
        )
    }

    func testContextUsesPinWhenAvailable() {
        let hole = Hole(
            number: 2,
            par: 3,
            lengthMeters: 150
        )

        let greenCentre = GeoCoordinate(
            latitude: 1,
            longitude: 1
        )

        let pin = GeoCoordinate(
            latitude: 1.0001,
            longitude: 1.0001
        )

        let geometry = HoleStrategyGeometry(
            holeID: hole.id,
            greenCentre: greenCentre,
            pinLocation: pin
        )

        let context = ShotContext(
            player: Player(name: "Gerard"),
            roundID: RoundID(),
            hole: hole,
            currentPosition: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            playableLie: .tee,
            courseArea: .tee,
            availableClubs: [],
            strategyGeometry: geometry
        )

        XCTAssertEqual(context.finalTarget, pin)
    }

    func testEnvironmentalContextStoresWind() {
        let wind = WindContext(
            speedMetersPerSecond: 5,
            directionDegrees: 270
        )

        let environment = EnvironmentalContext(
            wind: wind,
            temperatureCelsius: 18,
            humidityPercent: 70,
            pressureHPa: 1012,
            elevationChangeMeters: 4
        )

        XCTAssertEqual(
            environment.wind?.speedMetersPerSecond,
            5
        )

        XCTAssertEqual(
            environment.wind?.directionDegrees,
            270
        )

        XCTAssertEqual(
            environment.elevationChangeMeters,
            4
        )
    }

    func testRecentShotSummaryStoresPlayerHistory() {
        let clubID = ClubID()

        let summary = RecentShotSummary(
            clubID: clubID,
            averageDistanceMeters: 145,
            commonErrors: [.push, .short],
            sampleSize: 12
        )

        XCTAssertEqual(summary.clubID, clubID)
        XCTAssertEqual(summary.averageDistanceMeters, 145)
        XCTAssertEqual(summary.commonErrors, [.push, .short])
        XCTAssertEqual(summary.sampleSize, 12)
    }

    func testNegativeSampleSizeIsClampedToZero() {
        let summary = RecentShotSummary(
            clubID: ClubID(),
            sampleSize: -5
        )

        XCTAssertEqual(summary.sampleSize, 0)
    }

    func testNegativeWindSpeedIsClampedToZero() {
        let wind = WindContext(
            speedMetersPerSecond: -3,
            directionDegrees: 90
        )

        XCTAssertEqual(wind.speedMetersPerSecond, 0)
    }
}
