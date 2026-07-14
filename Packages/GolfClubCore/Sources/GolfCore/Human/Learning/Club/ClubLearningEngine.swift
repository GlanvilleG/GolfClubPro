//
//  ClubLearningEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

public struct ClubLearningEngine:
    Sendable {

    private let configuration:
        LearningConfiguration

    public init(
        configuration:
            LearningConfiguration =
                LearningConfiguration()
    ) {
        self.configuration =
            configuration
    }
}
