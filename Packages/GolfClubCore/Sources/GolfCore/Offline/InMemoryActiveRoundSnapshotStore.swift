//
//  InMemoryActiveRoundSnapshotStore.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public actor InMemoryActiveRoundSnapshotStore:
    ActiveRoundSnapshotStore {

    private var snapshots:
        [RoundID: ActiveRoundSnapshot] = [:]

    public init() {}

    public func save(
        _ snapshot: ActiveRoundSnapshot
    ) async throws {
        snapshots[snapshot.round.id] = snapshot
    }

    public func loadActiveRound(
        roundID: RoundID
    ) async throws -> ActiveRoundSnapshot? {
        snapshots[roundID]
    }

    public func loadMostRecentActiveRound()
        async throws -> ActiveRoundSnapshot? {

        snapshots.values
            .filter {
                $0.round.state != .roundCompleted
            }
            .max {
                $0.capturedAt < $1.capturedAt
            }
    }

    public func deleteActiveRound(
        roundID: RoundID
    ) async throws {
        snapshots.removeValue(
            forKey: roundID
        )
    }
}
