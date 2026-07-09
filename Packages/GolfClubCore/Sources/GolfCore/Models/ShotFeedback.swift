//
//  ShotFeedback.swift
//  GolfCore
//
//  Created by Dragon Development on 09/07/2026.
//

import Foundation

public enum ShotError: String, Codable, CaseIterable, Sendable {
    case mishit, miss, badLie, trouble
    case push, pull, slice, hook, fade, draw
    case chunk, fat, thin, blade, top, shank, duff, whiff
    case short, long, overHit
    case rough, trees, bunker, water, outOfBounds
    case duckHook, bananaBall, wormBurner, reload, luckyOutcome
}

public enum ShotSentiment: String, Codable, Sendable {
    case positive
    case neutral
    case negative
    case warning
}

public struct ShotFeedback: Codable, Equatable, Sendable {
    public var rawTranscript: String
    public var classifiedErrors: [ShotError]
    public var sentiment: ShotSentiment?
    public var capturedAt: Date

    public init(
        rawTranscript: String,
        classifiedErrors: [ShotError] = [],
        sentiment: ShotSentiment? = nil,
        capturedAt: Date = Date()
    ) {
        self.rawTranscript = rawTranscript
        self.classifiedErrors = classifiedErrors
        self.sentiment = sentiment
        self.capturedAt = capturedAt
    }
}
