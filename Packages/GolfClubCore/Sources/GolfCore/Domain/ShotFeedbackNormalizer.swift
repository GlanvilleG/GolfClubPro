//
//  ShotFeedbackNormalizer.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct ShotFeedbackNormalizer: Sendable {

    public init() {}

    public func normalize(_ transcript: String) -> ShotFeedback {
        let normalized = transcript
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let errors = classifyErrors(from: normalized)
        let sentiment = classifySentiment(from: normalized, errors: errors)

        return ShotFeedback(
            rawTranscript: transcript,
            classifiedErrors: errors,
            sentiment: sentiment
        )
    }

    private func classifyErrors(from text: String) -> [ShotError] {
        var errors = Set<ShotError>()

        let mappings: [(phrases: [String], error: ShotError)] = [
            (["mishit", "mis-hit", "bad strike"], .mishit),
            (["bad lie"], .badLie),
            (["trouble", "in trouble"], .trouble),

            (["push", "pushed", "pushed it"], .push),
            (["pull", "pulled", "pulled it"], .pull),
            (["slice", "sliced"], .slice),
            (["hook", "hooked"], .hook),
            (["fade"], .fade),
            (["draw"], .draw),

            (["chunk", "chunked", "fat"], .chunk),
            (["thin", "thinned", "blade", "bladed"], .thin),
            (["top", "topped"], .top),
            (["shank", "shanked"], .shank),
            (["duff", "duffed"], .duff),
            (["whiff", "missed the ball"], .whiff),

            (["short", "left it short", "came up short"], .short),
            (["long", "came up long", "too long"], .long),
            (["flew it", "over hit", "overhit"], .overHit),

            (["rough", "in the rough"], .rough),
            (["trees", "in the trees"], .trees),
            (["bunker", "sand", "sand trap"], .bunker),
            (["water", "drink", "wet", "that's wet"], .water),
            (["out of bounds", "ob", "o b"], .outOfBounds),

            (["duck hook"], .duckHook),
            (["banana ball"], .bananaBall),
            (["worm burner"], .wormBurner),
            (["reload"], .reload),
            (["got away with that", "tree love", "lucky"], .luckyOutcome)
        ]

        for mapping in mappings {
            if mapping.phrases.contains(where: { text.contains($0) }) {
                errors.insert(mapping.error)
            }
        }

        return Array(errors).sorted { $0.rawValue < $1.rawValue }
    }

    private func classifySentiment(
        from text: String,
        errors: [ShotError]
    ) -> ShotSentiment? {
        if text.contains("fore") {
            return .warning
        }

        if text.contains("good") ||
            text.contains("great") ||
            text.contains("perfect") ||
            text.contains("nice") ||
            text.contains("got away with that") {
            return .positive
        }

        if errors.isEmpty {
            return .neutral
        }

        return .negative
    }
}
