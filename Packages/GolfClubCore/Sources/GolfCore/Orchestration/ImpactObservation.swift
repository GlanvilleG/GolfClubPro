//
//  ImpactObservation.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct ImpactObservation:
    Codable,
    Equatable,
    Sendable {

    public var observedAt: Date
    public var confidence: Double
    public var peakMagnitude: Double?

    public init(
        observedAt: Date = Date(),
        confidence: Double,
        peakMagnitude: Double? = nil
    ) {
        self.observedAt = observedAt
        self.confidence = min(1, max(0, confidence))
        self.peakMagnitude = peakMagnitude
    }
}
