//
//  SwiftDataRoundOrchestratorSnapshotStore.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation
import GolfCore
import SwiftData

enum SwiftDataOrchestratorSnapshotStoreError:
    Error,
    Equatable,
    Sendable {

    case encodingFailed
    case decodingFailed
}

@ModelActor
actor SwiftDataRoundOrchestratorSnapshotStore:
    RoundOrchestratorSnapshotStore {

    func save(
        _ snapshot: RoundOrchestratorSnapshot
    ) async throws {
        let encodedSnapshot: Data

        do {
            encodedSnapshot = try JSONEncoder()
                .encode(snapshot)
        } catch {
            throw SwiftDataOrchestratorSnapshotStoreError
                .encodingFailed
        }

        let roundUUID = snapshot.roundID.value

        let descriptor =
            FetchDescriptor<RoundOrchestratorSnapshotRecord>(
                predicate: #Predicate {
                    $0.roundID == roundUUID
                }
            )

        if let existing =
            try modelContext.fetch(descriptor).first {

            existing.stateRawValue =
                snapshot.state.rawValue

            existing.capturedAt =
                snapshot.capturedAt

            existing.localRevision =
                snapshot.localRevision

            existing.encodedSnapshot =
                encodedSnapshot
        } else {
            let record =
                RoundOrchestratorSnapshotRecord(
                    roundID: roundUUID,
                    stateRawValue:
                        snapshot.state.rawValue,
                    capturedAt:
                        snapshot.capturedAt,
                    localRevision:
                        snapshot.localRevision,
                    encodedSnapshot:
                        encodedSnapshot
                )

            modelContext.insert(record)
        }

        try modelContext.save()
    }

    func load(
        roundID: RoundID
    ) async throws -> RoundOrchestratorSnapshot? {
        let roundUUID = roundID.value

        let descriptor =
            FetchDescriptor<RoundOrchestratorSnapshotRecord>(
                predicate: #Predicate {
                    $0.roundID == roundUUID
                }
            )

        guard let record =
                try modelContext.fetch(descriptor).first
        else {
            return nil
        }

        return try decode(
            record.encodedSnapshot
        )
    }

    func delete(
        roundID: RoundID
    ) async throws {
        let roundUUID = roundID.value

        let descriptor =
            FetchDescriptor<RoundOrchestratorSnapshotRecord>(
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
    ) throws -> RoundOrchestratorSnapshot {
        do {
            return try JSONDecoder().decode(
                RoundOrchestratorSnapshot.self,
                from: data
            )
        } catch {
            throw SwiftDataOrchestratorSnapshotStoreError
                .decodingFailed
        }
    }
}
