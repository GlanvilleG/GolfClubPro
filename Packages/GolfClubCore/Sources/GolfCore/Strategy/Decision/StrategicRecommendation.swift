//
//  StrategicRecommendation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct StrategicRecommendation:
    Codable,
    Equatable,
    Sendable {


    public let selectedOption:
        StrategicOption


    public let explanation:
        String


    public let confidence:
        Double


    public init(
        selectedOption:
            StrategicOption,
        explanation:
            String,
        confidence:
            Double
    ) {

        self.selectedOption =
            selectedOption

        self.explanation =
            explanation

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
