//
//  RiskRewardBalance.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public enum RiskRewardBalance:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable {

    case veryConservative
    case conservative
    case neutral
    case aggressive
    case veryAggressive
}
