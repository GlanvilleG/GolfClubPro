//
//  LandingZoneEvaluation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct LandingZoneEvaluation:
    Codable,
    Equatable,
    Sendable {


    public let location:
        GeoCoordinate


    public let lieQuality:
        PlayableLie


    public let hazardExposure:
        Double


    public let nextShotDistance:
        Double


    public let scoreExpectation:
        Double



    public init(
        location:
            GeoCoordinate,
        lieQuality:
            PlayableLie,
        hazardExposure:
            Double,
        nextShotDistance:
            Double,
        scoreExpectation:
            Double
    ) {

        self.location =
            location

        self.lieQuality =
            lieQuality

        self.hazardExposure =
            min(
                1,
                max(
                    0,
                    hazardExposure
                )
            )

        self.nextShotDistance =
            nextShotDistance

        self.scoreExpectation =
            scoreExpectation
    }
}
