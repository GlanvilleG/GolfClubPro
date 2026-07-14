//
//  ConfidenceCalculator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct ConfidenceCalculator:
    Sendable {

    private let configuration:
        LearningConfiguration

    public init(
        configuration:
            LearningConfiguration =
                LearningConfiguration()
    ) {
        self.configuration =
            configuration
    }

    public func confidence(
        sampleCount: Int
    ) -> Double {

        guard sampleCount > 0 else {
            return 0
        }

        let scale =
            Double(
                configuration
                    .confidenceSaturationSamples
            ) / 3.0

        let confidence =
            configuration.maximumConfidence *
            (
                1 -
                exp(
                    -Double(sampleCount) /
                    scale
                )
            )

        return min(
            configuration.maximumConfidence,
            max(0, confidence)
        )
    }
}
