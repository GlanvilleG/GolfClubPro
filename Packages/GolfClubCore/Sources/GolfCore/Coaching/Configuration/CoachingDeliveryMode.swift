//
//  CoachingDeliveryMode.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import Foundation

public enum CoachingDeliveryMode:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case watch
    case iphone
    case voice
    case coachReview
}
