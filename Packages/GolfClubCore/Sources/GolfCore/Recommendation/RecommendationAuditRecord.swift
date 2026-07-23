//
//  RecommendationAuditRecord.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

// MARK: - Recommendation Decision
public enum GolferRecommendationDecision: String, Codable, CaseIterable, Sendable {
    case accepted
    case rejected
    case modified
    case notRecorded
}

public struct RecommendationCandidateSnapshot:
    Codable,
    Equatable,
    Sendable {

    public var clubID: ClubID
    public var score: Double
    public var adjustedCarryMeters: Double
    public var confidence: Double

    public init(
        clubID: ClubID,
        score: Double,
        adjustedCarryMeters: Double,
        confidence: Double
    ) {
        self.clubID = clubID
        self.score = score
        self.adjustedCarryMeters = adjustedCarryMeters
        self.confidence = confidence
    }
}

public struct RecommendationAuditRecord:
    Codable,
    Equatable,
    Sendable {

    public let id: RecommendationAuditRecordID

    public var playerID: PlayerID
    public var roundID: RoundID
    public var holeID: HoleID

    public var createdAt: Date

    public var currentPosition: GeoCoordinate
    public var playableLie: PlayableLie
    public var courseArea: HoleAreaType

    public var targetPoint: TargetPoint
    public var targetBearingDegrees: Double
    public var targetDistanceMeters: Double

    public var preferredClubID: ClubID?
    public var alternativeClubIDs: [ClubID]

    public var candidateClubs:
        [RecommendationCandidateSnapshot]

    public var aimOffsetDegrees: Double
    public var riskLevel: ShotRiskLevel
    public var recommendationConfidence: Double

    public var explanation: String

    public var golferDecision: GolferRecommendationDecision
    public var selectedClubID: ClubID?
    public var actualShotID: ShotID?
    
    public var weatherObservedAt: Date?
    public var weatherAvailability: WeatherAvailability
    public var weatherSource: WeatherDataSource

    public var windSpeedMetersPerSecond: Double?
    public var windDirectionDegrees: Double?
    public var windGustMetersPerSecond: Double?

    public var temperatureCelsius: Double?
    public var humidityPercent: Double?
    public var pressureHPa: Double?

    public var explainabilitySnapshot: RecommendationEvidenceSnapshot?
    public init(
        id: RecommendationAuditRecordID =
            RecommendationAuditRecordID(),
        playerID: PlayerID,
        roundID: RoundID,
        holeID: HoleID,
        createdAt: Date = Date(),
        currentPosition: GeoCoordinate,
        playableLie: PlayableLie,
        courseArea: HoleAreaType,
        targetPoint: TargetPoint,
        targetBearingDegrees: Double,
        targetDistanceMeters: Double,
        preferredClubID: ClubID?,
        alternativeClubIDs: [ClubID] = [],
        candidateClubs:
            [RecommendationCandidateSnapshot] = [],
        aimOffsetDegrees: Double,
        riskLevel: ShotRiskLevel,
        recommendationConfidence: Double,
        explanation: String,
        golferDecision: GolferRecommendationDecision =
            .notRecorded,
        selectedClubID: ClubID? = nil,
        actualShotID: ShotID? = nil,
        weatherObservedAt: Date? = nil,
        weatherAvailability: WeatherAvailability = .unavailable,
        weatherSource: WeatherDataSource = .unknown,
        windSpeedMetersPerSecond: Double? = nil,
        windDirectionDegrees: Double? = nil,
        windGustMetersPerSecond: Double? = nil,
        temperatureCelsius: Double? = nil,
        humidityPercent: Double? = nil,
        pressureHPa: Double? = nil,
        explainabilitySnapshot: RecommendationEvidenceSnapshot? = nil
    ) {
        self.id = id
        self.playerID = playerID
        self.roundID = roundID
        self.holeID = holeID
        self.createdAt = createdAt
        self.currentPosition = currentPosition
        self.playableLie = playableLie
        self.courseArea = courseArea
        self.targetPoint = targetPoint
        self.targetBearingDegrees =
            targetBearingDegrees
        self.targetDistanceMeters =
            targetDistanceMeters
        self.preferredClubID = preferredClubID
        self.alternativeClubIDs =
            alternativeClubIDs
        self.candidateClubs = candidateClubs
        self.aimOffsetDegrees =
            aimOffsetDegrees
        self.riskLevel = riskLevel
        self.recommendationConfidence =
            min(1, max(0, recommendationConfidence))
        self.explanation = explanation
        self.golferDecision = golferDecision
        self.selectedClubID = selectedClubID
        self.actualShotID = actualShotID
        self.weatherObservedAt = weatherObservedAt
        self.weatherAvailability = weatherAvailability
        self.weatherSource = weatherSource
        self.windSpeedMetersPerSecond =
            windSpeedMetersPerSecond
        self.windDirectionDegrees =
            windDirectionDegrees
        self.windGustMetersPerSecond =
            windGustMetersPerSecond
        self.temperatureCelsius =
            temperatureCelsius
        self.humidityPercent =
            humidityPercent
        self.pressureHPa =
            pressureHPa
        self.explainabilitySnapshot = explainabilitySnapshot }
}
