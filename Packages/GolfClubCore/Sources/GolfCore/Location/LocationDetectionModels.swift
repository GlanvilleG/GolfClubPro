//
//  LocationDetectionModels.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//
import Foundation

public enum LocationDetectionStatus:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case detected
    case ambiguous
    case notFound
    case insufficientAccuracy
}

public struct GolfClubDetectionCandidate:
    Codable,
    Equatable,
    Sendable {

    public var golfClubID: GolfClubID
    public var distanceMeters: Double
    public var confidence: Double

    public init(
        golfClubID: GolfClubID,
        distanceMeters: Double,
        confidence: Double
    ) {
        self.golfClubID = golfClubID
        self.distanceMeters = max(0, distanceMeters)
        self.confidence = min(1, max(0, confidence))
    }
}

public struct GolfClubDetectionResult:
    Codable,
    Equatable,
    Sendable {

    public var status: LocationDetectionStatus
    public var selectedGolfClubID: GolfClubID?
    public var confidence: Double
    public var candidates: [GolfClubDetectionCandidate]

    public init(
        status: LocationDetectionStatus,
        selectedGolfClubID: GolfClubID? = nil,
        confidence: Double = 0,
        candidates: [GolfClubDetectionCandidate] = []
    ) {
        self.status = status
        self.selectedGolfClubID = selectedGolfClubID
        self.confidence = min(1, max(0, confidence))
        self.candidates = candidates
    }
}

public struct HoleDetectionCandidate:
    Codable,
    Equatable,
    Sendable {

    public var holeID: HoleID
    public var distanceToTeeMeters: Double
    public var confidence: Double

    public init(
        holeID: HoleID,
        distanceToTeeMeters: Double,
        confidence: Double
    ) {
        self.holeID = holeID
        self.distanceToTeeMeters =
            max(0, distanceToTeeMeters)
        self.confidence =
            min(1, max(0, confidence))
    }
}

public struct HoleDetectionResult:
    Codable,
    Equatable,
    Sendable {

    public var status: LocationDetectionStatus
    public var selectedHoleID: HoleID?
    public var confidence: Double
    public var candidates: [HoleDetectionCandidate]

    public init(
        status: LocationDetectionStatus,
        selectedHoleID: HoleID? = nil,
        confidence: Double = 0,
        candidates: [HoleDetectionCandidate] = []
    ) {
        self.status = status
        self.selectedHoleID = selectedHoleID
        self.confidence = min(1, max(0, confidence))
        self.candidates = candidates
    }
}
