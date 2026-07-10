//
//  LieConfirmationRequirement.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum LieConfirmationReason:
    String,
    Codable,
    CaseIterable,
    Sendable {
    case lowConfidence
    case nearBoundary
    case unknownArea
    case sensitiveArea
}

public enum LieConfirmationRequirement:
    Codable,
    Equatable,
    Sendable {

    case notRequired

    case recommended(
        inferredLie: PlayableLie,
        reasons: [LieConfirmationReason]
    )

    case required(
        inferredLie: PlayableLie,
        reasons: [LieConfirmationReason]
    )

    public var shouldPromptGolfer: Bool {
        switch self {
        case .notRequired:
            return false

        case .recommended, .required:
            return true
        }
    }
}
