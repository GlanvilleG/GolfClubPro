//
//  RecommendationPipelineError.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//

import Foundation

public enum RecommendationPipelineError:
    Error,
    Equatable,
    Sendable {

    case noCandidateLandingZones
    case selectedClubUnavailable
}
