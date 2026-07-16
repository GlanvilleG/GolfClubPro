//
//  ClubLearningEvent.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation

public struct ClubLearningEvent:
    Codable,
    Equatable,
    Sendable {

    public let shot:
        Shot

    public let assessment:
        ShotOutcomeAssessment

    public init(
        shot:
            Shot,
        assessment:
            ShotOutcomeAssessment
    ) {
        self.shot =
            shot

        self.assessment =
            assessment
    }
}
