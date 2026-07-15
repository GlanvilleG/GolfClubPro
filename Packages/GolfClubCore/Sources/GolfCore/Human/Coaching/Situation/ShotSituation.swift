//
//  ShotSituation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

public enum ShotSituation:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case driverTeeShot

    case fairwayWoodTeeShot

    case fairwayApproach

    case longIronApproach

    case shortIronApproach

    case hybridRecovery

    case punchShot

    case layUp

    case pitch

    case chip

    case greensideBunker

    case fairwayBunker

    case longPutt

    case shortPutt

    case unknown
}
