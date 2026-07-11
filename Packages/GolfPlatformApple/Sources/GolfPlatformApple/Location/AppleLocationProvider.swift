//
//  AppleLocationProvider.swift
//  GolfPlatformApple
//
//  Created by Dragon Development on 11/07/2026.
//

import CoreLocation

import Foundation

import GolfCore

@MainActor

public final class AppleLocationProvider:

    NSObject,

    @preconcurrency CLLocationManagerDelegate {

    private let manager: CLLocationManager

    private let observationStream:

        AsyncStream<LocationObservation>

    private let observationContinuation:

        AsyncStream<LocationObservation>.Continuation

    public private(set) var authorizationStatus:

        CLAuthorizationStatus

    public private(set) var latestObservation:

        LocationObservation?

    public override init() {

        let manager = CLLocationManager()

        let streamPair =

            AsyncStream<LocationObservation>

                .makeStream()

        self.manager = manager

        self.observationStream = streamPair.stream

        self.observationContinuation =

            streamPair.continuation

        self.authorizationStatus =

            manager.authorizationStatus

        super.init()

        manager.delegate = self

        manager.desiredAccuracy =

            kCLLocationAccuracyBest

        manager.distanceFilter = 5

        manager.activityType = .fitness

        #if os(iOS)

        manager.pausesLocationUpdatesAutomatically = true

        #endif
    }


    public func requestAuthorization() {
        guard CLLocationManager
            .locationServicesEnabled()
        else {
            return
        }

        if manager.authorizationStatus ==
            .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    public func startUpdates() {
        switch manager.authorizationStatus {
        case .authorizedAlways,
             .authorizedWhenInUse:
            manager.startUpdatingLocation()

        case .notDetermined:
            requestAuthorization()

        case .denied,
             .restricted:
            observationContinuation.finish()

        @unknown default:
            observationContinuation.finish()
        }
    }

    public func stopUpdates() {
        manager.stopUpdatingLocation()
    }

    public func observations()
        -> AsyncStream<LocationObservation> {
        observationStream
    }

    public func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        authorizationStatus =
            manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways,
             .authorizedWhenInUse:
            manager.startUpdatingLocation()

        case .denied,
             .restricted:
            observationContinuation.finish()

        case .notDetermined:
            break

        @unknown default:
            observationContinuation.finish()
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location =
            bestLocation(in: locations)
        else {
            return
        }

        let observation =
            Self.makeObservation(
                from: location
            )

        latestObservation = observation
        observationContinuation.yield(
            observation
        )
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        guard let locationError =
                error as? CLError,
              locationError.code ==
                .locationUnknown
        else {
            return
        }

        // A locationUnknown error is normally temporary,
        // so location updates remain active.
    }

    public static func makeObservation(
        from location: CLLocation
    ) -> LocationObservation {
        LocationObservation(
            coordinate: GeoCoordinate(
                latitude:
                    location.coordinate.latitude,
                longitude:
                    location.coordinate.longitude
            ),
            observedAt:
                location.timestamp,
            horizontalAccuracyMeters:
                location.horizontalAccuracy >= 0
                ? location.horizontalAccuracy
                : nil
        )
    }

    private func bestLocation(
        in locations: [CLLocation]
    ) -> CLLocation? {
        locations
            .filter {
                $0.horizontalAccuracy >= 0
            }
            .filter {
                abs(
                    $0.timestamp
                        .timeIntervalSinceNow
                ) <= 30
            }
            .min {
                $0.horizontalAccuracy <
                    $1.horizontalAccuracy
            }
    }
}
