//
//  HoleLocationConfidence.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public enum HoleLocationConfidence:
    Double,
    Codable,
    CaseIterable,
    Sendable {

    case none = 0.0
    case possible = 0.25
    case likely = 0.50
    case high = 0.75
    case certain = 1.0
}
