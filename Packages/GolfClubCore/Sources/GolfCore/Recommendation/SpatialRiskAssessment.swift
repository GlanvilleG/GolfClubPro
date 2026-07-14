//
//  SpatialRiskAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

public struct SpatialRiskAssessment:
    Codable,
    Equatable,
    Sendable {

    public let penalty:
        Double

    public let reasons:
        [RecommendationReason]

    public init(
        penalty: Double,
        reasons: [RecommendationReason]
    ) {
        self.penalty =
            min(
                1,
                max(0, penalty)
            )

        self.reasons =
            reasons
    }

    public static let none =
        SpatialRiskAssessment(
            penalty: 0,
            reasons: []
        )
}
