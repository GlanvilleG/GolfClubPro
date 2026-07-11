//
//  LocationService.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public protocol LocationService: Sendable {

    func currentLocation()
        async throws -> LocationObservation

    func locationUpdates()
        -> AsyncStream<LocationObservation>
}
