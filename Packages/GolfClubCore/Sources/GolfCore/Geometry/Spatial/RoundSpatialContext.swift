//
//  RoundSpatialContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct RoundSpatialContext:
    Codable,
    Equatable,
    Sendable {

    public let observedAt:
        Date

    public let golferPosition:
        GeoCoordinate

    public let hole:
        Hole?

    public let holeLocationConfidence:
        HoleLocationConfidence

    public let holeArea:
        HoleAreaType?

    public let playableLie:
        PlayableLie?

    public let distanceToTeeMeters:
        Double?

    public let distanceToGreenMeters:
        Double?

    public let remainingDistanceMeters:
        Double?

    public let nearestBoundaryDistanceMeters:
        Double?

    public let requiresConfirmation:
        Bool

    public init(
        observedAt: Date,
        golferPosition: GeoCoordinate,
        hole: Hole?,
        holeLocationConfidence:
            HoleLocationConfidence,
        holeArea:
            HoleAreaType? = nil,
        playableLie:
            PlayableLie? = nil,
        distanceToTeeMeters:
            Double? = nil,
        distanceToGreenMeters:
            Double? = nil,
        remainingDistanceMeters:
            Double? = nil,
        nearestBoundaryDistanceMeters:
            Double? = nil,
        requiresConfirmation:
            Bool = false
    ) {
        self.observedAt =
            observedAt

        self.golferPosition =
            golferPosition

        self.hole =
            hole

        self.holeLocationConfidence =
            holeLocationConfidence

        self.holeArea =
            holeArea

        self.playableLie =
            playableLie

        self.distanceToTeeMeters =
            distanceToTeeMeters

        self.distanceToGreenMeters =
            distanceToGreenMeters

        self.remainingDistanceMeters =
            remainingDistanceMeters

        self.nearestBoundaryDistanceMeters =
            nearestBoundaryDistanceMeters

        self.requiresConfirmation =
            requiresConfirmation
    }
}
