//
//  CourseGeometry.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum CourseAreaType: String, Codable, CaseIterable, Sendable {
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

public struct CourseArea: Codable, Equatable, Sendable {
    public var type: CourseAreaType
    public var boundary: [GeoCoordinate]

    public init(
        type: CourseAreaType,
        boundary: [GeoCoordinate]
    ) {
        self.type = type
        self.boundary = boundary
    }
}

public struct CourseGeometry: Codable, Equatable, Sendable {
    public var areas: [CourseArea]

    public init(areas: [CourseArea] = []) {
        self.areas = areas
    }
}

public enum LieSource: String, Codable, Sendable {
    case inferredFromCourseGeometry
    case golferConfirmed
    case golferCorrected
    case unknown
}

public struct LieDetectionResult:
    Codable,
    Equatable,
    Sendable {

    public var courseArea:
        CourseAreaType

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
        courseArea: CourseAreaType,
        playableLie: PlayableLie,
        source: LieSource,
        confidence: Double? = nil,
        distanceToBoundaryMeters:
            Double? = nil,
        confirmationRequirement:
            LieConfirmationRequirement =
                .notRequired
    ) {
        self.courseArea =
            courseArea

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
