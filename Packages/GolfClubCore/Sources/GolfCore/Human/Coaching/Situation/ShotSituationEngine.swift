//
//  ShotSituationEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public struct ShotSituationEngine:
    Sendable {

    private let shortPuttThresholdMeters:
        Double

    private let chipThresholdMeters:
        Double

    private let pitchThresholdMeters:
        Double

    private let shortIronThresholdMeters:
        Double

    private let longApproachThresholdMeters:
        Double

    public init(
        shortPuttThresholdMeters:
            Double = 8,
        chipThresholdMeters:
            Double = 25,
        pitchThresholdMeters:
            Double = 90,
        shortIronThresholdMeters:
            Double = 130,
        longApproachThresholdMeters:
            Double = 170
    ) {
        self.shortPuttThresholdMeters =
            shortPuttThresholdMeters

        self.chipThresholdMeters =
            chipThresholdMeters

        self.pitchThresholdMeters =
            pitchThresholdMeters
        
        self.shortIronThresholdMeters =
            shortIronThresholdMeters

        self.longApproachThresholdMeters =
            longApproachThresholdMeters
    }

    public func classify(
        recommendation:
            RecommendationDecision,
        context:
            ShotContext
    ) -> ShotSituationAssessment {

        guard let preferred =
                recommendation.preferredClub,
              let selectedClub =
                context.availableClubs.first(
                    where: {
                        $0.id ==
                            preferred.clubID
                    }
                )
        else {
            return .unknown
        }

        let targetDistance =
            recommendation
                .shotPlan
                .targetDistanceMeters

        // MARK: - Putting

        if context.playableLie == .green,
           selectedClub.type == .putter {

            return classifyPutt(
                targetDistanceMeters:
                    targetDistance
            )
        }

        // MARK: - Bunkers

        switch context.playableLie {

        case .greensideBunker,
             .pluggedBunker:

            return ShotSituationAssessment(
                situation:
                    .greensideBunker,
                confidence:
                    1,
                rationale:
                    "The ball is in a greenside bunker."
            )

        case .fairwayBunker:

            return ShotSituationAssessment(
                situation:
                    .fairwayBunker,
                confidence:
                    1,
                rationale:
                    "The ball is in a fairway bunker."
            )

        default:
            break
        }

        // MARK: - Recovery

        switch context.playableLie {

        case .trees,
             .treeRoots,
             .pineStraw:

            return ShotSituationAssessment(
                situation:
                    .punchShot,
                confidence:
                    0.95,
                rationale:
                    "The lie requires a controlled recovery beneath or around an obstruction."
            )

        case .recovery:

            if selectedClub.type == .hybrid {
                return ShotSituationAssessment(
                    situation:
                        .hybridRecovery,
                    confidence:
                        0.90,
                    rationale:
                        "A hybrid has been selected for a recovery shot."
                )
            }

            return ShotSituationAssessment(
                situation:
                    .punchShot,
                confidence:
                    0.85,
                rationale:
                    "The current lie requires a recovery shot."
            )

        default:
            break
        }

        // MARK: - Tee shots

        if context.playableLie == .tee {

            switch selectedClub.type {

            case .driver:

                return ShotSituationAssessment(
                    situation:
                        .driverTeeShot,
                    confidence:
                        1,
                    rationale:
                        "A driver has been selected from the tee."
                )

            case .fairwayWood:

                return ShotSituationAssessment(
                    situation:
                        .fairwayWoodTeeShot,
                    confidence:
                        1,
                    rationale:
                        "A fairway wood has been selected from the tee."
                )

            default:
                break
            }
        }

        // MARK: - Short game

        if selectedClub.type == .wedge {

            if targetDistance <=
                chipThresholdMeters {

                return ShotSituationAssessment(
                    situation:
                        .chip,
                    confidence:
                        0.90,
                    rationale:
                        "A wedge has been selected for a short shot near the green."
                )
            }

            if targetDistance <=
                pitchThresholdMeters {

                return ShotSituationAssessment(
                    situation:
                        .pitch,
                    confidence:
                        0.90,
                    rationale:
                        "A wedge has been selected for a controlled pitch."
                )
            }
        }

        // MARK: - Approach shots

        if isPlayableApproachLie(
            context.playableLie
        ) {
            return classifyApproach(
                targetDistanceMeters:
                    targetDistance
            )
        }

        return .unknown
    }

    // MARK: - Putting

    private func classifyPutt(
        targetDistanceMeters:
            Double
    ) -> ShotSituationAssessment {

        if targetDistanceMeters <=
            shortPuttThresholdMeters {

            return ShotSituationAssessment(
                situation:
                    .shortPutt,
                confidence:
                    1,
                rationale:
                    "The ball is on the green and the target is within the short-putt threshold."
            )
        }

        return ShotSituationAssessment(
            situation:
                .longPutt,
            confidence:
                1,
            rationale:
                "The ball is on the green and the target exceeds the short-putt threshold."
        )
    }

    // MARK: - Approach

    private func classifyApproach(
        targetDistanceMeters:
            Double
    ) -> ShotSituationAssessment {

        if targetDistanceMeters >
            longApproachThresholdMeters {

            return ShotSituationAssessment(
                situation:
                    .longApproach,
                confidence:
                    0.85,
                rationale:
                    "The required distance exceeds the long-approach threshold."
            )
        }

        if targetDistanceMeters >
            shortIronThresholdMeters {

            return ShotSituationAssessment(
                situation:
                    .midIronApproach,
                confidence:
                    0.85,
                rationale:
                    "The required distance is within the mid-iron approach range."
            )
        }

        return ShotSituationAssessment(
            situation:
                .shortIronApproach,
            confidence:
                0.85,
            rationale:
                "The required distance is within the short-iron approach range."
        )
    }

    // MARK: - Lie Classification

    private func isPlayableApproachLie(
        _ lie: PlayableLie
    ) -> Bool {

        switch lie {

        case .fairway,
             .lightRough,
             .deepRough:

            return true

        default:
            return false
        }
    }
}
