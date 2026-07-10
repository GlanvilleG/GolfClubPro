//
//  Shot.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public enum PlayableLie: String, Codable, CaseIterable, Sendable {
    case tee
    case fairway
    case lightRough
    case deepRough
    case fringe
    case green
    case fairwayBunker
    case greensideBunker
    case pluggedBunker
    case trees
    case treeRoots
    case pineStraw
    case cartPath
    case water
    case penaltyArea
    case outOfBounds
    case recovery
    case unknown
}

public struct Shot: Codable, Equatable, Sendable {
    public let id: ShotID
    public var roundID: RoundID
    public var holeID: HoleID
    public var clubID: ClubID

    public var startedAt: Date
    public var completedAt: Date?

    public var startLocation: GeoCoordinate?
    public var endLocation: GeoCoordinate?
    public var distanceMeters: Double?

    public var inferredCourseArea: CourseAreaType?
    public var inferredPlayableLie: PlayableLie?
    public var confirmedPlayableLie: PlayableLie?
    public var lieSource: LieSource?
    public var lieDetectionConfidence: Double?
    public var lieConfirmationRequirement: LieConfirmationRequirement?

    public var effectivePlayableLie: PlayableLie {
        confirmedPlayableLie ?? inferredPlayableLie ?? .unknown
    }

    public var feedback: ShotFeedback?

    public init(
        id: ShotID = ShotID(),
        roundID: RoundID,
        holeID: HoleID,
        clubID: ClubID,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        startLocation: GeoCoordinate? = nil,
        endLocation: GeoCoordinate? = nil,
        distanceMeters: Double? = nil,
        inferredCourseArea: CourseAreaType? = nil,
        inferredPlayableLie: PlayableLie? = nil,
        confirmedPlayableLie: PlayableLie? = nil,
        lieSource: LieSource? = nil,
        lieDetectionConfidence: Double? = nil,
        lieConfirmationRequirement: LieConfirmationRequirement? = nil,
        feedback: ShotFeedback? = nil
    ) {
        self.id = id
        self.roundID = roundID
        self.holeID = holeID
        self.clubID = clubID
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.distanceMeters = distanceMeters
        self.inferredCourseArea = inferredCourseArea
        self.inferredPlayableLie = inferredPlayableLie
        self.confirmedPlayableLie = confirmedPlayableLie
        self.lieSource = lieSource
        self.lieDetectionConfidence = lieDetectionConfidence
        self.lieConfirmationRequirement = lieConfirmationRequirement
        self.feedback = feedback
    }
}
