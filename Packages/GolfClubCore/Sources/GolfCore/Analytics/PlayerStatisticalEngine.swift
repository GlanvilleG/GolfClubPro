//
//  PlayerStatisticalEngine.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct PlayerStatisticsEngine: Sendable {

    public init() {}

    public func makeRecentShotSummaries(
        from shots: [Shot],
        maximumShotsPerClub: Int = 20
    ) -> [RecentShotSummary] {
        let completedShots = shots.filter {
            $0.completedAt != nil
        }

        let groupedShots = Dictionary(
            grouping: completedShots,
            by: \.clubID
        )

        return groupedShots
            .map { clubID, clubShots in
                makeSummary(
                    clubID: clubID,
                    shots: Array(
                        clubShots
                            .sorted {
                                $0.completedAt ?? $0.startedAt >
                                $1.completedAt ?? $1.startedAt
                            }
                            .prefix(max(1, maximumShotsPerClub))
                    )
                )
            }
            .sorted {
                $0.clubID.value.uuidString <
                $1.clubID.value.uuidString
            }
    }

    public func makeSummary(
        for clubID: ClubID,
        from shots: [Shot],
        maximumShots: Int = 20
    ) -> RecentShotSummary {
        let matchingShots = shots
            .filter {
                $0.clubID == clubID &&
                $0.completedAt != nil
            }
            .sorted {
                $0.completedAt ?? $0.startedAt >
                $1.completedAt ?? $1.startedAt
            }

        return makeSummary(
            clubID: clubID,
            shots: Array(
                matchingShots.prefix(max(1, maximumShots))
            )
        )
    }

    private func makeSummary(
        clubID: ClubID,
        shots: [Shot]
    ) -> RecentShotSummary {
        let recordedDistances = shots.compactMap {
            $0.distanceMeters
        }

        let averageDistance: Double?

        if recordedDistances.isEmpty {
            averageDistance = nil
        } else {
            averageDistance =
                recordedDistances.reduce(0, +) /
                Double(recordedDistances.count)
        }

        let commonErrors = mostCommonErrors(
            from: shots,
            maximumCount: 3
        )

        return RecentShotSummary(
            clubID: clubID,
            averageDistanceMeters: averageDistance,
            commonErrors: commonErrors,
            sampleSize: shots.count
        )
    }

    private func mostCommonErrors(
        from shots: [Shot],
        maximumCount: Int
    ) -> [ShotError] {
        var counts: [ShotError: Int] = [:]

        for shot in shots {
            for error in shot.feedback?.classifiedErrors ?? [] {
                counts[error, default: 0] += 1
            }
        }

        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key.rawValue <
                        rhs.key.rawValue
                }

                return lhs.value > rhs.value
            }
            .prefix(maximumCount)
            .map(\.key)
    }
}
