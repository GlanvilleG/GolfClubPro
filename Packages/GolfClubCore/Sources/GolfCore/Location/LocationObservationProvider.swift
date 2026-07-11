//
//  LocationService.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public protocol LocationObservationProvider:
    Sendable {

    func observations()
        async -> AsyncStream<LocationObservation>
}
