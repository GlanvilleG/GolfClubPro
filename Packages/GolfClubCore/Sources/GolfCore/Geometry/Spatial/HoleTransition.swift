//
//  HoleTransition.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public enum HoleTransition:
    Codable,
    Equatable,
    Sendable {

    case noChange

    case possible(
        fromHoleID: HoleID,
        toHoleID: HoleID
    )

    case confirmed(
        fromHoleID: HoleID,
        toHoleID: HoleID
    )

    case locationLost(
        previousHoleID: HoleID
    )
}
