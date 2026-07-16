//
//  StrategicDecisionEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct StrategicDecisionEngine:
    Sendable {


    public init() {}


    public func select(
        options:
            [StrategicOption]
    ) -> StrategicRecommendation {


        let selected =
            options
                .min {
                    $0.risk.hazardExposure
                    <
                    $1.risk.hazardExposure
                }


        guard let selected
        else {

            fatalError(
                "No strategic options provided."
            )
        }


        return StrategicRecommendation(
            selectedOption:
                selected,
            explanation:
                "Selected the option with the lowest calculated risk.",
            confidence:
                selected.risk.confidence
        )
    }
}
