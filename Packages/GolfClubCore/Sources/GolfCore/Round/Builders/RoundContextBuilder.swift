//
//  RoundContextBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//
import Foundation

public struct RoundContextBuilder: Sendable {

    private let shotContextBuilder: ShotContextBuilder

    public init(
        shotContextBuilder: ShotContextBuilder =
            ShotContextBuilder()
    ) {
        self.shotContextBuilder = shotContextBuilder
    }

    public func build(
        round: Round,
        player: Player,
        course: Course,
        weather: WeatherCondition?,
        currentLocation: GeoCoordinate,
        playableLie: PlayableLie,
        courseArea: HoleAreaType,
        availableClubs: [Club],
        recentShotHistory: [RecentShotSummary] = [],
        dispersionSummaries: [ClubDispersionSummary] = [],
        strategyGeometry: HoleStrategyGeometry,
        currentShotPlan: ShotPlan? = nil,
        environment: EnvironmentalContext =
            EnvironmentalContext()
    ) throws -> RoundContext {
        
        let hole = try resolveActiveHole(
            round: round,
            course: course
        )
        
        guard let holeSession = round.currentHoleSession else {
            throw RoundContextBuilderError.noActiveHole
        }
        
        let holeContext = try buildHoleContext(
            hole: hole,
            holeSession: holeSession,
            currentLocation: currentLocation
        )
        
        let shotContext = shotContextBuilder.build(
            player: player,
            roundID: round.id,
            hole: hole,
            currentPosition: currentLocation,
            playableLie: playableLie,
            courseArea: courseArea,
            availableClubs: availableClubs,
            recentShotHistory: recentShotHistory,
            dispersionSummaries: dispersionSummaries,
            strategyGeometry: strategyGeometry,
            currentShotPlan: currentShotPlan,
            environment: environment
        )
        
        let recommendationInputs = RecommendationInputs(
            candidateLandingZones: [],
            playerPerformance: nil,
            weatherCondition: weather
        )
        
        
        
        return RoundContext(
            round: round,
            player: player,
            course: course,
            hole: holeContext,
            shot: shotContext,
            recommendationInputs: recommendationInputs
        )
    }
    private func resolveActiveHole(
        round:
        Round,
        course:
        Course
    ) throws -> Hole {
        
        guard let activeHoleID =
                round.currentHoleSession?.holeID
        else {
            throw RoundContextBuilderError.noActiveHole
        }
        
        
        guard let hole =
                course.holes.first(
                    where:
                        {
                            $0.id ==
                            activeHoleID
                        }
                )
        else {
            throw RoundContextBuilderError.holeNotFound(
                activeHoleID
            )
        }
        
        
        return hole
    }
    
    
    private func buildHoleContext(
        hole: Hole,
        holeSession: HoleSession,
        currentLocation: GeoCoordinate
    ) throws -> HoleContext {
        
        guard let greenLocation = hole.greenLocation else {
            throw RoundContextBuilderError.noGreenLocation(hole.id)
        }
        
        let shots = holeSession.shots
        
        
        let remainingDistance = DistanceCalculator.distanceMeters(
            from: currentLocation,
            to: greenLocation
        )
        
        return HoleContext(
            hole: hole,
            shots: shots,
            currentLie: .tee,
            remainingDistanceMeters: remainingDistance,
            shotsPlayed: shots.count,
            greenReached: remainingDistance <= 20
            //TODO - greenReached - Later we'll replace it with logic that uses:
            //HoleAreaType.green
            //Lie Detection
            //GPS
        )
    }
    
   
}
