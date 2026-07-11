//
//  RoundOrchestratorSnapshotStore.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public protocol RoundOrchestratorSnapshotStore:
    Sendable {

    func save(
        _ snapshot: RoundOrchestratorSnapshot
    ) async throws

    func load(
        roundID: RoundID
    ) async throws -> RoundOrchestratorSnapshot?

    func delete(
        roundID: RoundID
    ) async throws
}
