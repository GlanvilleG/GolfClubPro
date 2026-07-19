//
//  RecommendationDecisionContext.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct RecommendationDecisionContext:
    Equatable,
    Sendable {

    public let strategicOption:
        StrategicOption

    public let shotDispersion:
        ShotDispersionModel

    public let holeAssessment:
        HoleAssessment
    
    public init(
        strategicOption: StrategicOption,
        shotDispersion: ShotDispersionModel,
        holeAssessment: HoleAssessment,
        
    ) {
        self.strategicOption =
            strategicOption

        self.shotDispersion =
            shotDispersion

        self.holeAssessment =
            holeAssessment
        
    }
    
}
