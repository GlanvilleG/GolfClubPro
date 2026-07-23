//
//  PlayerIntelligenceIntegrationExample.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//

import Foundation

/// Internal helper demonstrating how to generate and inject PlayerIntelligence into RecommendationEngine
/// without changing public APIs. This is a non-breaking integration helper intended to guide integration
/// within the module. Production code may build PlayerIntelligence in a dedicated context or builder layer.
internal struct PlayerIntelligenceIntegrator {
    internal init() {}

    /// Demonstrates how to build PlayerIntelligence and inject it into RecommendationEngine without changing public APIs.
    /// This is intended as integration guidance and may be adapted in app code or builders.
    internal func makeRecommendationEngine(
        playerID: PlayerID,
        dispersionProfiles: [ShotDispersionProfile],
        shotHistory: ShotHistoryProvider,
        roundHistory: RoundHistoryProvider,
        clock: @Sendable @escaping () -> Date = { Date() }
    ) async throws -> RecommendationEngine {
        let engine = PlayerPerformanceEngine(clock: clock)
        let intelligence = try await engine.analyze(
            playerID: playerID,
            dispersionProfiles: dispersionProfiles,
            shotHistory: shotHistory,
            roundHistory: roundHistory
        )
        // Use internal initializer to inject snapshot
        // NOTE: Adjust the argument label to match RecommendationEngine's available initializers.
        // If RecommendationEngine has a different API, update this label accordingly.
        var recommendationEngine = RecommendationEngine()
        recommendationEngine.injectedPlayerIntelligence = intelligence
        return recommendationEngine
    }
}

