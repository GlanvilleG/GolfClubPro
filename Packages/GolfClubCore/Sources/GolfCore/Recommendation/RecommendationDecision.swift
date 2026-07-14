//
//  RecommendationDecision.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

/// The canonical decision produced by the recommendation engine.
///
/// This represents the golfing decision only.
/// It intentionally contains no presentation or audit information.
public struct RecommendationDecision:
    Codable,
   Equatable,
    Sendable {

    public let shotPlan:
        ShotPlan

    public let preferredClub:
        ClubRecommendation?

    public let alternatives:
        [ClubRecommendation]

    public let aimOffsetDegrees:
        Double

    public init(
        shotPlan: ShotPlan,
        preferredClub: ClubRecommendation?,
        alternatives: [ClubRecommendation],
        aimOffsetDegrees: Double
    ) {
        self.shotPlan =
            shotPlan

        self.preferredClub =
            preferredClub

        self.alternatives =
            alternatives

        self.aimOffsetDegrees =
            aimOffsetDegrees
    }
}
