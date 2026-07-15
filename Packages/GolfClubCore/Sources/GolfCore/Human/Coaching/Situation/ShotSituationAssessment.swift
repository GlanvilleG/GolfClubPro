//
//  ShotSituationAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct ShotSituationAssessment:
    Codable,
    Equatable,
    Sendable {

    public let situation:
        ShotSituation

    public let confidence:
        Double

    public let rationale:
        String

    public init(
        situation: ShotSituation,
        confidence: Double,
        rationale: String
    ) {
        self.situation =
            situation

        self.confidence =
            min(
                1,
                max(0, confidence)
            )

        self.rationale =
            rationale
    }
}
public extension ShotSituationAssessment {

    static let unknown =
        ShotSituationAssessment(
            situation: .unknown,
            confidence: 0,
            rationale:
                "The available shot information was insufficient to classify the situation."
        )
}
