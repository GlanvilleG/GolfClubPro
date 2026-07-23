//
//  RecommendationContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct RecommendationContext:
    Sendable {

    public let shotContext:
        ShotContext

    public let spatialContext:
        RoundSpatialContext

    public let spatialAnalysis:
        SpatialAnalysis
    
     public init(
        shotContext: ShotContext,
        spatialContext: RoundSpatialContext,
        spatialAnalysis: SpatialAnalysis
    ) {
        self.shotContext =
            shotContext

        self.spatialContext =
            spatialContext

        self.spatialAnalysis =
            spatialAnalysis
        
    }
    internal init(
        shotContext: ShotContext,
        spatialContext: RoundSpatialContext,
        spatialAnalysis: SpatialAnalysis,
        playerIntelligence: PlayerIntelligence?
    ) {
        self.shotContext = shotContext
        self.spatialContext = spatialContext
        self.spatialAnalysis = spatialAnalysis
       
    }
}
