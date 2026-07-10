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

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: ActiveRoundSnapshotRecord.self
            )
        } catch {
            fatalError(
                "Unable to create SwiftData container: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
