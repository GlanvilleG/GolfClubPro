//
//  WeatherSnapshotTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class WeatherSnapshotTests: XCTestCase {

    func testFreshSnapshotIsClassifiedLive() {
        let now = Date()

        let snapshot = makeSnapshot(
            observedAt: now.addingTimeInterval(-5 * 60)
        )

        XCTAssertEqual(
            snapshot.classifiedAvailability(
                relativeTo: now
            ),
            .live
        )
    }

    func testOlderSnapshotIsClassifiedCached() {
        let now = Date()

        let snapshot = makeSnapshot(
            observedAt: now.addingTimeInterval(-30 * 60)
        )

        XCTAssertEqual(
            snapshot.classifiedAvailability(
                relativeTo: now
            ),
            .cached
        )
    }

    func testOldSnapshotIsClassifiedStale() {
        let now = Date()

        let snapshot = makeSnapshot(
            observedAt: now.addingTimeInterval(-60 * 60)
        )

        XCTAssertEqual(
            snapshot.classifiedAvailability(
                relativeTo: now
            ),
            .stale
        )
    }

    func testHumidityIsClamped() {
        let snapshot = WeatherSnapshot(
            observedAt: Date(),
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            humidityPercent: 150,
            availability: .live,
            source: .weatherKit
        )

        XCTAssertEqual(
            snapshot.humidityPercent,
            100
        )
    }

    func testNegativePrecipitationIsClamped() {
        let snapshot = WeatherSnapshot(
            observedAt: Date(),
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            precipitationMillimetres: -5,
            availability: .live,
            source: .weatherKit
        )

        XCTAssertEqual(
            snapshot.precipitationMillimetres,
            0
        )
    }

    func testEnvironmentalContextExposesWeatherValues() {
        let wind = WindContext(
            speedMetersPerSecond: 5,
            directionDegrees: 270
        )

        let snapshot = WeatherSnapshot(
            observedAt: Date(),
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            wind: wind,
            temperatureCelsius: 18,
            humidityPercent: 70,
            pressureHPa: 1012,
            availability: .live,
            source: .weatherKit
        )

        let context = EnvironmentalContext(
            weatherSnapshot: snapshot,
            elevationChangeMeters: 4
        )

        XCTAssertEqual(
            context.wind,
            wind
        )

        XCTAssertEqual(
            context.temperatureCelsius,
            18
        )

        XCTAssertEqual(
            context.weatherAvailability,
            .live
        )
    }

    private func makeSnapshot(
        observedAt: Date
    ) -> WeatherSnapshot {
        WeatherSnapshot(
            observedAt: observedAt,
            location: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            availability: .live,
            source: .weatherKit
        )
    }
}
