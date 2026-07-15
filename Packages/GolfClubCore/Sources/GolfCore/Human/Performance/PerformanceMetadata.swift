//
//  PerformanceMetadata.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

public struct PerformanceMetadata:
    Codable,
    Equatable,
    Sendable {

    /// When the performance model was first created.
    public let createdAt:
        Date

    /// When the model was last updated.
    public var lastUpdatedAt:
        Date

    /// Number of rounds contributing to this model.
    public var roundsAnalysed:
        Int

    /// Total number of shots represented.
    public var shotsAnalysed:
        Int

    /// Version of the performance model schema.
    public var modelVersion:
        Int

    public init(
        createdAt: Date = Date(),
        lastUpdatedAt: Date = Date(),
        roundsAnalysed: Int = 0,
        shotsAnalysed: Int = 0,
        modelVersion: Int = 1
    ) {
        self.createdAt =
            createdAt

        self.lastUpdatedAt =
            lastUpdatedAt

        self.roundsAnalysed =
            roundsAnalysed

        self.shotsAnalysed =
            shotsAnalysed

        self.modelVersion =
            modelVersion
    }
}
public extension PerformanceMetadata {

    var hasPerformanceData:
        Bool {

        shotsAnalysed > 0
    }

    var isEmpty:
        Bool {

        roundsAnalysed == 0 &&
        shotsAnalysed == 0
    }
}
