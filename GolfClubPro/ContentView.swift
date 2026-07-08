//
//  ContentView.swift
//  GolfClubPro
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
        Text("Welcome \(player.name)")
            .padding()
    }
}

#Preview {
    ContentView()
}
