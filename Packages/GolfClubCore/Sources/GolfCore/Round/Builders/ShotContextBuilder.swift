//
//  ShotContextBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//
import Foundation

public struct ShotContextBuilder: Sendable {

    public init() {}

    public func build(
        player: Player,
        roundID: RoundID,
        hole: Hole,
        currentPosition: GeoCoordinate,
        playableLie: PlayableLie,
        courseArea: HoleAreaType,
        availableClubs: [Club],
        recentShotHistory: [RecentShotSummary] = [],
        dispersionSummaries: [ClubDispersionSummary] = [],
        strategyGeometry: HoleStrategyGeometry,
        currentShotPlan: ShotPlan? = nil,
        environment: EnvironmentalContext = EnvironmentalContext()
    ) -> ShotContext {

        ShotContext(
            player: player,
            roundID: roundID,
            hole: hole,
            currentPosition: currentPosition,
            playableLie: playableLie,
            courseArea: courseArea,
            availableClubs: availableClubs,
            recentShotHistory: recentShotHistory,
            dispersionSummaries: dispersionSummaries,
            strategyGeometry: strategyGeometry,
            currentShotPlan: currentShotPlan,
            environment: environment
        )
    }
}
