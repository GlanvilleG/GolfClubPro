//
//  ShotShape.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

public enum ShotShape:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case draw
    case fade
    case straight
    case hook
    case slice
    case pull
    case push
    case unknown
}
