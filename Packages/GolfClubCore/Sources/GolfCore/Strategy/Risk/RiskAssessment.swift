//
//  RiskAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation

public enum RiskLevel:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case low
    case moderate
    case high
    case extreme
}


public struct RiskAssessment:
    Codable,
    Equatable,
    Sendable {

    public let riskLevel:
        RiskLevel

    public let hazardExposure:
        Double

    public let penaltyProbability:
        Double

    public let recommendation:
        String

    public let confidence:
        Double


    public init(
        riskLevel:
            RiskLevel,
        hazardExposure:
            Double,
        penaltyProbability:
            Double,
        recommendation:
            String,
        confidence:
            Double
    ) {

        self.riskLevel =
            riskLevel

        self.hazardExposure =
            min(
                1,
                max(
                    0,
                    hazardExposure
                )
            )

        self.penaltyProbability =
            min(
                1,
                max(
                    0,
                    penaltyProbability
                )
            )

        self.recommendation =
            recommendation

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )
    }
}
