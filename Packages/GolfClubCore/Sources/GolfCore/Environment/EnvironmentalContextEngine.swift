//
//  EnvironmentalContextEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//
import Foundation

/// Performs one-time interpretation of raw environmental inputs into immutable assessment objects.
public struct EnvironmentalContextEngine: Sendable {

    public struct Inputs: Sendable, Equatable, Codable {
        // Raw weather inputs (optional)
        public var windSpeedMetersPerSecond: Double?
        public var windDirectionDegrees: Double? // direction from which wind blows
        public var temperatureCelsius: Double?
        public var pressureHPa: Double?
        public var humidityPercent: Double?
        public var observationAgeSeconds: TimeInterval?
        public var providerQuality: Double?

        // Shot geometry (optional) to derive wind components
        public var shotBearingDegrees: Double?

        // Terrain
        public var elevationDeltaMeters: Double?
        public var localSlopeDegrees: Double?

        // Lie
        public var lieCategory: LieAssessment.LieCategory?
        public var lieDetectionConfidence: Double?

        // Course conditions
        public var fairwayRollFactor: Double?
        public var greenReceptivenessFactor: Double?
        public var roughSeverity: Double?
        public var preferredLies: Bool?
        public var conditionConfidence: Double?

        // Hazard summary (already computed elsewhere)
        public var hazard: HazardAssessment?

        // Confidence inputs
        public var gpsAccuracyMeters: Double?
        public var feedsPresentFraction: Double? // 0..1 how many feeds are available

        public init() { }
    }

    public init() { }

    public func assess(from inputs: Inputs) -> EnvironmentalAssessment {
        let weather = makeWeather(inputs: inputs)
        let terrain = makeTerrain(inputs: inputs)
        let lie = makeLie(inputs: inputs)
        let course = makeCourse(inputs: inputs)
        let hazard = inputs.hazard
        let confidence = makeConfidence(inputs: inputs, weather: weather)
        return EnvironmentalAssessment(
            weather: weather,
            terrain: terrain,
            lie: lie,
            course: course,
            hazard: hazard,
            confidence: confidence
        )
    }

    // MARK: - Builders

    private func makeWeather(inputs: Inputs) -> WeatherAssessment? {
        guard let speed = inputs.windSpeedMetersPerSecond,
              let direction = inputs.windDirectionDegrees else {
            return nil
        }
        let bearing = inputs.shotBearingDegrees
        let components = deriveWindComponents(windDirection: direction, windSpeed: speed, shotBearing: bearing)
        // simple temperature/pressure density proxy omitted; keep neutral factor 1.0 for now
        let age = max(0, inputs.observationAgeSeconds ?? 0)
        let quality = clamp01(inputs.providerQuality ?? 1.0)
        return WeatherAssessment(
            windSpeedMetersPerSecond: max(0, speed),
            windDirectionDegrees: direction,
            crosswindMetersPerSecond: components.cross,
            alongWindMetersPerSecond: components.along,
            carryAdjustmentFactor: 1.0,
            ageSeconds: age,
            providerQuality: quality
        )
    }

    private func makeTerrain(inputs: Inputs) -> TerrainAssessment? {
        guard let elev = inputs.elevationDeltaMeters else { return nil }
        let slope = max(0, inputs.localSlopeDegrees ?? 0)
        // Simple elevation carry proxy: +/- 0.1 per 100m as a placeholder (clamped in model)
        let factor = 1.0 // keep neutral for now; elevation delta is provided for downstream engines if needed
        return TerrainAssessment(
            elevationDeltaMeters: elev,
            localSlopeDegrees: slope,
            carryAdjustmentFactor: factor
        )
    }

    private func makeLie(inputs: Inputs) -> LieAssessment? {
        guard let category = inputs.lieCategory else { return nil }
        // Neutral defaults; downstream engines can weight distanceFactor appropriately
        let detection = clamp01(inputs.lieDetectionConfidence ?? 0.8)
        let distanceFactor: Double
        let playability: Double
        switch category {
        case .fairway: distanceFactor = 1.0; playability = 1.0
        case .firstCut: distanceFactor = 0.98; playability = 0.95
        case .lightRough: distanceFactor = 0.96; playability = 0.9
        case .rough: distanceFactor = 0.92; playability = 0.8
        case .heavyRough: distanceFactor = 0.85; playability = 0.6
        case .sand: distanceFactor = 0.88; playability = 0.7
        case .hardpan: distanceFactor = 0.97; playability = 0.85
        case .recovery: distanceFactor = 0.8; playability = 0.5
        case .unknown: distanceFactor = 0.95; playability = 0.8
        }
        return LieAssessment(
            category: category,
            distanceFactor: distanceFactor,
            playability: playability,
            detectionConfidence: detection
        )
    }

