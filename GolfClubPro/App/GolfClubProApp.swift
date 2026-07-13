//
//  GolfClubProApp.swift
//  GolfClubPro
//
//  Created by Dragon Development on 08/07/2026.
//

import SwiftUI
import SwiftData
import GolfCore

@main
struct GolfClubProApp: App {

    private let dependencies:
        AppDependencies

    @State private var roundSession:
        RoundSession

    init() {
        do {
            let dependencies =
                try AppDependencies.live()

            self.dependencies =
                dependencies

            _roundSession = State(
                initialValue: RoundSession(
                    roundCoordinator:
                        dependencies
                            .roundCoordinator,
                    orchestratorSnapshotStore:
                        dependencies
                            .orchestratorSnapshotStore,
                    locationProvider:
                        dependencies
                            .locationProvider,
                    golfClubCatalogue:
                        dependencies.golfClubCatalogue
                )
            )
        } catch {
            fatalError(
                "Unable to initialise GolfClubPro: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(roundSession)
                .task {
                    await roundSession
                        .restoreActiveRound()
                }
        }
        .modelContainer(
            dependencies.modelContainer
        )
    }
}
