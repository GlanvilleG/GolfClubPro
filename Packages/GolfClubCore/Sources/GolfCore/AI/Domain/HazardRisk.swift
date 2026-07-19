//
//  HazardRisk.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public enum HazardRisk:
    String,
    Codable,
    CaseIterable,
    Comparable,
    Sendable {

    case negligible
    case low
    case moderate
    case high
    case severe

    private var rank: Int {
        switch self {
        case .negligible:
            return 0

        case .low:
            return 1

        case .moderate:
            return 2

        case .high:
            return 3

        case .severe:
            return 4
        }
    }

    public static func < (
        lhs: HazardRisk,
        rhs: HazardRisk
    ) -> Bool {
        lhs.rank < rhs.rank
    }

    public static func classify(
        probability: Double
    ) -> HazardRisk {
        switch probability {
        case ..<0.05:
            return .negligible

        case ..<0.15:
            return .low

        case ..<0.30:
            return .moderate

        case ..<0.50:
            return .high

        default:
            return .severe
        }
    }
}
