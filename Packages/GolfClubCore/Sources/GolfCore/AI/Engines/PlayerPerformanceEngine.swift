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

// MARK: - Lightweight placeholders to compile alongside shared PlayerIntelligence models

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
    func fetchCompletedShots(for playerID: PlayerID) async throws -> [CompletedShot]
}

/// Provides completed round data for a player asynchronously.
public protocol RoundHistoryProvider: Sendable {
    func fetchCompletedRounds(for playerID: PlayerID) async throws -> [CompletedRound]
}

// MARK: - PlayerPerformanceEngine

/// Deterministically analyzes player shots/rounds to produce immutable PlayerIntelligence.
/// - Provider-based (no persistence here)
/// - Deterministic and explainable
/// - No ML
/// - Optional filtering of recovery/penalty/punch-out shots using ShotOutcomeClassifier
public struct PlayerPerformanceEngine: Sendable {

    private let clock: @Sendable () -> Date

    // Internal toggle: filter penalty/recovery/punch-out before analytics
    private let filterRecoveryAndPenaltyShots: Bool

    /// Initializes the engine with a clock and optional filtering toggle.
    /// - Parameters:
    ///   - clock: Deterministic time source (defaults to Date()).
    ///   - filterRecoveryAndPenaltyShots: If true, ShotOutcomeClassifier removes penalty/recovery/punch-out shots from analytics.
    public init(
        clock: @escaping @Sendable () -> Date = { @Sendable in Date() },
        filterRecoveryAndPenaltyShots: Bool = false
    ) {
        self.clock = clock
        self.filterRecoveryAndPenaltyShots = filterRecoveryAndPenaltyShots
    }

