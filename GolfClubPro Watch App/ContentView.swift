//
//  ContentView.swift
//  GolfClubPro Watch App
//
//  Created by Dragon Development on 08/07/2026.
//

import SwiftUI
import GolfCore

struct ContentView: View {
    private let player = Player(
        dotGolfMemberID: DotGolfMemberID("123456"),
        name: "Gerard Glanville",
        handicapIndex: 12.0
    )

    var body: some View {
        let handicapText = String(format: "%.1f", player.handicapIndex ?? 0.0)
        return Text("Welcome \(player.name), your handicap is currently \(handicapText)")
            .padding()
    }
}

#Preview {
    ContentView()
}
