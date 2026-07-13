//
//  HoleLocationResult.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct HoleLocationResult:
    Codable,
    Equatable,
    Sendable {

    public let hole: Hole?

    public let confidence:
        HoleLocationConfidence

    public let distanceToTeeMeters:
        Double?

    public let distanceToGreenMeters:
        Double?

    public let nearestArea:
        HoleAreaType?

    public let requiresConfirmation:
        Bool

    public init(
        hole: Hole?,
        confidence: HoleLocationConfidence,
        distanceToTeeMeters: Double? = nil,
        distanceToGreenMeters: Double? = nil,
        nearestArea: HoleAreaType? = nil,
        requiresConfirmation: Bool = false
    ) {
        self.hole = hole
        self.confidence = confidence
        self.distanceToTeeMeters =
            distanceToTeeMeters
        self.distanceToGreenMeters =
            distanceToGreenMeters
        self.nearestArea = nearestArea
        self.requiresConfirmation =
            requiresConfirmation
    }
}
