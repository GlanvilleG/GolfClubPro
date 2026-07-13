//
//  CourseGeometryResult.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

public struct HoleGeometryAreaMatch:
    Codable,
    Equatable,
    Sendable {

    public let areaType: HoleAreaType
    public let containsLocation: Bool
    public let distanceToBoundaryMeters: Double

    public init(
        areaType: HoleAreaType,
        containsLocation: Bool,
        distanceToBoundaryMeters: Double
    ) {
        self.areaType = areaType
        self.containsLocation =
            containsLocation

        self.distanceToBoundaryMeters =
            max(
                0,
                distanceToBoundaryMeters
            )
    }
}

public struct HoleGeometryResult:
    Codable,
    Equatable,
    Sendable {

    public let primaryArea: HoleAreaType
    public let matches:
        [HoleGeometryAreaMatch]

    public let nearestBoundaryDistanceMeters:
        Double?

    public let confidence: Double

    public let requiresConfirmation: Bool

    public init(
        primaryArea: HoleAreaType,
        matches: [HoleGeometryAreaMatch],
        nearestBoundaryDistanceMeters:
            Double?,
        confidence: Double,
        requiresConfirmation: Bool
    ) {
        self.primaryArea = primaryArea
        self.matches = matches
        self.nearestBoundaryDistanceMeters =
            nearestBoundaryDistanceMeters
        self.confidence =
            min(
                1,
                max(0, confidence)
            )
        self.requiresConfirmation =
            requiresConfirmation
    }
}
