//
//  EnvironmentalAssessmentBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//
import Foundation

/// Utility to derive normalized EnvironmentalAssessment values from raw EnvironmentalContext.
public enum EnvironmentalAssessmentBuilder {

    /// Build a WeatherAssessment from EnvironmentalContext and a shot bearing.
    /// - Parameters:
    ///   - environment: The raw environmental context containing a weather snapshot.
    ///   - shotBearingDegrees: Intended shot bearing in degrees [0,360).
    ///   - now: Reference time for computing age seconds. Defaults to `Date()`.
    /// - Returns: A WeatherAssessment if wind and snapshot exist; otherwise nil.
    public static func buildWeather(
        from environment: EnvironmentalContext,
        shotBearingDegrees: Double,
        now: Date = Date()
    ) -> WeatherAssessment? {
        guard let snapshot = environment.weatherSnapshot,
              let wind = snapshot.wind else {
            return nil
        }

        // Normalize bearing to [0,360)
        let bearing = normalize(degrees: shotBearingDegrees)

        // Relative angle between shot bearing and wind origin direction (met convention: wind comes FROM direction)
        let relative = angularDifferenceDegrees(bearing, wind.directionDegrees)

        // Along-wind (tailwind positive) uses cosine of relative angle.
        let along = cos(relative * .pi / 180) * wind.speedMetersPerSecond * -1
        // Explanation: If wind comes FROM directly ahead (relative ~0), that's a headwind -> along should be negative.
        // Using -cos maps 0° to -speed (headwind), 180° to +speed (tailwind).

        // Crosswind component (positive = right-to-left pushing ball left)
        let cross = sin(relative * .pi / 180) * wind.speedMetersPerSecond

        // Age seconds (non-negative)
        let age = max(0, now.timeIntervalSince(snapshot.observedAt))

        // Provider quality heuristic based on availability
        let providerQuality: Double
        switch snapshot.availability {
        case .live: providerQuality = 1.0
        case .cached: providerQuality = 0.9
        case .stale: providerQuality = 0.7
        case .unavailable: providerQuality = 0.5
        }

        return WeatherAssessment(
            windSpeedMetersPerSecond: wind.speedMetersPerSecond,
            windDirectionDegrees: wind.directionDegrees,
            crosswindMetersPerSecond: cross,
            alongWindMetersPerSecond: along,
            carryAdjustmentFactor: 1.0,
            ageSeconds: age,
            providerQuality: providerQuality
        )
    }

    /// Build a full EnvironmentalAssessment with only weather populated for now.
    /// Additional terrain/lie/course assessments can be supplied or extended later.
    public static func buildAssessment(
        from environment: EnvironmentalContext,
        shotBearingDegrees: Double,
        now: Date = Date(),
        terrain: TerrainAssessment? = nil,
        lie: LieAssessment? = nil,
        course: CourseConditionAssessment? = nil,
        hazard: HazardAssessment? = nil
    ) -> EnvironmentalAssessment? {
        let weather = buildWeather(from: environment, shotBearingDegrees: shotBearingDegrees, now: now)
        // If we have no weather and no other components, returning nil keeps ShotContext lightweight.
        if weather == nil && terrain == nil && lie == nil && course == nil && hazard == nil {
            return nil
        }

        // Compute a simple overall confidence roll-up.
        let overall: Double = {
            var components: [Double] = []
            if let w = weather { components.append(w.providerQuality) }
            // Terrain/course/hazard confidences could be added in future.
            if components.isEmpty { return 0.6 } // default mid-low if something is present without explicit quality
            return max(0, min(1, components.reduce(0, +) / Double(components.count)))
        }()

        let envConfidence = EnvironmentalConfidence(
            overall: overall,
            gpsQuality: 0.8, // placeholder until GPS quality is modeled
            weatherFreshness: min(1, max(0, 1 - (weather?.ageSeconds ?? 0) / (60 * 60))), // 1 at 0s, ~0 at >=1h
            dataCompleteness: {
                let present = [weather != nil, terrain != nil, lie != nil, course != nil, hazard != nil].filter { $0 }.count
                return Double(present) / 5.0
            }()
        )

        return EnvironmentalAssessment(
            weather: weather,
            terrain: terrain,
            lie: lie,
            course: course,
            hazard: hazard,
            confidence: envConfidence
        )
    }

    // MARK: - Helpers

    private static func normalize(degrees: Double) -> Double {
        var d = degrees.truncatingRemainder(dividingBy: 360)
        if d < 0 { d += 360 }
        return d
    }

    /// Signed minimal angular difference second - first in degrees, range [-180, 180].
    private static func angularDifferenceDegrees(_ first: Double, _ second: Double) -> Double {
        var difference = (second - first).truncatingRemainder(dividingBy: 360)
        if difference > 180 { difference -= 360 }
        if difference < -180 { difference += 360 }
        return difference
    }
}

