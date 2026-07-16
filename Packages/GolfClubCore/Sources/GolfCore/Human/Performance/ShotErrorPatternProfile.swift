//
//  ShotErrorPatternProfile.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import Foundation

public struct ShotErrorPatternProfile:
    Codable,
    Equatable,
    Sendable {

    public let clubID:
        ClubID

    public var sampleCount:
        Int

    public var errors:
        [ShotErrorFrequency]

    public init(
        clubID: ClubID,
        sampleCount: Int = 0,
        errors: [ShotErrorFrequency] = []
    ) {
        self.clubID =
            clubID

        self.sampleCount =
            max(
                0,
                sampleCount
            )

        self.errors =
            errors
    }
}

public extension ShotErrorPatternProfile {

    var dominantError:
        ShotErrorFrequency? {

        errors.max {
            lhs,
            rhs in

            if lhs.occurrenceCount ==
                rhs.occurrenceCount {

                return lhs.error.rawValue <
                    rhs.error.rawValue
            }

            return lhs.occurrenceCount <
                rhs.occurrenceCount
        }
    }

    var hasSufficientData:
        Bool {

        sampleCount >= 5
    }

    func frequency(
        for error: ShotError
    ) -> ShotErrorFrequency? {

        errors.first {
            $0.error == error
        }
    }
}
