import Foundation

/// Aggregated, immutable snapshot of environmental intelligence for a single recommendation evaluation.
public struct EnvironmentalAssessment: Codable, Equatable, Sendable {
    public let weather: WeatherAssessment?
    public let terrain: TerrainAssessment?
    public let lie: LieAssessment?
    public let course: CourseConditionAssessment?
    public let hazard: HazardAssessment?
    public let confidence: EnvironmentalConfidence

    public init(
        weather: WeatherAssessment?,
        terrain: TerrainAssessment?,
        lie: LieAssessment?,
        course: CourseConditionAssessment?,
        hazard: HazardAssessment?,
        confidence: EnvironmentalConfidence
    ) {
        self.weather = weather
        self.terrain = terrain
        self.lie = lie
        self.course = course
        self.hazard = hazard
        self.confidence = confidence
    }
}

/// Shot-relevant interpretation of weather inputs, including derived wind components.
public struct WeatherAssessment: Codable, Equatable, Sendable {
    /// m/s wind speed
    public let windSpeedMetersPerSecond: Double
    /// degrees [0,360) direction wind is coming from
    public let windDirectionDegrees: Double
    /// m/s crosswind component relative to intended shot bearing (positive = right-to-left pushing ball left)
    public let crosswindMetersPerSecond: Double
    /// m/s head/tail component (positive = tailwind aiding carry)
    public let alongWindMetersPerSecond: Double
    /// Optional density/carry factor (1.0 = neutral)
    public let carryAdjustmentFactor: Double
    /// Seconds since observation or forecast timestamp (lower is fresher)
    public let ageSeconds: TimeInterval
    /// Provider quality score [0,1]
    public let providerQuality: Double

    public init(
        windSpeedMetersPerSecond: Double,
        windDirectionDegrees: Double,
        crosswindMetersPerSecond: Double,
        alongWindMetersPerSecond: Double,
        carryAdjustmentFactor: Double = 1.0,
        ageSeconds: TimeInterval,
        providerQuality: Double = 1.0
    ) {
        self.windSpeedMetersPerSecond = max(0, windSpeedMetersPerSecond)
        self.windDirectionDegrees = WeatherAssessment.normalize(degrees: windDirectionDegrees)
        self.crosswindMetersPerSecond = crosswindMetersPerSecond
        self.alongWindMetersPerSecond = alongWindMetersPerSecond
        self.carryAdjustmentFactor = max(0.5, min(1.5, carryAdjustmentFactor))
        self.ageSeconds = max(0, ageSeconds)
        self.providerQuality = max(0, min(1, providerQuality))
    }

    private static func normalize(degrees: Double) -> Double {
        var d = degrees.truncatingRemainder(dividingBy: 360)
        if d < 0 { d += 360 }
        return d
    }
}

/// Terrain and elevation interpretation for the current shot.
public struct TerrainAssessment: Codable, Equatable, Sendable {
    /// Elevation difference from ball to target in meters (positive = target is higher)
    public let elevationDeltaMeters: Double
    /// Local slope magnitude in degrees (optional, 0 if unknown)
    public let localSlopeDegrees: Double
    /// Carry adjustment factor due to elevation/terrain (1.0 = neutral)
    public let carryAdjustmentFactor: Double

    public init(
        elevationDeltaMeters: Double,
        localSlopeDegrees: Double = 0,
        carryAdjustmentFactor: Double = 1.0
    ) {
        self.elevationDeltaMeters = elevationDeltaMeters
        self.localSlopeDegrees = max(0, localSlopeDegrees)
        self.carryAdjustmentFactor = max(0.7, min(1.3, carryAdjustmentFactor))
    }
}

/// Lie normalization into deterministic penalty/adjustment factors.
public struct LieAssessment: Codable, Equatable, Sendable {
    public enum LieCategory: String, Codable, Sendable {
        case fairway
        case firstCut
        case lightRough
        case rough
        case heavyRough
        case sand
        case hardpan
        case recovery
        case unknown
    }

