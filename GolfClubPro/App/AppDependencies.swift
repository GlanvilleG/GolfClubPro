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

    let platformProbe: GolfPlatformAppleProbe
    
    let modelContainer: ModelContainer
    let snapshotStore: SwiftDataActiveRoundSnapshotStore
    let roundCoordinator: PersistentOfflineRoundCoordinator
    let locationProvider: AppleLocationProvider

    init(
        modelContainer: ModelContainer
    ) {
        self.modelContainer = modelContainer

        self.platformProbe = GolfPlatformAppleProbe()
        
        let snapshotStore =
            SwiftDataActiveRoundSnapshotStore(
                modelContainer: modelContainer
            )

        self.snapshotStore = snapshotStore

        self.roundCoordinator =
            PersistentOfflineRoundCoordinator(
                store: snapshotStore
            )

        self.locationProvider =
            AppleLocationProvider()
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
