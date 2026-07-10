//
//  CandidateSwing.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct CandidateSwing:
    Codable,
    Equatable,
    Sendable {

    public var observation: SwingObservation
    public var origin: GeoCoordinate?

    public var impactDetected: Bool
    public var impactConfidence: Double?

    public var golferDepartedOrigin: Bool
    public var feedbackReceived: Bool
    public var nextClubSelectedElsewhere: Bool

    public var computedConfidence: Double
    public var classification: SwingClassification

    public init(
        observation: SwingObservation,
        origin: GeoCoordinate? = nil,
        impactDetected: Bool = false,
        impactConfidence: Double? = nil,
        golferDepartedOrigin: Bool = false,
        feedbackReceived: Bool = false,
        nextClubSelectedElsewhere: Bool = false,
        computedConfidence: Double = 0,
        classification: SwingClassification = .uncertain
    ) {
        self.observation = observation
        self.origin = origin
        self.impactDetected = impactDetected
        self.impactConfidence =
            impactConfidence.map { min(1, max(0, $0)) }
        self.golferDepartedOrigin = golferDepartedOrigin
        self.feedbackReceived = feedbackReceived
        self.nextClubSelectedElsewhere =
            nextClubSelectedElsewhere
        self.computedConfidence =
            min(1, max(0, computedConfidence))
        self.classification = classification
    }
}
