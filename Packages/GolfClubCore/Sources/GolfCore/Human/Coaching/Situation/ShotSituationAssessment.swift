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
        self.situation = situation
        self.confidence = confidence
        self.rationale = rationale
    }
}
