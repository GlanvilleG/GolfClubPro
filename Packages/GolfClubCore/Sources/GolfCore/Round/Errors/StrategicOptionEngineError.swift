//
//  StrategicOptionEngineError.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//
import Foundation

public enum StrategicOptionEngineError:
    Error,
    Equatable,
    Sendable {

    case noAvailableClubs
    case noCandidateLandingZones
    case unableToDetermineTarget
}
