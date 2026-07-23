//
//  PlayerPerformanceEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 22/07/2026.
//
import Foundation


// MARK: - Placeholder core domain types (replace with real implementations)

public enum MissDirection: String, Sendable, Codable {
    case left
    case right
    case centred
    case insufficientData
}

public struct DistanceProfile: Sendable, Equatable, Codable {
    public let averageCarryMeters: Double?
    public let medianCarryMeters: Double?
    public let averageTotalMeters: Double?
    public let carryConsistency: Double?
    public let distanceConsistency: Double?
    public let sampleSize: Int

    public init(
        averageCarryMeters: Double?,
        medianCarryMeters: Double?,
        averageTotalMeters: Double?,
        carryConsistency: Double?,
        distanceConsistency: Double?,
        sampleSize: Int
    ) {
        self.averageCarryMeters = averageCarryMeters
        self.medianCarryMeters = medianCarryMeters
        self.averageTotalMeters = averageTotalMeters
        self.carryConsistency = carryConsistency
        self.distanceConsistency = distanceConsistency
        self.sampleSize = sampleSize
    }
}

public struct ClubPerformanceProfile: Sendable, Equatable, Codable {
    public let clubID: ClubID
    public let observationCount: Int
    public let lastAnalyzed: Date?
    public let distance: DistanceProfile
    public let typicalMissDirection: MissDirection
    public let dispersionConfidence: Double
    public let outlierCount: Int
    public let explainableEvidence: [String]

    public init(
        clubID: ClubID,
        observationCount: Int,
        lastAnalyzed: Date?,
        distance: DistanceProfile,
        typicalMissDirection: MissDirection,
        dispersionConfidence: Double,
        outlierCount: Int,
        explainableEvidence: [String]
    ) {
        self.clubID = clubID
        self.observationCount = observationCount
        self.lastAnalyzed = lastAnalyzed
        self.distance = distance
        self.typicalMissDirection = typicalMissDirection
        self.dispersionConfidence = min(1, max(0, dispersionConfidence))
        self.outlierCount = max(0, outlierCount)
        self.explainableEvidence = explainableEvidence
    }
}

public struct PlayerPerformanceProfile: Sendable, Equatable, Codable {
    public let totalRoundsAnalyzed: Int
    public let totalShotsAnalyzed: Int
    public let recentRoundsConsidered: Int
    public let overallConsistency: Double
    public let overallDistanceBiasMeters: Double

    public init(
        totalRoundsAnalyzed: Int,
        totalShotsAnalyzed: Int,
        recentRoundsConsidered: Int,
        overallConsistency: Double,
        overallDistanceBiasMeters: Double
    ) {
        self.totalRoundsAnalyzed = totalRoundsAnalyzed
        self.totalShotsAnalyzed = totalShotsAnalyzed
        self.recentRoundsConsidered = recentRoundsConsidered
        self.overallConsistency = overallConsistency
        self.overallDistanceBiasMeters = overallDistanceBiasMeters
    }
}

public struct ConfidenceProfile: Sendable, Equatable, Codable {
    public let overall: Double
    public let sampleSize: Double
    public let recency: Double
    public let consistency: Double
    public let trendConfidence: Double
    public let dataFreshness: Double

    public init(
        overall: Double,
        sampleSize: Double,
        recency: Double,
        consistency: Double,
        trendConfidence: Double,
        dataFreshness: Double
    ) {
        self.overall = overall
        self.sampleSize = sampleSize
        self.recency = recency
        self.consistency = consistency
        self.trendConfidence = trendConfidence
        self.dataFreshness = dataFreshness
    }
}

// Lightweight placeholders to compile alongside PlayerIntelligence.swift types
public struct CompletedShot: Sendable, Equatable, Codable {
    public let clubID: ClubID
    public let carryMeters: Double
    public let totalMeters: Double
    public let timestamp: Date

    public init(
        clubID: ClubID,
        carryMeters: Double,
        totalMeters: Double,
        timestamp: Date
    ) {
        self.clubID = clubID
        self.carryMeters = carryMeters
        self.totalMeters = totalMeters
        self.timestamp = timestamp
    }
}

public struct CompletedRound: Sendable, Equatable, Codable {
    public let id: UUID
    public let startedAt: Date
    public let finishedAt: Date

    public init(
        id: UUID,
        startedAt: Date,
        finishedAt: Date
    ) {
        self.id = id
        self.startedAt = startedAt
        self.finishedAt = finishedAt
    }
}

/// Provides completed shot data for a player asynchronously.
public protocol ShotHistoryProvider: Sendable {
    /// Fetches completed shots for the given player ID.
    /// - Parameter playerID: The player identifier.
    /// - Returns: An array of completed shots.
    /// - Throws: Errors encountered during fetching.
    func fetchCompletedShots(for playerID: PlayerID) async throws -> [CompletedShot]
}

