//
//  RecommendationPipeline.swift
//  GolfClubCore
//
//  Created by Dragon Development on 18/07/2026.
//


import Foundation

public struct RecommendationPipeline:
    Sendable {

    private let strategicOptionEngine:
        StrategicOptionEngine

    private let adaptiveCoachingEngine:
        AdaptiveCoachingEngine

    private let weatherAdjustmentEngine:
        WeatherAdjustmentEngine

    private let caddyRecommendationEngine:
        CaddyRecommendationEngine

    private let dispersionEngine:
        DispersionEngine
    
    private let holeAreaAssessmentEngine:
        HoleAreaAssessmentEngine
    
    private let riskRewardAnalysisEngine:
        RiskRewardAnalysisEngine
    
    private let environmentalContextEngine: EnvironmentalContextEngine

    public init(
        strategicOptionEngine:
            StrategicOptionEngine = StrategicOptionEngine(),
        adaptiveCoachingEngine:
            AdaptiveCoachingEngine = AdaptiveCoachingEngine(),
        weatherAdjustmentEngine:
            WeatherAdjustmentEngine = WeatherAdjustmentEngine(),
        caddyRecommendationEngine:
            CaddyRecommendationEngine = CaddyRecommendationEngine(),
        dispersionEngine:
            DispersionEngine = DispersionEngine(),
        holeAreaAssessmentEngine:
            HoleAreaAssessmentEngine = HoleAreaAssessmentEngine(),
        riskRewardAnalysisEngine:
            RiskRewardAnalysisEngine =
                RiskRewardAnalysisEngine(),
        environmentalContextEngine: EnvironmentalContextEngine = EnvironmentalContextEngine()
    ) {
        self.strategicOptionEngine =
            strategicOptionEngine

        self.adaptiveCoachingEngine =
            adaptiveCoachingEngine

        self.weatherAdjustmentEngine =
            weatherAdjustmentEngine

        self.caddyRecommendationEngine =
            caddyRecommendationEngine

        self.dispersionEngine =
            dispersionEngine

        self.holeAreaAssessmentEngine =
            holeAreaAssessmentEngine
        
        self.riskRewardAnalysisEngine =
            riskRewardAnalysisEngine
        
        self.environmentalContextEngine = environmentalContextEngine
    }

    public func execute(
        context:
            RoundContext
    ) throws -> RecommendationPipelineResult {

        let shotContext =
            context.shot

        let inputs =
            context.recommendationInputs

        guard !inputs.candidateLandingZones.isEmpty else {

            throw RecommendationPipelineError
                .noCandidateLandingZones
        }

        let strategicOption =
            try strategicOptionEngine
                .determineBestOption(
                    from:
                        shotContext,
                    candidateLandingZones:
                        inputs.candidateLandingZones
                )
        
        let shotDispersion =
            dispersionEngine.calculate(
                target:
                    strategicOption.target,
                clubID:
                    strategicOption.clubID,
                performance:
                    inputs.playerPerformance
            )
        
        let riskRewardAnalysis =
            riskRewardAnalysisEngine.analyse(
                option: strategicOption
            )
        // Geomtery
        let shotBearingDegrees =
            BearingCalculator
                .bearingDegrees(
                    from:
                        shotContext.currentPosition,
                    to:
                        strategicOption.target
                )
    
        
        // Environmental Intelligence
        var envInputs = EnvironmentalContextEngine.Inputs()
        // Weather (provider-agnostic)
        if let w = inputs.weatherCondition {
            envInputs.windSpeedMetersPerSecond = w.windSpeedmps
            //windSpeedMetersPerSecond
            envInputs.windDirectionDegrees = w.windDirectionDegrees
            envInputs.observationAgeSeconds = w.ageSeconds
            envInputs.providerQuality = w.providerQuality
            // Optional temperature if available on WeatherCondition
            // envInputs.temperatureCelsius = w.temperatureCelsius
        }
        envInputs.shotBearingDegrees = shotBearingDegrees
        // Terrain and lie, if available on ShotContext/environment
        envInputs.elevationDeltaMeters = context.shot.environment.elevationChangeMeters
        envInputs.localSlopeDegrees = nil
        // Map playable lie to LieAssessment category if possible
        switch context.shot.playableLie {
        case .tee, .fairway: envInputs.lieCategory = .fairway
        case .lightRough: envInputs.lieCategory = .lightRough
        case .deepRough: envInputs.lieCategory = .heavyRough
        case .fairwayBunker, .greensideBunker, .pluggedBunker: envInputs.lieCategory = .sand
        case .trees, .treeRoots, .pineStraw, .recovery: envInputs.lieCategory = .recovery
        case .fringe, .green: envInputs.lieCategory = .unknown
        case .cartPath, .water, .penaltyArea, .outOfBounds: envInputs.lieCategory = .unknown
        case .unknown: envInputs.lieCategory = .unknown
        }
        envInputs.lieDetectionConfidence = 0.8
        // Course conditions unavailable here; leave nil for now
        // Hazard summary derived from holeAssessment
        let holeAssessment =
            holeAreaAssessmentEngine.assess(
                areas:
                    inputs.holeAreas,
                shotDispersion:
                    shotDispersion,
                shotBearingDegrees:
                    shotBearingDegrees
            )
        envInputs.hazard = summarizeHazard(from: holeAssessment)
        // Confidence inputs
        envInputs.gpsAccuracyMeters = inputs.gpsAccuracyMeters
        envInputs.feedsPresentFraction = nil

        let environmentalAssessment = environmentalContextEngine.assess(from: envInputs)
        
        let decisionContext =
            RecommendationDecisionContext(
                strategicOption:
                    strategicOption,
                shotDispersion:
                    shotDispersion,
                holeAssessment:
                    holeAssessment
            )
        
      
        let clubDistanceMeters =
            try selectedClubDistance(
                clubID:
                    decisionContext.strategicOption.clubID,
                target:
                    decisionContext.strategicOption.target,
                shotContext:
                    shotContext
            )
        
        // Player Intelligence
        let adaptiveAdjustment =
            adaptiveAdjustment(
                strategicOption:
                    strategicOption,
                bearingDegrees:
                    shotBearingDegrees,
                performance:
                    inputs.playerPerformance
            )
        
        // Environment
        let weatherAdjustment =
            weatherAdjustment(
                clubDistanceMeters:
                    clubDistanceMeters,
                shotBearingDegrees:
                    shotBearingDegrees,
                weather:
                    inputs.weatherCondition
            )

        let recommendation =
            caddyRecommendationEngine
                .create(
                    option: strategicOption,
                    adaptiveAdjustment: adaptiveAdjustment,
                    weatherAdjustment: weatherAdjustment,
                    environmentalAssessment: environmentalAssessment
                )
        
        return RecommendationPipelineResult(
            strategicOption: strategicOption,
            adaptiveAdjustment: adaptiveAdjustment,
            weatherAdjustment: weatherAdjustment,
            recommendation: recommendation,
            environmentalAssessment: environmentalAssessment
        )
    }

    private func selectedClubDistance(
        clubID: ClubID,
        target: GeoCoordinate,
        shotContext: ShotContext
    ) throws -> Double {

        guard let club =
            shotContext.availableClubs.first(
                where: { $0.id == clubID }
            )
        else {
            throw RecommendationPipelineError
                .selectedClubUnavailable
        }

        if let carryDistance =
            club.averageCarryMeters {

            return carryDistance
        }

        return DistanceCalculator.distanceMeters(
            from:
                shotContext.currentPosition,
            to:
                target
        )
    }

    private func adaptiveAdjustment(
        strategicOption:
            StrategicOption,
        bearingDegrees:
            Double,
        performance:
            PlayerPerformanceModel?
    ) -> AdaptiveTargetAdjustment {

        guard let performance else {

            return AdaptiveTargetAdjustment(
                originalTarget:
                    strategicOption.target,
                adjustedTarget:
                    strategicOption.target,
                adjustmentMeters:
                    0,
                reason:
                    "No player performance adjustment available.",
                confidence:
                    0
            )
        }

        return adaptiveCoachingEngine
            .adjustTarget(
                plannedTarget:
                    strategicOption.target,
                bearingDegrees:
                    bearingDegrees,
                clubID:
                    strategicOption.clubID,
                performance:
                    performance
            )
    }

    private func weatherAdjustment(
        clubDistanceMeters:
            Double,
        shotBearingDegrees:
            Double,
        weather:
            WeatherCondition?
    ) -> WeatherAdjustment? {

        guard let weather else {

            return nil
        }

        return weatherAdjustmentEngine
            .calculate(
                clubDistanceMeters:
                    clubDistanceMeters,
                shotBearingDegrees:
                    shotBearingDegrees,
                
                weather:
                    weather
            )
    }
    
    private func summarizeHazard(from hole: HoleAssessment) -> HazardAssessment? {
        guard !hole.areaAssessments.isEmpty else { return nil }
        func level(for types: [HoleAreaType]) -> HazardAssessment.RiskLevel {
            let maxRisk = hole.areaAssessments.filter { types.contains($0.area.type) }.map(\.risk).max() ?? .negligible
            switch maxRisk {
            case .negligible: return .negligible
            case .low: return .low
            case .moderate: return .moderate
            case .high: return .high
            case .severe: return .severe
            }
        }
        let water = level(for: [.water])
        let bunkers = level(for: [.bunker])
        let trees = level(for: [.trees])
        let penalty = level(for: [.penaltyArea])
        let oob = level(for: [.outOfBounds])
        // Recovery difficulty proxy: max risk among non-playing surfaces excluding green/fairway
        let recovery = hole.areaAssessments.filter { $0.area.type.isHazard || $0.area.type == .trees }.map(\.risk).max() ?? .negligible
        let recoveryLevel: HazardAssessment.RiskLevel = {
            switch recovery {
            case .negligible: return .negligible
            case .low: return .low
            case .moderate: return .moderate
            case .high: return .high
            case .severe: return .severe
            }
        }()
        let forcedLayup = (water == .high || water == .severe) || (oob == .high || oob == .severe)
        return HazardAssessment(
            water: water,
            bunkers: bunkers,
            trees: trees,
            penaltyAreas: penalty,
            outOfBounds: oob,
            recoveryDifficulty: recoveryLevel,
            forcedLayup: forcedLayup
        )
    }
}
