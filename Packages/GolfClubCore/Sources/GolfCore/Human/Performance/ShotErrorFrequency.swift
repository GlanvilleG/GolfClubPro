//
//  ShotErrorFrequency.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import Foundation

public struct ShotErrorFrequency:
    Codable,
    Equatable,
    Sendable {

    public let error:
        ShotError

    public var occurrenceCount:
        Int

    public var percentage:
        Double

    public init(
        error: ShotError,
        occurrenceCount: Int,
        percentage: Double
    ) {
        self.error =
            error

        self.occurrenceCount =
            max(
                0,
                occurrenceCount
            )

        self.percentage =
            min(
                1,
                max(
                    0,
                    percentage
                )
            )
    }
}
