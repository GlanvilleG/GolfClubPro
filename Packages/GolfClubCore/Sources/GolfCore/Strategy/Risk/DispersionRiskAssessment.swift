//
//  DispersionRiskAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation


public struct DispersionRiskAssessment:
    Codable,
    Equatable,
    Sendable {


    public let riskProbability:
        Double


    public let lateralOffsetMeters:
        Double


    public let dispersionWidthMeters:
        Double


    public let confidence:
        Double


    public init(
        riskProbability:
            Double,
        lateralOffsetMeters:
            Double,
        dispersionWidthMeters:
            Double,
        confidence:
            Double
    ) {

        self.riskProbability =
            min(
                1,
                max(
                    0,
                    riskProbability
                )
            )

        self.lateralOffsetMeters =
            lateralOffsetMeters

        self.dispersionWidthMeters =
            dispersionWidthMeters

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