    private func makeCourse(inputs: Inputs) -> CourseConditionAssessment? {
        let anyProvided = inputs.fairwayRollFactor != nil || inputs.greenReceptivenessFactor != nil || inputs.roughSeverity != nil || inputs.preferredLies != nil || inputs.conditionConfidence != nil
        guard anyProvided else { return nil }
        return CourseConditionAssessment(
            fairwayRollFactor: inputs.fairwayRollFactor ?? 1.0,
            greenReceptivenessFactor: inputs.greenReceptivenessFactor ?? 1.0,
            roughSeverity: inputs.roughSeverity ?? 0.5,
            preferredLies: inputs.preferredLies ?? false,
            conditionConfidence: inputs.conditionConfidence ?? 0.8
        )
    }

    private func makeConfidence(inputs: Inputs, weather: WeatherAssessment?) -> EnvironmentalConfidence {
        let gpsQuality = qualityFromGPSAccuracyMeters(inputs.gpsAccuracyMeters)
        let weatherFreshness: Double = {
            guard let w = weather else { return 0.5 } // neutral when unknown
            // Freshness: 1.0 at 0s, decays to ~0.0 after 3 hours
            let halfLife: TimeInterval = 3 * 3600
            let freshness = max(0, 1.0 - (w.ageSeconds / halfLife))
            return clamp01(freshness)
        }()
        let completeness = clamp01(inputs.feedsPresentFraction ?? inferredFeedsPresent(inputs: inputs))
        // Simple weighted mean
        let overall = clamp01((gpsQuality * 0.35) + (weatherFreshness * 0.35) + (completeness * 0.30))
        return EnvironmentalConfidence(
            overall: overall,
            gpsQuality: gpsQuality,
            weatherFreshness: weatherFreshness,
            dataCompleteness: completeness
        )
    }

    // MARK: - Helpers

    private func deriveWindComponents(windDirection: Double, windSpeed: Double, shotBearing: Double?) -> (cross: Double, along: Double) {
        guard let bearing = shotBearing else { return (cross: 0, along: 0) }
        // Compute relative angle between shot bearing and wind direction
        let rel = angularDifferenceDegrees(bearing, windDirection)
        let rad = rel * .pi / 180
        let cross = sin(rad) * windSpeed
        let along = cos(rad) * windSpeed // +along = tailwind aiding carry
        return (cross, along)
    }

    private func angularDifferenceDegrees(_ first: Double, _ second: Double) -> Double {
        var difference = (second - first).truncatingRemainder(dividingBy: 360)
        if difference > 180 { difference -= 360 }
        if difference < -180 { difference += 360 }
        return difference
    }

    private func clamp01(_ x: Double) -> Double { max(0, min(1, x)) }

    private func qualityFromGPSAccuracyMeters(_ meters: Double?) -> Double {
        guard let m = meters, m > 0 else { return 0.6 }
        // 1.0 at <=3m, 0.0 at >=50m
        if m <= 3 { return 1.0 }
        if m >= 50 { return 0.0 }
        let t = (m - 3) / (50 - 3)
        return clamp01(1.0 - t)
    }

    private func inferredFeedsPresent(inputs: Inputs) -> Double {
        var total = 0
        var present = 0
        func count(_ provided: Bool) { total += 1; if provided { present += 1 } }
        count(inputs.windSpeedMetersPerSecond != nil && inputs.windDirectionDegrees != nil)
        count(inputs.elevationDeltaMeters != nil)
        count(inputs.lieCategory != nil)
        count(inputs.fairwayRollFactor != nil || inputs.greenReceptivenessFactor != nil || inputs.roughSeverity != nil)
        if total == 0 { return 0.5 }
        return Double(present) / Double(total)
    }
}

