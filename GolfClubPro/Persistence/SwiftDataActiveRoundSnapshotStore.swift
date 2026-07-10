//
//  SwiftDataActiveRoundSnapshotStore.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation
import SwiftData
import GolfCore

public enum SwiftDataSnapshotStoreError:
    Error,
    Equatable,
    Sendable {

    case encodingFailed
    case decodingFailed
}

@ModelActor
public actor SwiftDataActiveRoundSnapshotStore:
    ActiveRoundSnapshotStore {

    public func save(
        _ snapshot: ActiveRoundSnapshot
    ) async throws {
        let encodedSnapshot: Data

        do {
            encodedSnapshot = try JSONEncoder()
                .encode(snapshot)
        } catch {
            throw SwiftDataSnapshotStoreError
                .encodingFailed
        }

        let roundID = snapshot.round.id.value

        let descriptor =
            FetchDescriptor<ActiveRoundSnapshotRecord>(
                predicate: #Predicate {
                    $0.roundID == roundID
                }
            )

        if let existingRecord =
            try modelContext.fetch(descriptor).first {

            existingRecord.capturedAt =
                snapshot.capturedAt

            existingRecord.roundState =
                snapshot.round.state.rawValue

            existingRecord.localRevision =
                snapshot.localRevision

            existingRecord.encodedSnapshot =
                encodedSnapshot
        } else {
            let record = ActiveRoundSnapshotRecord(
                roundID: roundID,
                capturedAt: snapshot.capturedAt,
                roundState:
                    snapshot.round.state.rawValue,
                localRevision:
                    snapshot.localRevision,
                encodedSnapshot:
                    encodedSnapshot
            )

            modelContext.insert(record)
        }

        try modelContext.save()
    }

    public func loadActiveRound(
        roundID: RoundID
    ) async throws -> ActiveRoundSnapshot? {
        let roundUUID = roundID.value

        let descriptor =
            FetchDescriptor<ActiveRoundSnapshotRecord>(
                predicate: #Predicate {
                    $0.roundID == roundUUID
                }
            )

        guard let record =
            try modelContext.fetch(descriptor).first
        else {
            return nil
        }

        return try decode(record.encodedSnapshot)
    }

    public func loadMostRecentActiveRound()
        async throws -> ActiveRoundSnapshot? {

        var descriptor =
            FetchDescriptor<ActiveRoundSnapshotRecord>(
                sortBy: [
                    SortDescriptor(
                        \.capturedAt,
                        order: .reverse
                    )
                ]
            )

        descriptor.fetchLimit = 20

        let records =
            try modelContext.fetch(descriptor)

        for record in records {
            let snapshot =
                try decode(record.encodedSnapshot)

            if snapshot.round.state !=
                .roundCompleted {
                return snapshot
            }
        }

        return nil
    }

    public func deleteActiveRound(
        roundID: RoundID
    ) async throws {
        let roundUUID = roundID.value

        let descriptor =
            FetchDescriptor<ActiveRoundSnapshotRecord>(
                predicate: #Predicate {
                    $0.roundID == roundUUID
                }
            )

        let records =
            try modelContext.fetch(descriptor)

        for record in records {
            modelContext.delete(record)
        }

        try modelContext.save()
    }

    private func decode(
        _ data: Data
    ) throws -> ActiveRoundSnapshot {
        do {
            return try JSONDecoder().decode(
                ActiveRoundSnapshot.self,
                from: data
            )
        } catch {
            throw SwiftDataSnapshotStoreError
                .decodingFailed
        }
    }
}
