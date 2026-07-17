//
//  HoleContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//

import Foundation

public struct HoleContext:
    Codable,
    Equatable,
    Sendable {

    public let hole:
        Hole

    public let shots:
        [Shot]

    public let currentLie:
        PlayableLie

    public let remainingDistanceMeters:
        Double

    public let shotsPlayed:
        Int

    public let greenReached:
        Bool


    public init(
        hole:
            Hole,
        shots:
            [Shot],
        currentLie:
            PlayableLie,
        remainingDistanceMeters:
            Double,
        shotsPlayed:
            Int,
        greenReached:
            Bool
    ) {

        self.hole =
            hole

        self.shots =
            shots

        self.currentLie =
            currentLie

        self.remainingDistanceMeters =
            max(
                0,
                remainingDistanceMeters
            )

        self.shotsPlayed =
            max(
                0,
                shotsPlayed
            )

        self.greenReached =
            greenReached
    }
}
