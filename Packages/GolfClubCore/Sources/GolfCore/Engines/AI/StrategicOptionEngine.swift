//
//  StrategicOptionEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//

import Foundation

public struct StrategicOptionEngine: Sendable {

    private let riskEngine: RiskModelEngine

    public init(
        riskEngine: RiskModelEngine = RiskModelEngine()
    ) {
        self.riskEngine = riskEngine
    }

    public func determineBestOption(
        from shotContext: ShotContext,
        candidateLandingZones: [LandingZoneEvaluation]
    ) throws -> StrategicOption {

        guard !shotContext.availableClubs.isEmpty else {
            throw StrategicOptionEngineError.noAvailableClubs
        }

        guard !candidateLandingZones.isEmpty else {
            throw StrategicOptionEngineError.noCandidateLandingZones
        }

        var bestOption: StrategicOption?
        var bestScore = Double.infinity

        for landingZone in candidateLandingZones {

            let plannedCarryMeters =
                DistanceCalculator.distanceMeters(
                    from:
                        shotContext.currentPosition,
                    to:
                        landingZone.location
                )

            guard let club =
                selectClub(
                    requiredCarryMeters:
                        plannedCarryMeters,
                    availableClubs:
                        shotContext.availableClubs
                )
            else {
                continue
            }

            let risk =
                riskEngine.evaluate(
                    landingZone:
                        landingZone
                )

            let optionScore =
                rankingScore(
                    landingZone:
                        landingZone,
                    risk:
                        risk
                )

            let metrics =
                StrategicDecisionMetrics(
                    plannedCarryMeters:
                        plannedCarryMeters,
                    optionScore:
                        optionScore,
                    decisionConfidence:
                        .full
                )

            let option =
                StrategicOption(
                    target:
                        landingZone.location,
                    clubID:
                        club.id,
                    landingZone:
                        landingZone,
                    risk:
                        risk,
                    metrics:
                        metrics
                )

            if optionScore < bestScore {
                bestScore =
                    optionScore

                bestOption =
                    option
            }
        }

        guard let bestOption else {
            throw StrategicOptionEngineError.unableToDetermineTarget
        }

        return bestOption
    }
}
private extension StrategicOptionEngine {
    
    private func selectClub(
        requiredCarryMeters:
            Double,
        availableClubs:
            [Club]
    ) -> Club? {

        let measurableClubs =
            availableClubs.filter {
                $0.averageCarryMeters != nil &&
                $0.type != .putter
            }

        return measurableClubs.min {
            firstClub,
            secondClub in

            guard
                let firstCarry =
                    firstClub.averageCarryMeters,
                let secondCarry =
                    secondClub.averageCarryMeters
            else {
                return false
            }

            let firstDifference =
                abs(
                    firstCarry -
                    requiredCarryMeters
                )

            let secondDifference =
                abs(
                    secondCarry -
                    requiredCarryMeters
                )

            return firstDifference <
                secondDifference
        }
    }
    
    private func rankingScore(
        landingZone:
        LandingZoneEvaluation,
        risk:
        RiskAssessment
    ) -> Double {
        
        let riskScore = risk.hazardExposure + risk.penaltyProbability
        
        return landingZone.scoreExpectation + riskScore
    }
}
