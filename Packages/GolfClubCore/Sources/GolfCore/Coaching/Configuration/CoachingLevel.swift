//
//  CoachingLevel.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public enum CoachingLevel:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case off
    case beginner
    case intermediate
    case standard
    case advanced
    case professional
    case adaptiveAI
}
