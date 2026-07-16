//
//  ShotOutcomeEvaluator.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct ShotOutcomeEvaluator:
    Sendable {

    private let excellentDistanceVarianceMeters:
        Double

    private let goodDistanceVarianceMeters:
        Double

    public init(
        excellentDistanceVarianceMeters:
            Double = 5,
        goodDistanceVarianceMeters:
            Double = 15
    ) {
        self.excellentDistanceVarianceMeters =
            excellentDistanceVarianceMeters

        self.goodDistanceVarianceMeters =
            goodDistanceVarianceMeters
    }

    public func evaluate(
        planned:
            PlannedShotOutcome,
        actual:
            ActualShotOutcome
    ) throws -> ShotOutcomeAssessment {

        guard planned.shotID ==
                actual.shotID
        else {
            throw ShotOutcomeEvaluationError
                .shotIdentityMismatch
        }
        
        let targetAchieved =
            planned.landingArea.contains(
                actual.landingLocation
            )

        let hazardAvoided =
            planned.avoidZones.allSatisfy {
                !$0.contains(
                    actual.landingLocation
                )
            }

        let distanceVariance =
            abs(
                planned.expectedDistanceMeters -
                actual.distanceMeters
            )

        let decisionQuality =
            evaluateDecisionQuality(
                targetAchieved:
                    targetAchieved,
                hazardAvoided:
                    hazardAvoided
            )

        let executionQuality =
            evaluateExecutionQuality(
                distanceVariance:
                    distanceVariance,
                targetAchieved:
                    targetAchieved
            )

        let feedback =
            generateFeedback(
                targetAchieved:
                    targetAchieved,
                hazardAvoided:
                    hazardAvoided,
                distanceVariance:
                    distanceVariance
            )

        return ShotOutcomeAssessment(
            decisionQuality:
                decisionQuality,
            executionQuality:
                executionQuality,
            feedback:
                feedback
        )
    }
}
private extension ShotOutcomeEvaluator {

    func evaluateDecisionQuality(
        targetAchieved:
            Bool,
        hazardAvoided:
            Bool
    ) -> DecisionQuality {

        if targetAchieved &&
            hazardAvoided {

            return .excellent
        }

        if hazardAvoided {

            return .good
        }

        if targetAchieved {

            return .acceptable
        }

        return .poor
    }
}
private extension ShotOutcomeEvaluator {

    func evaluateExecutionQuality(
        distanceVariance:
            Double,
        targetAchieved:
            Bool
    ) -> ExecutionQuality {

        if targetAchieved &&
            distanceVariance <=
                excellentDistanceVarianceMeters {

            return .excellent
        }

        if distanceVariance <=
            goodDistanceVarianceMeters {

            return .good
        }

        return .needsImprovement
    }
}
private extension ShotOutcomeEvaluator {

    func generateFeedback(
        targetAchieved:
            Bool,
        hazardAvoided:
            Bool,
        distanceVariance:
            Double
    ) -> [String] {

        var feedback:
            [String] = []

        if targetAchieved {

            feedback.append(
                "The planned landing area was achieved."
            )
        }
        else {

            feedback.append(
                "The ball finished outside the planned landing area."
            )
        }

        if hazardAvoided {

            feedback.append(
                "The planned hazard risk was successfully avoided."
            )
        }

        if distanceVariance <=
            excellentDistanceVarianceMeters {

            feedback.append(
                "Distance control was excellent."
            )
        }
        else if distanceVariance <=
                    goodDistanceVarianceMeters {

            feedback.append(
                "Distance was within an acceptable range."
            )
        }
        else {

            feedback.append(
                "Distance control requires improvement."
            )
        }

        return feedback
    }
}
