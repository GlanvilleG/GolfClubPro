//
//  HoleAreaType+Classification.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public extension HoleAreaType {

    var isHazard: Bool {
        switch self {
        case .bunker,
             .water,
             .penaltyArea:
            return true

        default:
            return false
        }
    }

    var isPlayingSurface: Bool {
        switch self {
        case .tee,
             .fairway,
             .rough,
             .green,
             .fringe:
            return true

        default:
            return false
        }
    }

    var requiresRulesRelief: Bool {
        switch self {
        case .water,
             .penaltyArea,
             .outOfBounds,
             .cartPath:
            return true

        default:
            return false
        }
    }

    var isSensitiveArea: Bool {
        switch self {
        case .water,
             .penaltyArea,
             .outOfBounds,
             .nativeArea:
            return true

        default:
            return false
        }
    }
}