/// Provides completed round data for a player asynchronously.
public protocol RoundHistoryProvider: Sendable {
    /// Fetches completed rounds for the given player ID.
    /// - Parameter playerID: The player identifier.
    /// - Returns: An array of completed rounds.
    /// - Throws: Errors encountered during fetching.
    func fetchCompletedRounds(for playerID: PlayerID) async throws -> [CompletedRound]
}



/// PlayerPerformanceEngine is responsible for analyzing player shot and round history
/// to produce PlayerIntelligence. It does not access persistence directly and is engine-agnostic.
/// Input data must be provided via ShotHistoryProvider and RoundHistoryProvider protocols.
///
/// Responsibilities:
/// - Fetching player shot and round data using provided protocols.
/// - Producing a conservative, minimal PlayerIntelligence based on available data.
///
/// Non-Responsibilities:
/// - Persistence or data storage is out of scope and must be implemented externally.
/// - Does not perform advanced or non-deterministic analysis.
///



public struct PlayerPerformanceEngine: Sendable {
    private let clock: @Sendable () -> Date

    /// Initializes the engine with a clock function.
    /// - Parameter clock: A function returning the current date/time (defaults to Date()).
    public init(clock: @escaping @Sendable () -> Date = { @Sendable in Date() }) {
        self.clock = clock
    }

