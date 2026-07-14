//
//  LearningConfiguration.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct LearningConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var minimumConfidenceSamples: Int

    public var confidenceSaturationSamples: Int

    public var maximumConfidence: Double

    /// Future weighting based on dispersion.
    public var enableDispersionAdjustment: Bool

    public init(
        minimumConfidenceSamples: Int = 10,
        confidenceSaturationSamples: Int = 100,
        maximumConfidence: Double = 0.99,
        enableDispersionAdjustment: Bool = false
    ) {
        self.minimumConfidenceSamples =
            minimumConfidenceSamples

        self.confidenceSaturationSamples =
            confidenceSaturationSamples

        self.maximumConfidence =
            maximumConfidence

        self.enableDispersionAdjustment =
            enableDispersionAdjustment
    }
}
