//
//  AppDependencies.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation
import SwiftData
import GolfCore

@MainActor
final class AppDependencies {

    let modelContainer: ModelContainer

    let snapshotStore: SwiftDataActiveRoundSnapshotStore

    let roundCoordinator: PersistentOfflineRoundCoordinator

    init(
        modelContainer: ModelContainer
    ) {
        self.modelContainer = modelContainer

        let snapshotStore =
            SwiftDataActiveRoundSnapshotStore(
                modelContainer: modelContainer
            )

        self.snapshotStore = snapshotStore

        self.roundCoordinator =
            PersistentOfflineRoundCoordinator(
                store: snapshotStore
            )
    }

    static func live() throws -> AppDependencies {
        let modelContainer = try ModelContainer(
            for: ActiveRoundSnapshotRecord.self
        )

        return AppDependencies(
            modelContainer: modelContainer
        )
    }

    static func preview() throws -> AppDependencies {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let modelContainer = try ModelContainer(
            for: ActiveRoundSnapshotRecord.self,
            configurations: configuration
        )

        return AppDependencies(
            modelContainer: modelContainer
        )
    }
}
