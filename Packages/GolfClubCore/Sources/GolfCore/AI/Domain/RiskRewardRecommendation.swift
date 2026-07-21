//
//  RiskRewardRecommendation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public enum RiskRewardRecommendation:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case stronglyConservative
    case conservative
    case balanced
    case aggressive
    case stronglyAggressive
}
