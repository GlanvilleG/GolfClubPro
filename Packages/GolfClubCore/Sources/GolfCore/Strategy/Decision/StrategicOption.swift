//
//  StrategicOption.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct StrategicOption:
    Codable,
    Equatable,
    Sendable {


    public let target:
        GeoCoordinate


    public let clubID:
        ClubID


    public let landingZone:
        LandingZoneEvaluation


    public let risk:
        RiskAssessment
    
    public let metrics:
        StrategicDecisionMetrics


    public init(
        target:
            GeoCoordinate,
        clubID:
            ClubID,
        landingZone:
            LandingZoneEvaluation,
        risk:
            RiskAssessment,
        metrics:
            StrategicDecisionMetrics = .unavailable
    ) {

        self.target =
            target

        self.clubID =
            clubID

        self.landingZone =
            landingZone

        self.risk =
            risk
        
        self.metrics = metrics
        
    }
}
