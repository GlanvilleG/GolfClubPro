//
//  ShotOutcomeEvaluationError.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import Foundation

public enum ShotOutcomeEvaluationError:
    Error,
    Equatable,
    Sendable {

    case shotIdentityMismatch
}
