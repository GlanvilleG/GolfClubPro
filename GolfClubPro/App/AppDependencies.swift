//
//  AppDependencies.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//
//
//  AppDependencies.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation
import GolfCore
import GolfPlatformApple
import SwiftData

@MainActor
final class AppDependencies {

    let modelContainer: ModelContainer
    let snapshotStore: SwiftDataActiveRoundSnapshotStore
    let roundCoordinator: PersistentOfflineRoundCoordinator
    let orchestratorSnapshotStore:
        SwiftDataRoundOrchestratorSnapshotStore
    let locationProvider: AppleLocationProvider
    let golfClubCatalogue: any GolfClubCatalogue

    init(
        modelContainer: ModelContainer,
        golfClubCatalogue:
            (any GolfClubCatalogue)? = nil
    ) throws {
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

        self.orchestratorSnapshotStore =
            SwiftDataRoundOrchestratorSnapshotStore(
                modelContainer: modelContainer
            )

        self.locationProvider =
            AppleLocationProvider()

        if let golfClubCatalogue {
            self.golfClubCatalogue =
                golfClubCatalogue
        } else {
            self.golfClubCatalogue =
                try BundledGolfClubCatalogueLoader()
                    .makeCatalogue()
        }
    }

    static func live() throws -> AppDependencies {
        let modelContainer = try ModelContainer(
            for:
                ActiveRoundSnapshotRecord.self,
                RoundOrchestratorSnapshotRecord.self
        )

        return try AppDependencies(
            modelContainer: modelContainer
        )
    }

    static func preview() throws -> AppDependencies {
        let configuration =
            ModelConfiguration(
                isStoredInMemoryOnly: true
            )

        let modelContainer = try ModelContainer(
            for:
                ActiveRoundSnapshotRecord.self,
                RoundOrchestratorSnapshotRecord.self,
            configurations: configuration
        )

        return try AppDependencies(
            modelContainer: modelContainer,
            golfClubCatalogue:
                DevelopmentGolfClubCatalogue
                    .makeCatalogue()
        )
    }
}
