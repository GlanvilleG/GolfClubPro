//
//  DispersionConfidence.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//

import Foundation

public struct DispersionConfidence:
    Codable,
    Equatable,
    Sendable {

    /// Number of historical shots contributing to the model.
    public let historicalShots: Int

    /// Confidence in the statistical model (0...1).
    public let confidence: Double

    public init(
        historicalShots: Int,
        confidence: Double
    ) {

        self.historicalShots = max(0, historicalShots)
        self.confidence = min(max(confidence, 0), 1)
    }
}
