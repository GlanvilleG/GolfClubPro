//
//  InstructionPriority.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//
// InstructionPriority.swift
//

import Foundation


public enum InstructionPriority:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case normal
    case advisory
    case caution
}