    /// Analyze player performance into immutable PlayerIntelligence.
    /// Deterministic, provider-based, and explainable.
    public func analyze(
        playerID: PlayerID,
        dispersionProfiles: [ShotDispersionProfile],
        shotHistory: ShotHistoryProvider,
        roundHistory: RoundHistoryProvider
    ) async throws -> PlayerIntelligence {

        let now = clock()

        // Fetch history
        let rounds = try await roundHistory.fetchCompletedRounds(for: playerID)
        let shots  = try await shotHistory.fetchCompletedShots(for: playerID)
        let recentRoundsConsidered = min(rounds.count, 5)

        // Optional filtering via ShotOutcomeClassifier
        let effectiveShots: [CompletedShot]
        if filterRecoveryAndPenaltyShots {
            let classifier = ShotOutcomeClassifier()
            effectiveShots = shots.filter { shot in
                let outcome = classifier.classify(
                    carryMeters: shot.carryMeters,
                    totalMeters: shot.totalMeters
                    // Hints can be supplied later when available
                )
                switch outcome {
                case .penalty, .punchOut, .recovery:
                    return false
                default:
                    return true
                }
            }
        } else {
            effectiveShots = shots
        }

        // Group by club for per-club DistanceProfile
        let shotsByClub = Dictionary(grouping: effectiveShots, by: { $0.clubID })
        var clubProfiles: [ClubID: ClubPerformanceProfile] = [:]
        clubProfiles.reserveCapacity(shotsByClub.count)

        for (club, clubShots) in shotsByClub {
            guard !clubShots.isEmpty else { continue }

            // Carry values for consistency and median
            let carries = clubShots.map { $0.carryMeters }

            // Deterministic carry-consistency proxy:
            // Normalize std dev with 30m cap and invert so higher = more consistent.
            let meanCarry = carries.reduce(0, +) / Double(carries.count)
            let variance = carries.reduce(0) { $0 + pow($1 - meanCarry, 2) } / Double(carries.count)
            let stdDev = sqrt(variance)
            let carryConsistency = max(0, min(1, 1 - stdDev / 30))

            // Median carry when sampleSize >= 5
            let medianCarry: Double? = {
                let cs = carries.sorted()
                guard cs.count >= 5 else { return nil }
                if cs.count % 2 == 1 {
                    return cs[cs.count/2]
                } else {
                    let upper = cs.count/2
                    let lower = upper - 1
                    return (cs[lower] + cs[upper]) / 2
                }
            }()

            let evidenceBuilder = PerformanceEvidenceBuilder()
            let evidence = evidenceBuilder.clubEvidence(
                clubID: club,
                medianCarryMeters: medianCarry,
                sampleSize: clubShots.count,
                carryConsistency: carryConsistency,
                missDirection: .centred // placeholder until canonical miss direction is threaded
            )
            
            let distance = DistanceProfile(
                averageCarryMeters: nil,       // Can be added when available
                medianCarryMeters: medianCarry,
                averageTotalMeters: nil,       // Can be added when available
                carryConsistency: carryConsistency,
                distanceConsistency: nil,      // Placeholder for future total-distance consistency
                sampleSize: clubShots.count
            )

            // Typical miss direction and dispersion confidence will be refined once we thread in canonical dispersion.
            let profile = ClubPerformanceProfile(
                clubID: club,
                observationCount: clubShots.count,
                lastAnalyzed: now,
                distance: distance,
                typicalMissDirection: .centred,
                dispersionConfidence: 0.0,
                outlierCount: 0,
                explainableEvidence: evidence
            )

            clubProfiles[club] = profile
        }

        // Overall consistency = average of per-club carryConsistency (0...1)
        let consistencies = clubProfiles.values.compactMap { $0.distance.carryConsistency }
        let overallConsistency = consistencies.isEmpty
            ? 0
            : max(0, min(1, consistencies.reduce(0, +) / Double(consistencies.count)))

        // Distance trend (recent vs lifetime) — last 10 shots, tolerance = 2m
        let recentWindow = 10
        let recentCarries = Array(effectiveShots.suffix(recentWindow).map { $0.carryMeters })
        let lifetimeCarries = effectiveShots.map { $0.carryMeters }

        func mean(_ xs: [Double]) -> Double? {
            guard !xs.isEmpty else { return nil }
            return xs.reduce(0, +) / Double(xs.count)
        }

        var trends: [PerformanceTrend] = []
        if let r = mean(recentCarries), let l = mean(lifetimeCarries) {
            let delta = r - l
            let tolerance = 2.0 // meters
            let direction: TrendDirection =
                delta > tolerance ? .improving :
                (delta < -tolerance ? .declining : .stable)

            // Confidence: coverage of recent window + inverse window range (30m clamp)
            let coverage = min(1, Double(min(recentCarries.count, recentWindow)) / Double(recentWindow))
            let windowRange = (recentCarries.max() ?? 0) - (recentCarries.min() ?? 0)
            let rangeFactor = max(0, min(1, 1 - min(1, windowRange / 30)))
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

        // Overall consistency trend (recent vs lifetime) — last 10 shots, tol = 0.05
        func consistency(from values: [Double]) -> Double? {
            guard values.count >= 5 else { return nil }
            let m = values.reduce(0, +) / Double(values.count)
            let v = values.reduce(0) { $0 + pow($1 - m, 2) } / Double(values.count)
            let s = sqrt(v)
            return max(0, min(1, 1 - s / 30))
        }

        let recentN = 10
        let recentShots = Array(effectiveShots.suffix(recentN))
        let recentCarriesAll = recentShots.map { $0.carryMeters }
        let lifetimeCarriesAll = effectiveShots.map { $0.carryMeters }
        if let recentC = consistency(from: recentCarriesAll),
           let lifeC = consistency(from: lifetimeCarriesAll) {

            let delta = recentC - lifeC
            let tol = 0.05
            let direction: TrendDirection =
                delta > tol ? .improving :
                (delta < -tol ? .declining : .stable)

            let coverage = min(1, Double(min(recentCarriesAll.count, recentN)) / Double(recentN))
            let windowRange = (recentCarriesAll.max() ?? 0) - (recentCarriesAll.min() ?? 0)
            let rangeFactor = max(0, min(1, 1 - min(1, windowRange / 30)))
            let trendConfidence = max(0, min(1, 0.5 * coverage + 0.5 * rangeFactor))

            trends.append(
                PerformanceTrend(
                    scope: .overallConsistency,
                    direction: direction,
                    magnitude: abs(delta),
                    confidence: trendConfidence,
                    windowDescription: "last \(min(recentCarriesAll.count, recentN)) shots vs lifetime"
                )
            )
        }

        // Overall player profile
        let overallProfile = PlayerPerformanceProfile(
            totalRoundsAnalyzed: rounds.count,
            totalShotsAnalyzed: effectiveShots.count,
            recentRoundsConsidered: recentRoundsConsidered,
            overallConsistency: overallConsistency,
            overallDistanceBiasMeters: 0
        )

        // ConfidenceProfile with recency and sample-size blend
        let mostRecentDate = rounds.map { $0.finishedAt }.max()
        let recencyScore: Double = {
            guard let recent = mostRecentDate else { return 0.25 }
            let days = max(0, now.timeIntervalSince(recent) / 86400)
            switch days {
            case ..<7: return 1.0
            case ..<30: return 0.75
            case ..<90: return 0.5
            default: return 0.25
            }
        }()
        // Sample-size scale capped at 20 for stable early confidence
        let sampleScale = min(1, max(0, Double(min(effectiveShots.count, 20)) / 20.0))
        let overallConfidence = max(0, min(1, 0.6 * sampleScale + 0.4 * recencyScore))
        let trendConfidenceValue = trends.map { $0.confidence }.max() ?? 0

        let updatedConfidence = ConfidenceProfile(
            overall: overallConfidence,
            sampleSize: sampleScale,
            recency: recencyScore,
            consistency: overallConsistency,
            trendConfidence: trendConfidenceValue,
            dataFreshness: effectiveShots.isEmpty ? 0 : recencyScore
        )

        // Final immutable PlayerIntelligence
        return PlayerIntelligence(
            playerID: playerID,
            generatedAt: now,
            overall: overallProfile,
            clubs: clubProfiles,
            trends: trends,
            confidence: updatedConfidence,
            notes: []
        )
    }
    
    // MARK: - Deterministic helpers (unused in final stats, kept for future refinement)

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
