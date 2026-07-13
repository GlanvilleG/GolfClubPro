//
//  ContentView.swift
//  GolfClubPro
//
//  Created by Dragon Development on 08/07/2026.
//

import SwiftUI
import GolfCore
import SwiftData

struct ContentView: View {

    @Environment(RoundSession.self)
    private var roundSession

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if roundSession.isLoading {
                    ProgressView(
                        "Restoring round…"
                    )
                } else if let round =
                    roundSession.activeRound {

                    Text("Active Round")
                        .font(.title2)
                        .bold()

                    Text(
                        "State: \(round.state.rawValue)"
                    )

                    Text(
                        "Pending sync events: \(roundSession.activeSnapshot?.pendingEvents.count ?? 0)"
                    )

                    Button("Finish Round") {
                        Task {
                            await roundSession
                                .finishRound()
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Active Round",
                        systemImage: "figure.golf",
                        description: Text(
                            "A new round can be started after golf-club detection."
                        )
                    )
                }

                if let error =
                    roundSession.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)

                    Button("Dismiss Error") {
                        roundSession.clearError()
                    }
                }
            }
            .padding()
            .navigationTitle("GolfClubPro")
        }
    }
}

#Preview {
    let dependencies =
        try! AppDependencies.preview()

    
    let session = RoundSession(
        roundCoordinator:
            dependencies.roundCoordinator,
        orchestratorSnapshotStore:
            dependencies.orchestratorSnapshotStore,
        locationProvider:
            dependencies.locationProvider,
        golfClubCatalogue:
            dependencies.golfClubCatalogue
    )

    ContentView()
        .environment(session)
        .modelContainer(
            dependencies.modelContainer
        )
}
