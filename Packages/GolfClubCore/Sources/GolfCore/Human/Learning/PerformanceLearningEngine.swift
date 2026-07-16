//
//  PerformanceLearningEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct PerformanceLearningEngine:
    Sendable {

    private let clubLearning:
        ClubLearningEngine


    public init(
        configuration:
            LearningConfiguration =
                LearningConfiguration()
    ) {
        self.clubLearning =
            ClubLearningEngine(
                configuration:
                    configuration
            )
    }


    public func learn(
        observation:
            ShotLearningObservation,
        performance:
            PlayerPerformanceModel
    ) -> PlayerPerformanceModel {

        var updatedPerformance =
            performance


        let existingProfile =
            performance
                .dispersionProfile(
                    for:
                        observation.shot.clubID
                )


        let updatedProfile =
            clubLearning
                .updateDispersionProfile(
                    existing:
                        existingProfile,
                    observation:
                        observation
                )


        updatedPerformance
            .setDispersionProfile(
                updatedProfile
            )
        
        let existingErrorProfile =
            performance
                .errorPatternProfile(
                    for:
                        observation.shot.clubID
                )


        let updatedErrorProfile =
            clubLearning
                .updateErrorPatternProfile(
                    existing:
                        existingErrorProfile,
                    observation:
                        observation
                )


        updatedPerformance
            .setErrorPatternProfile(
                updatedErrorProfile
            )


        return updatedPerformance
    }
}
