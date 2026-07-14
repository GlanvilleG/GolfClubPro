//
//  PlayerCharacteristics.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
public struct PlayerCharacteristics:
    Codable,
    Equatable,
    Sendable {

    public var dominantShotShape:
        ShotShape

    public var confidence:
        Double

    public var totalRecordedShots:
        Int
}
