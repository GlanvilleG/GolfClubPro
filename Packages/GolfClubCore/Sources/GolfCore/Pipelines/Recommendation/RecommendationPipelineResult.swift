//
//  RecommendationPipelineResult.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
//
//  RecommendationPipelineResult.swift
//  GolfCore
//

import Foundation

public struct RecommendationPipelineResult:
    Codable,
    Equatable,
    Sendable {

    public let strategicOption:
        StrategicOption

    public let adaptiveAdjustment:
        AdaptiveTargetAdjustment

    public let weatherAdjustment:
        WeatherAdjustment?

    public let recommendation:
        CaddyRecommendation
    
    public let environmentalAssessment: EnvironmentalAssessment?

    public init(
        strategicOption:
            StrategicOption,
        adaptiveAdjustment:
            AdaptiveTargetAdjustment,
        weatherAdjustment:
            WeatherAdjustment?,
        recommendation:
            CaddyRecommendation,
        environmentalAssessment: EnvironmentalAssessment? = nil
    ) {

        self.strategicOption =
            strategicOption

        self.adaptiveAdjustment =
            adaptiveAdjustment

        self.weatherAdjustment =
            weatherAdjustment

        self.recommendation =
            recommendation
        
        self.environmentalAssessment =
            environmentalAssessment
    }
}
