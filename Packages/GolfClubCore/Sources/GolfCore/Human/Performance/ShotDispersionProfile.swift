//
//  ShotDispersionProfile.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import Foundation

public struct ShotDispersionProfile:
    Codable,
    Equatable,
    Sendable {

    public let clubID:
        ClubID

    public var sampleCount:
        Int

    public var averageCarryMeters:
        Double

    public var lateralBiasMeters:
        Double

    public var distanceStandardDeviationMeters:
        Double

    public var lateralStandardDeviationMeters:
        Double

    public var shotShape:
        ShotShape

    public var confidence:
        Double
    
    public var distanceBiasMeters:
        Double

    public init(
        clubID:
            ClubID,
        sampleCount:
            Int = 0,
        averageCarryMeters:
            Double = 0,
        lateralBiasMeters:
            Double = 0,
        distanceStandardDeviationMeters:
            Double = 0,
        lateralStandardDeviationMeters:
            Double = 0,
        shotShape:
            ShotShape = .straight,
        confidence:
            Double = 0,
        distanceBiasMeters:
            Double = 0
    ) {
        self.clubID =
            clubID

        self.sampleCount =
            max(
                0,
                sampleCount
            )

        self.averageCarryMeters =
            max(
                0,
                averageCarryMeters
            )

        self.lateralBiasMeters =
            lateralBiasMeters
        
        self.distanceBiasMeters =
            distanceBiasMeters

        self.distanceStandardDeviationMeters =
            max(
                0,
                distanceStandardDeviationMeters
            )

        self.lateralStandardDeviationMeters =
            max(
                0,
                lateralStandardDeviationMeters
            )

        self.shotShape =
            shotShape

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )
        
    }
}
public extension ShotDispersionProfile {

    var hasSufficientData:
        Bool {

        sampleCount >= 5
    }

    var hasDirectionalBias:
        Bool {

        abs(
            lateralBiasMeters
        ) >= 1
    }

    var isBiasedLeft:
        Bool {

        lateralBiasMeters < -1
    }

    var isBiasedRight:
        Bool {

        lateralBiasMeters > 1
    }
}
public extension ShotDispersionProfile {

    var isConsistentlyShort: Bool {

        distanceBiasMeters < -1
    }

    var isConsistentlyLong: Bool {

        distanceBiasMeters > 1
    }
}
