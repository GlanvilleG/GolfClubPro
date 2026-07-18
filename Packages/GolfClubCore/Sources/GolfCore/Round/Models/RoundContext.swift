///
//  RoundContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//

import Foundation

public struct RoundContext:
    Codable,
    Equatable,
    Sendable {

    public let round:
        Round

    public let player:
        Player

    public let course:
        Course

    public let hole:
        HoleContext

    public let shot:
        ShotContext

    /// Immutable snapshot of transient information required
    /// by the recommendation pipeline.
    public let recommendationInputs:
        RecommendationInputs

    public init(
        round:
            Round,
        player:
            Player,
        course:
            Course,
        hole:
            HoleContext,
        shot:
            ShotContext,
        recommendationInputs:
            RecommendationInputs = RecommendationInputs()
    ) {

        self.round =
            round

        self.player =
            player

        self.course =
            course

        self.hole =
            hole

        self.shot =
            shot

        self.recommendationInputs =
            recommendationInputs
    }
}
