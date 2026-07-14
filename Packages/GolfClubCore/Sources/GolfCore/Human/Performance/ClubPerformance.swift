//
//  ClubPerformance.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct ClubPerformance:
    Codable,
    Equatable,
    Sendable {

    public let clubID:
        ClubID

    private var carryAccumulator:
        WelfordAccumulator

    private var totalAccumulator:
        WelfordAccumulator

    public private(set) var shortestCarryMeters:
        Double

    public private(set) var longestCarryMeters:
        Double

    public private(set) var confidence:
        Double

    public private(set) var preferredShotShape:
        ShotShape

    public init(
        clubID: ClubID,
        preferredShotShape:
            ShotShape = .unknown
    ) {
        self.clubID =
            clubID

        self.carryAccumulator =
            WelfordAccumulator()

        self.totalAccumulator =
            WelfordAccumulator()

        self.shortestCarryMeters =
            0

        self.longestCarryMeters =
            0

        self.confidence =
            0

        self.preferredShotShape =
            preferredShotShape
    }
}
public extension ClubPerformance {

    var shotCount: Int {
        carryAccumulator.sampleCount
    }

    var averageCarryMeters: Double {
        carryAccumulator.mean
    }

    var averageTotalMeters: Double {
        totalAccumulator.mean
    }

    var carryVariance: Double {
        carryAccumulator.variance
    }

    var totalVariance: Double {
        totalAccumulator.variance
    }

    var carryStandardDeviation:
        Double {

        carryAccumulator
            .standardDeviation
    }

    var totalStandardDeviation:
        Double {

        totalAccumulator
            .standardDeviation
    }

    var hasRecordedShots: Bool {
        carryAccumulator.hasSamples
    }

    var hasEnoughData: Bool {
        shotCount >= 10
    }
}
extension ClubPerformance {

    var currentCarryAccumulator:
        WelfordAccumulator {

        carryAccumulator
    }

    var currentTotalAccumulator:
        WelfordAccumulator {

        totalAccumulator
    }

    mutating func applyLearningState(
        carryAccumulator:
            WelfordAccumulator,
        totalAccumulator:
            WelfordAccumulator,
        shortestCarryMeters:
            Double,
        longestCarryMeters:
            Double,
        confidence:
            Double,
        preferredShotShape:
            ShotShape
    ) {
        self.carryAccumulator =
            carryAccumulator

        self.totalAccumulator =
            totalAccumulator

        self.shortestCarryMeters =
            shortestCarryMeters

        self.longestCarryMeters =
            longestCarryMeters

        self.confidence =
            min(
                1,
                max(0, confidence)
            )

        self.preferredShotShape =
            preferredShotShape
    }
}
