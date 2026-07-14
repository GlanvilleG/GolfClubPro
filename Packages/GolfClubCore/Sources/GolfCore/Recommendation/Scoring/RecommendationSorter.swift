//
//  RecommendationSorter.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct RecommendationSorter:
    Sendable {

    public init() {}

    public func sort(
        _ candidates: [ClubRecommendation]
    ) -> [ClubRecommendation] {

        candidates
            .enumerated()
            .sorted { lhs, rhs in
                let left =
                    lhs.element

                let right =
                    rhs.element

                if left.score != right.score {
                    return left.score >
                        right.score
                }

                if left.distanceDifferenceMeters !=
                    right.distanceDifferenceMeters {

                    return left
                        .distanceDifferenceMeters <
                        right
                            .distanceDifferenceMeters
                }

                if left.confidence !=
                    right.confidence {

                    return left.confidence >
                        right.confidence
                }

                return lhs.offset <
                    rhs.offset
            }
            .map(\.element)
    }
}
