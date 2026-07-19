//
//  HoleAreaAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct HoleAreaAssessment:
    Codable,
    Equatable,
    Sendable {

    public let area:
        HoleArea

    public let probability:
        Double

    public let risk:
        HazardRisk

    public init(
        area: HoleArea,
        probability: Double,
        risk: HazardRisk
    ) {
        self.area =
            area

        self.probability =
            max(
                0,
                min(1, probability)
            )

        self.risk =
            risk
    }
}
