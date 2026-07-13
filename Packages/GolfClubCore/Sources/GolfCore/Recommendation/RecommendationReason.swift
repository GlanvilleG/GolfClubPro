//
//  RecommendationReason.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

public enum RecommendationReason:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case distanceFit
    case lieSuitability
    case hazardAvoidance
    case boundaryRisk
    case routeSafety
    case lowConfidence
    case recovery
    case layup
    case aggressiveOption
    case conservativeOption
}
