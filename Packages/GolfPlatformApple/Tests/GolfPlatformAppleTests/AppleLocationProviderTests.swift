//
//  AppleLocationProviderTests.swift
//  GolfPlatformApple
//
//  Created by Dragon Development on 11/07/2026.
//
import CoreLocation
import GolfCore
import Testing
@testable import GolfPlatformApple

@Suite("Apple Location Provider")
struct AppleLocationProviderTests {

    @Test("CLLocation converts to a GolfCore observation")
    @MainActor
    func convertsLocation() {
        let timestamp = Date(
            timeIntervalSince1970:
                1_700_000_000
        )

        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            altitude: 20,
            horizontalAccuracy: 4,
            verticalAccuracy: 6,
            timestamp: timestamp
        )

        let observation =
            AppleLocationProvider
                .makeObservation(from: location)

        #expect(
            observation.coordinate.latitude ==
                -39.9300
        )

        #expect(
            observation.coordinate.longitude ==
                175.0500
        )

        #expect(
            observation.horizontalAccuracyMeters ==
                4
        )

        #expect(
            observation.observedAt == timestamp
        )
    }

    @Test("Negative location accuracy becomes nil")
    @MainActor
    func rejectsNegativeAccuracy() {
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 0,
                longitude: 0
            ),
            altitude: 0,
            horizontalAccuracy: -1,
            verticalAccuracy: -1,
            timestamp: Date()
        )

        let observation =
            AppleLocationProvider
                .makeObservation(from: location)

        #expect(
            observation
                .horizontalAccuracyMeters == nil
        )
    }
}
