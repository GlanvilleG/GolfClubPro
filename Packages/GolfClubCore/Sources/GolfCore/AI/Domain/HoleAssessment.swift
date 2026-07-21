//
//  HoleAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct HoleAssessment:
    Codable,
    Equatable,
    Sendable {

    public let areaAssessments:
        [HoleAreaAssessment]

    public let overallRisk:
        HazardRisk

    public init(
        areaAssessments:
            [HoleAreaAssessment],
        overallRisk:
            HazardRisk
    ) {
        self.areaAssessments =
            areaAssessments

        self.overallRisk =
            overallRisk
    }

    /// Normalized probability that the expected shot outcome
    /// intersects one or more strategically adverse hole areas.
    ///
    /// The result is constrained to the range `0...1`.
    public var expectedRisk:
        Double {

        let adverseProbabilities =
            areaAssessments
                .filter {
                    $0.area.type.isStrategicallyAdverse
                }
                .map {
                    Self.clampProbability(
                        $0.probability
                    )
                }

        guard !adverseProbabilities.isEmpty else {
            return 0
        }

        let probabilityOfAvoidingAllAreas =
            adverseProbabilities.reduce(1.0) {
                currentProbability,
                areaProbability in

                currentProbability *
                    (1.0 - areaProbability)
            }

        return Self.clampProbability(
            1.0 -
                probabilityOfAvoidingAllAreas
        )
    }

    public var hazardAssessments:
        [HoleAreaAssessment] {

        areaAssessments.filter {
            $0.area.type.isHazard
        }
    }

    public var rulesReliefAssessments:
        [HoleAreaAssessment] {

        areaAssessments.filter {
            $0.area.type.requiresRulesRelief
        }
    }

    public var sensitiveAreaAssessments:
        [HoleAreaAssessment] {

        areaAssessments.filter {
            $0.area.type.isSensitiveArea
        }
    }

    private static func clampProbability(
        _ value:
            Double
    ) -> Double {

        min(
            max(value, 0),
            1
        )
    }
}
import Foundation

public extension HoleAreaAssessment {

    var areaType: HoleAreaType {
        area.type
    }
}
