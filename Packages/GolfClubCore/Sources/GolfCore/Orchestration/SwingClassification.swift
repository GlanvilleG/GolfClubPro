//
//  SwingClassification.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum SwingClassification:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case practice
    case playedShot
    case uncertain
    case golferCorrected
}
