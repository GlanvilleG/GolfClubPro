//
//  SwingObservation.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct SwingObservation:
    Codable,
    Equatable,
    Sendable {

    public var observedAt: Date
    public var durationSeconds: Double
    public var peakAcceleration: Double?
    public var peakRotationRate: Double?
    public var returnedToAddress: Bool
    public var confidence: Double

    public init(
        observedAt: Date = Date(),
        durationSeconds: Double,
        peakAcceleration: Double? = nil,
        peakRotationRate: Double? = nil,
        returnedToAddress: Bool,
        confidence: Double
    ) {
        self.observedAt = observedAt
        self.durationSeconds = max(0, durationSeconds)
        self.peakAcceleration = peakAcceleration
        self.peakRotationRate = peakRotationRate
        self.returnedToAddress = returnedToAddress
        self.confidence = min(1, max(0, confidence))
    }
}
