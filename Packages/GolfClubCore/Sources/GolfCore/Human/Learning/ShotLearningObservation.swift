//
//  ShotLearningObservation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import Foundation

public struct ShotLearningObservation:
    Codable,
    Equatable,
    Sendable {

    public let shot:
        Shot

    public let plannedOutcome:
        PlannedShotOutcome

    public let actualOutcome:
        ActualShotOutcome

    public let assessment:
        ShotOutcomeAssessment


    public init(
        shot:
            Shot,
        plannedOutcome:
            PlannedShotOutcome,
        actualOutcome:
            ActualShotOutcome,
        assessment:
            ShotOutcomeAssessment
    ) {

        self.shot =
            shot

        self.plannedOutcome =
            plannedOutcome

        self.actualOutcome =
            actualOutcome

        self.assessment =
            assessment
    }
}

public extension ShotLearningObservation {

    var hasConsistentIdentity:
        Bool {

        shot.id ==
            plannedOutcome.shotID
        &&
        shot.id ==
            actualOutcome.shotID
    }
}
