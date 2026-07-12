//
//  GolfCoreTestFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation
@testable import GolfCore

enum GolfCoreTestFactory {

    static func makeActiveRound(
        playerID: PlayerID = PlayerID(),
        golfClubID: GolfClubID = GolfClubID(),
        courseID: CourseID = CourseID()
    ) -> Round {
        RoundEngine().startRound(
            playerID: playerID,
            golfClubID: golfClubID,
            courseID: courseID
        )
    }

    static func makeActiveHoleSnapshot(
        deviceID: DeviceID = DeviceID()
    ) async throws -> ActiveRoundSnapshot {
        let store =
            InMemoryActiveRoundSnapshotStore()

        let coordinator =
            PersistentOfflineRoundCoordinator(
                store: store
            )

        var snapshot =
            try await coordinator.startRound(
                playerID: PlayerID(),
                golfClubID: GolfClubID(),
                courseID: CourseID(),
                deviceID: deviceID
            )

        snapshot =
            try await coordinator.confirmTeeSet(
                TeeSetID(),
                in: snapshot
            )

        snapshot =
            try await coordinator.confirmHole(
                HoleID(),
                in: snapshot
            )

        return snapshot
    }

    static func makeWeatherSnapshot(
        observedAt: Date,
        availability:
            WeatherAvailability = .live
    ) -> WeatherSnapshot {
        WeatherSnapshot(
            observedAt: observedAt,
            location: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            availability: availability,
            source: .weatherKit
        )
    }
}
