//
//  ShotDispersionModel.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//

import Foundation

public struct ShotDispersionModel:
    Codable,
    Equatable,
    Sendable {

    /// Intended landing target.
    public let target: GeoCoordinate

    /// One standard deviation left/right of target.
    public let lateralSigmaMeters: Double

    /// One standard deviation short/long of target.
    public let longitudinalSigmaMeters: Double

    /// Persistent left/right tendency.
    public let lateralBiasMeters: Double

    /// Persistent short/long tendency.
    public let longitudinalBiasMeters: Double

    /// Statistical confidence in this model (0...1).
    public let confidence: Double

    public init(
        target: GeoCoordinate,
        lateralSigmaMeters: Double,
        longitudinalSigmaMeters: Double,
        lateralBiasMeters: Double = 0,
        longitudinalBiasMeters: Double = 0,
        confidence: Double
    ) {

        self.target = target
        self.lateralSigmaMeters = max(0, lateralSigmaMeters)
        self.longitudinalSigmaMeters = max(0, longitudinalSigmaMeters)
        self.lateralBiasMeters = lateralBiasMeters
        self.longitudinalBiasMeters = longitudinalBiasMeters
        self.confidence = min(max(confidence, 0), 1)
    }
}
