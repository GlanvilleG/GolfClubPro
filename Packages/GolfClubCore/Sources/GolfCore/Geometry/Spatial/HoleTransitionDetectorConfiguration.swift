//
//  HoleTransitionDetectorConfiguration.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct HoleTransitionDetectorConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var requiredConsecutiveObservations:
        Int

    public var minimumDestinationConfidence:
        HoleLocationConfidence

    public init(
        requiredConsecutiveObservations:
            Int = 2,
        minimumDestinationConfidence:
            HoleLocationConfidence = .high
    ) {
        self.requiredConsecutiveObservations =
            max(
                1,
                requiredConsecutiveObservations
            )

        self.minimumDestinationConfidence =
            minimumDestinationConfidence
    }
}
