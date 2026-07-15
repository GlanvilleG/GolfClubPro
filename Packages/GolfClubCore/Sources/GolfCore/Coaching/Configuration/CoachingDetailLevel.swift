//
//  CoachingDetailLevel.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public enum CoachingDetailLevel:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case essentials
    case standard
    case detailed
    case professional
}