    public let category: LieCategory
    /// Distance factor due to lie (1.0 = neutral)
    public let distanceFactor: Double
    /// Qualitative playability [0,1]
    public let playability: Double
    /// Confidence in lie detection [0,1]
    public let detectionConfidence: Double

    public init(
        category: LieCategory,
        distanceFactor: Double,
        playability: Double,
        detectionConfidence: Double
    ) {
        self.category = category
        self.distanceFactor = max(0.6, min(1.1, distanceFactor))
        self.playability = max(0, min(1, playability))
        self.detectionConfidence = max(0, min(1, detectionConfidence))
    }
}

/// Course condition interpretation: roll, receptiveness, temporary rules.
public struct CourseConditionAssessment: Codable, Equatable, Sendable {
    /// Fairway roll multiplier (1.0 = neutral)
    public let fairwayRollFactor: Double
    /// Green receptiveness/stop multiplier (1.0 = neutral; <1 stops faster, >1 rolls out more)
    public let greenReceptivenessFactor: Double
    /// Rough severity [0,1] where 1 is extremely penal
    public let roughSeverity: Double
    /// Preferred lies enabled
    public let preferredLies: Bool
    /// Confidence in course condition inputs [0,1]
    public let conditionConfidence: Double

    public init(
        fairwayRollFactor: Double = 1.0,
        greenReceptivenessFactor: Double = 1.0,
        roughSeverity: Double = 0.5,
        preferredLies: Bool = false,
        conditionConfidence: Double = 0.8
    ) {
        self.fairwayRollFactor = max(0.7, min(1.3, fairwayRollFactor))
        self.greenReceptivenessFactor = max(0.7, min(1.3, greenReceptivenessFactor))
        self.roughSeverity = max(0, min(1, roughSeverity))
        self.preferredLies = preferredLies
        self.conditionConfidence = max(0, min(1, conditionConfidence))
    }
}

/// Summary projection of spatial hazard exposure for easy downstream consumption.
public struct HazardAssessment: Codable, Equatable, Sendable {
    public enum RiskLevel: String, Codable, Sendable, Comparable {
        case negligible, low, moderate, high, severe
        public static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
            let order: [RiskLevel] = [.negligible, .low, .moderate, .high, .severe]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
    }

    public let water: RiskLevel
    public let bunkers: RiskLevel
    public let trees: RiskLevel
    public let penaltyAreas: RiskLevel
    public let outOfBounds: RiskLevel
    public let recoveryDifficulty: RiskLevel
    public let forcedLayup: Bool

    public init(
        water: RiskLevel,
        bunkers: RiskLevel,
        trees: RiskLevel,
        penaltyAreas: RiskLevel,
        outOfBounds: RiskLevel,
        recoveryDifficulty: RiskLevel,
        forcedLayup: Bool
    ) {
        self.water = water
        self.bunkers = bunkers
        self.trees = trees
        self.penaltyAreas = penaltyAreas
        self.outOfBounds = outOfBounds
        self.recoveryDifficulty = recoveryDifficulty
        self.forcedLayup = forcedLayup
    }
}

/// Deterministic roll-up of environmental data quality and certainty.
public struct EnvironmentalConfidence: Codable, Equatable, Sendable {
    /// Overall environmental confidence [0,1]
    public let overall: Double
    /// Optional sub-dimensions for explanation/audit
    public let gpsQuality: Double
    public let weatherFreshness: Double
    public let dataCompleteness: Double

    public init(
        overall: Double,
        gpsQuality: Double,
        weatherFreshness: Double,
        dataCompleteness: Double
    ) {
        self.overall = max(0, min(1, overall))
        self.gpsQuality = max(0, min(1, gpsQuality))
        self.weatherFreshness = max(0, min(1, weatherFreshness))
        self.dataCompleteness = max(0, min(1, dataCompleteness))
    }
}
