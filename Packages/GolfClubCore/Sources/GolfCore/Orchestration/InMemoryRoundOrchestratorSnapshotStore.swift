//
//  InMemoryRoundOrchestratorSnapshotStore.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//
import Foundation

public actor InMemoryRoundOrchestratorSnapshotStore:
    RoundOrchestratorSnapshotStore {

    private var snapshots:
        [RoundID: RoundOrchestratorSnapshot] = [:]

    public init() {}

    public func save(
        _ snapshot: RoundOrchestratorSnapshot
    ) async throws {
        snapshots[snapshot.roundID] = snapshot
    }

    public func load(
        roundID: RoundID
    ) async throws -> RoundOrchestratorSnapshot? {
        snapshots[roundID]
    }

    public func delete(
        roundID: RoundID
    ) async throws {
        snapshots.removeValue(
            forKey: roundID
        )
    }
}
