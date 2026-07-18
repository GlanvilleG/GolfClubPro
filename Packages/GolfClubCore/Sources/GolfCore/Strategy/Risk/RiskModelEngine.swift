//
//  RiskModelEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//
//  RiskModelEngine.swift
//  GolfClubCore
//

import Foundation


public struct RiskModelEngine:
    Sendable {


    public init() {}



    public func evaluate(
        landingZone:
            LandingZoneEvaluation
    ) -> RiskAssessment {


        let exposure =
            landingZone.hazardExposure


        let level =
            classifyRisk(
                exposure:
                    exposure
            )


        return RiskAssessment(
            riskLevel:
                level,
            hazardExposure:
                exposure,
            penaltyProbability:
                exposure,
            recommendation:
                recommendation(
                    level:
                        level
                ),
            confidence:
                0.5
        )
    }



    private func classifyRisk(
        exposure:
            Double
    ) -> RiskLevel {


        switch exposure {

        case 0..<0.2:
            return .low


        case 0.2..<0.5:
            return .moderate


        case 0.5..<0.75:
            return .high


        default:
            return .extreme
        }
    }



    private func recommendation(
        level:
            RiskLevel
    ) -> String {


        switch level {

        case .low:

            return "Proceed with normal target."


        case .moderate:

            return "Consider additional margin."


        case .high:

            return "Select a safer landing area."


        case .extreme:

            return "Avoid this target area."
        }
    }
}
