//
//  ActiveRoundSnapshotStore.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public protocol ActiveRoundSnapshotStore: Sendable {

    func save(
        _ snapshot: ActiveRoundSnapshot
    ) async throws

    func loadActiveRound(
        roundID: RoundID
    ) async throws -> ActiveRoundSnapshot?

    func loadMostRecentActiveRound()
        async throws -> ActiveRoundSnapshot?

    func deleteActiveRound(
        roundID: RoundID
    ) async throws
}