    /// Analyzes a player's performance given dispersion profiles and history providers.
    /// - Parameters:
    ///   - playerID: The player identifier.
    ///   - dispersionProfiles: The shot dispersion profiles to consider.
    ///   - shotHistory: The provider for completed shots.
    ///   - roundHistory: The provider for completed rounds.
    /// - Returns: A PlayerIntelligence summarizing conservative performance results.
    /// - Throws: Errors thrown by the history providers.
    public func analyze(
          playerID: PlayerID,
          dispersionProfiles: [ShotDispersionProfile],
          shotHistory: ShotHistoryProvider,
          roundHistory: RoundHistoryProvider
      ) async throws -> PlayerIntelligence {
          
        let now = clock() // or your injected clock time
        // Flatten all shots from all rounds
        let rounds = try await roundHistory.fetchCompletedRounds(for: playerID)
        let shots  = try await shotHistory.fetchCompletedShots(for: playerID)
        let recentRoundsConsidered = min(rounds.count, 5)
        
        // Group shots by club and compute carry consistency for each club
          var clubProfiles: [ClubID: ClubPerformanceProfile] = [:]
        
        let shotsByClub = Dictionary(grouping: shots, by: { $0.clubID })
        
          for (club, clubShots) in shotsByClub {
            let carries = clubShots.map { $0.carryMeters }
            let meanCarry = carries.reduce(0, +) / Double(carries.count)
            let variance = carries.reduce(0) { $0 + pow($1 - meanCarry, 2) } / Double(carries.count)
            let stdDev = sqrt(variance)
            // carryConsistency is 1 - normalized stdDev, clamped 0-1; assuming max std dev ~30m
            let consistency = max(0, min(1, 1 - stdDev / 30))
            
            
              
            let sampleCount = Int(clubShots.count)
            
            let distance = DistanceProfile(
                averageCarryMeters: nil,
                medianCarryMeters: nil,
                averageTotalMeters: nil,
                carryConsistency: consistency,
                distanceConsistency: nil,
                sampleSize: sampleCount // provide the sample size you computed for this club
            )
            let profile = ClubPerformanceProfile(
                clubID: club, // the ClubID you’re iterating over
                observationCount: sampleCount,
                lastAnalyzed: now,
                distance: distance,
                typicalMissDirection: .centred, // or .left/.right based on your logic
                dispersionConfidence: 0.0, // or a computed value
                outlierCount: 0,
                explainableEvidence: []
            )

              clubProfiles[club] = profile
              
            //DEBUG End
          //  clubProfiles[club] = ClubPerformanceProfile(distance: .init(carryConsistency: consistency))
        }
        
        // Extract carryConsistency values for all clubs to compute overallConsistency
        let consistencies = clubProfiles.values.compactMap { $0.distance.carryConsistency }
        // overallConsistency is average of per-club consistencies, clamped 0-1
        let overallConsistency = consistencies.isEmpty ? 0 : max(0, min(1, consistencies.reduce(0, +) / Double(consistencies.count)))
          
          
          
        // Compute recent distance trend across all shots
        // Thresholds and windows used below:
        // - recentWindow: last 10 shots
        // - tolerance for trend detection: 2 meters
        let recentWindow = 10
        let recentCarries = Array(shots.suffix(recentWindow).map { $0.carryMeters })
        let lifetimeCarries = shots.map { $0.carryMeters }
        
        func mean(_ xs: [Double]) -> Double? {
            guard !xs.isEmpty else { return nil }
            return xs.reduce(0, +) / Double(xs.count)
        }
        
        let recentMean = mean(recentCarries)
        let lifetimeMean = mean(lifetimeCarries)
        
        var trends: [PerformanceTrend] = []
        if let r = recentMean, let l = lifetimeMean {
            let delta = r - l
            let tolerance = 2.0 // meters
            let direction: TrendDirection
            if delta > tolerance { direction = .improving }
            else if delta < -tolerance { direction = .declining }
            else { direction = .stable }
            
            // Confidence: scale with recent sample coverage and dispersion of recent window
            let coverage = min(1, Double(min(recentCarries.count, recentWindow)) / Double(recentWindow))
            // Use a simple inverse range as a rough consistency proxy for the window
            let windowRange = (recentCarries.max() ?? 0) - (recentCarries.min() ?? 0)
            let rangeFactor = max(0, min(1, 1 - min(1, windowRange / 30))) // 30m clamp for range effect
            let trendConfidence = max(0, min(1, 0.5 * coverage + 0.5 * rangeFactor))
            
            trends.append(
                PerformanceTrend(
                    scope: .distance,
                    direction: direction,
                    magnitude: abs(delta),
                    confidence: trendConfidence,
                    windowDescription: "last \(min(recentCarries.count, recentWindow)) shots vs lifetime"
                )
            )
        }
        
        let overallProfile = PlayerPerformanceProfile(
            totalRoundsAnalyzed: rounds.count,
            totalShotsAnalyzed: shots.count,
            recentRoundsConsidered: recentRoundsConsidered,
            overallConsistency: overallConsistency,
            overallDistanceBiasMeters: 0
        )
        
          //DEBUG init
            // Ensure a confidence profile exists for the return value
          // Build a ConfidenceProfile using available signals
          let sampleSize = Double(shots.count)
          // Coverage from the recent window calculation above (0...1). Recompute here to avoid scope issues.
          let coverage = min(1, Double(min(shots.count, recentWindow)) / Double(recentWindow))
          // Trend confidence if a trend was computed; otherwise 0. Use the max confidence found in trends.
          let trendConfidenceValue = trends.map { $0.confidence }.max() ?? 0
          // Recency heuristic: weight by how much of the recent window we have.
          let recencyValue = coverage
          // Consistency heuristic: reuse overallConsistency.
          let consistencyValue = overallConsistency
          // Data freshness heuristic: if we have any shots, treat as fresh proportional to recency; else 0.
          let dataFreshnessValue = shots.isEmpty ? 0 : recencyValue
          let confidenceProfile = ConfidenceProfile(
              overall: overallConsistency,
              sampleSize: sampleSize,
              recency: recencyValue,
              consistency: consistencyValue,
              trendConfidence: trendConfidenceValue,
              dataFreshness: dataFreshnessValue
          )
          //DEBUG end

          // Construct PlayerIntelligence with explicit initializer
            return PlayerIntelligence(
                playerID: playerID,
                generatedAt: now,
                overall: overallProfile,
                clubs: clubProfiles,
                trends: trends,
                confidence: confidenceProfile,
                notes: []
            )

    }


    private func trimmedValues(_ values: [Double], trimFraction: Double) -> [Double] {
        guard !values.isEmpty, trimFraction > 0 else { return values }
        let sorted = values.sorted()
        let k = Int(Double(sorted.count) * trimFraction)
        if k == 0 || 2*k >= sorted.count { return sorted }
        return Array(sorted[k..<(sorted.count - k)])
    }

    private func iqr(_ values: [Double]) -> Double? {
        guard values.count >= 4 else { return nil }
        let sorted = values.sorted()
        let q1Index = (Double(sorted.count - 1)) * 0.25
        let q3Index = (Double(sorted.count - 1)) * 0.75
        func interp(_ idx: Double) -> Double {
            let lo = Int(floor(idx))
            let hi = Int(ceil(idx))
            if lo == hi { return sorted[lo] }
            let t = idx - floor(idx)
            return sorted[lo] * (1 - t) + sorted[hi] * t
        }
        let q1 = interp(q1Index)
        let q3 = interp(q3Index)
        return max(0, q3 - q1)
    }

    private func normalizedConsistency(from values: [Double]) -> Double? {
        guard values.count >= 5 else { return nil }
        guard let spread = iqr(values) else { return nil }
        let range = (values.max() ?? 0) - (values.min() ?? 0)
        guard range > 0 else { return 1 }
        let ratio = 1 - min(1, spread / range)
        return max(0, min(1, ratio))
    }
}

