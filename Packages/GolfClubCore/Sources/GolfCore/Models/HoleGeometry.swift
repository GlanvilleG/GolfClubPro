//
//  HoleGeometry.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum HoleAreaType: String, Codable, CaseIterable, Sendable {
    case tee
    case fairway
    case rough
    case green
    case fringe
    case bunker
    case water
    case trees
    case outOfBounds
    case penaltyArea
    case cartPath
    case nativeArea
    case unknown
}

public struct HoleArea: Codable, Equatable, Sendable {
    public var type: HoleAreaType
    public var boundary: [GeoCoordinate]

    public init(
        type: HoleAreaType,
        boundary: [GeoCoordinate]
    ) {
        self.type = type
        self.boundary = boundary
    }
}

public struct HoleGeometry: Codable, Equatable, Sendable {

    public var areas: [HoleArea]

    public init(areas: [HoleArea] = []) {
        self.areas = areas
    }
}

public enum LieSource: String, Codable, Sendable {
    case inferredFromHoleGeometry
    case golferConfirmed
    case golferCorrected
    case unknown
}

public struct LieDetectionResult:
    Codable,
    Equatable,
    Sendable {

    public var holeArea:
        HoleAreaType

    public var playableLie:
        PlayableLie

    public var source:
        LieSource

    public var confidence:
        Double?

    public var distanceToBoundaryMeters:
        Double?

    public var confirmationRequirement:
        LieConfirmationRequirement

    public init(
        holeArea: HoleAreaType,
        playableLie: PlayableLie,
        source: LieSource,
        confidence: Double? = nil,
        distanceToBoundaryMeters:
            Double? = nil,
        confirmationRequirement:
            LieConfirmationRequirement =
                .notRequired
    ) {
        self.holeArea =
            holeArea

        self.playableLie =
            playableLie

        self.source =
            source

        self.confidence =
            confidence

        self.distanceToBoundaryMeters =
            distanceToBoundaryMeters

        self.confirmationRequirement =
            confirmationRequirement
    }
}

