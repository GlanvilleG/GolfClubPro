//
//  PlayerCharacteristics.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
public struct OverallPerformanceSummary:
    Codable,
    Equatable,
    Sendable {

    public var averageDrivingDistance: Double
    public var handicapIndex: Double

    public init(
        averageDrivingDistance: Double = 0,
        handicapIndex: Double = 0
    ) {
        self.averageDrivingDistance =
            averageDrivingDistance

        self.handicapIndex =
            handicapIndex
    }
}
