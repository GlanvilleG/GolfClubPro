//
//  NarrationVariant.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// The level of detail for generated narration.
public enum NarrationVariant: String, Codable, CaseIterable, Sendable {
    /// Minimal, intended for active play on Apple Watch.
    case concise
    /// Balanced, intended for expanded Watch or iPhone display.
    case standard
    /// Most detailed, intended for iPhone review or post-round analysis.
    case detailed
}

