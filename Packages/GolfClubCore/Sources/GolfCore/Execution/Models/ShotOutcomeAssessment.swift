//
//  ShotOutcomeAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct ShotOutcomeAssessment:
    Codable,
    Equatable,
    Sendable {

    public let decisionQuality:
        DecisionQuality

    public let executionQuality:
        ExecutionQuality

    public let feedback:
        [String]

    public init(
        decisionQuality:
            DecisionQuality,
        executionQuality:
            ExecutionQuality,
        feedback:
            [String]
    ) {
        self.decisionQuality =
            decisionQuality

        self.executionQuality =
            executionQuality

        self.feedback =
            feedback
    }
}
public extension ShotOutcomeAssessment {

    static func successful(
        feedback:
            [String]
    ) -> ShotOutcomeAssessment {

        ShotOutcomeAssessment(
            decisionQuality:
                .excellent,
            executionQuality:
                .excellent,
            feedback:
                feedback
        )
    }
}
