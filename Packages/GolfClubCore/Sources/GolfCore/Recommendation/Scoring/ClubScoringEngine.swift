//
//  ClubScoringEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct ClubScoringEngine:
    Sendable {

    public init() {}

    public func score(
        club: Club,
        targetDistanceMeters: Double,
        context: ShotContext,
        shotPlan: ShotPlan,
        spatialRisk:
            SpatialRiskAssessment
    ) -> ClubRecommendation? {

        let baseCarry =
            historicalCarry(
                for: club,
                history:
                    context.recentShotHistory
            ) ??
            club.averageCarryMeters ??
            0

        let windAdjustedCarry =
            adjustCarryForWind(
                baseCarry,
                shotBearingDegrees:
                    shotPlan.targetBearingDegrees,
                wind:
                    context.environment.wind
            )

        let lieAdjustedCarry =
            adjustCarryForLie(
                windAdjustedCarry,
                lie:
                    context.playableLie,
                clubType:
                    club.type
            )

        let elevationAdjustedCarry =
            adjustCarryForElevation(
                lieAdjustedCarry,
                elevationChangeMeters:
                    context.environment
                        .elevationChangeMeters
            )

        let difference =
            abs(
                targetDistanceMeters -
                elevationAdjustedCarry
            )

        let distanceScore =
            distanceSuitabilityScore(
                differenceMeters:
                    difference
            )

        let lieScore =
            lieSuitabilityScore(
                clubType:
                    club.type,
                lie:
                    context.playableLie
            )

        guard lieScore >= 0.40 else {
            return nil
        }

        let historyPenalty =
            historicalErrorPenalty(
                for:
                    club.id,
                history:
                    context.recentShotHistory
            )

        let dispersionPenalty =
            dispersionPenalty(
                for:
                    club.id,
                summaries:
                    context.dispersionSummaries
            )

        let routeRiskPenalty =
            routeRiskPenalty(
                for:
                    shotPlan.riskLevel
            )

        let missingWeatherPenalty =
            context.environment.wind == nil
            ? 0.03
            : 0

        let finalScore =
            min(
                1,
                max(
                    0,
                    distanceScore * 0.60 +
                    lieScore * 0.25 +
                    shotPlan.confidence * 0.15 -
                    historyPenalty -
                    dispersionPenalty -
                    routeRiskPenalty -
                    missingWeatherPenalty -
                    spatialRisk.penalty
                )
            )

        let confidence =
            confidenceForClub(
                club: club,
                context: context,
                distanceDifferenceMeters:
                    difference
            )

        let recommendationReasons =
            uniqueReasons(
                reasons(
                    for: club,
                    adjustedCarryMeters:
                        elevationAdjustedCarry,
                    targetDistanceMeters:
                        targetDistanceMeters,
                    context:
                        context
                ) + spatialRisk.reasons.map(\.rawValue)
            )

        return ClubRecommendation(
            clubID:
                club.id,
            score:
                finalScore,
            adjustedCarryMeters:
                elevationAdjustedCarry,
            distanceDifferenceMeters:
                difference,
            confidence:
                confidence,
            reasons:
                recommendationReasons
        )
    }
   
    private func historicalCarry(
        for club: Club,
        history: [RecentShotSummary]
    ) -> Double? {
        history.first {
            $0.clubID == club.id &&
            $0.sampleSize > 0
        }?.averageDistanceMeters
    }

    private func adjustCarryForWind(
        _ carry: Double,
        shotBearingDegrees: Double,
        wind: WindContext?
    ) -> Double {
        guard let wind else {
            return carry
        }

        let relativeAngle =
            angularDifferenceDegrees(
                shotBearingDegrees,
                wind.directionDegrees
            )

        let headwindComponent =
            cos(relativeAngle * .pi / 180) *
            wind.speedMetersPerSecond

        let adjustmentFactor =
            1 - headwindComponent * 0.015

        return max(0, carry * adjustmentFactor)
    }

    private func adjustCarryForLie(
        _ carry: Double,
        lie: PlayableLie,
        clubType: ClubType
    ) -> Double {
        let factor: Double

        switch lie {
        case .tee, .fairway:
            factor = 1

        case .lightRough:
            factor = 0.95

        case .deepRough:
            factor =
                clubType == .wedge ||
                clubType == .iron
                ? 0.85
                : 0.72

        case .fairwayBunker:
            factor =
                clubType == .wedge ||
                clubType == .iron
                ? 0.82
                : 0.65

        case .greensideBunker,
             .pluggedBunker:
            factor =
                clubType == .wedge
                ? 0.45
                : 0.20

        case .trees,
             .treeRoots,
             .pineStraw,
             .recovery:
            factor = 0.70

        case .fringe, .green:
            factor =
                clubType == .putter
                ? 1
                : 0.60

        case .cartPath,
             .water,
             .penaltyArea,
             .outOfBounds:
            factor = 0

        case .unknown:
            factor = 0.90
        }

        return carry * factor
    }

    private func adjustCarryForElevation(
        _ carry: Double,
        elevationChangeMeters: Double?
    ) -> Double {
        guard let elevationChangeMeters else {
            return carry
        }

        let adjustment =
            elevationChangeMeters * 0.8

        return max(0, carry - adjustment)
    }

    private func distanceSuitabilityScore(
        differenceMeters: Double
    ) -> Double {
        switch differenceMeters {
        case ..<5:
            return 1
        case 5..<10:
            return 0.90
        case 10..<20:
            return 0.70
        case 20..<30:
            return 0.45
        default:
            return 0.15
        }
    }

    private func lieSuitabilityScore(
        clubType: ClubType,
        lie: PlayableLie
    ) -> Double {
        switch lie {
        case .tee:
            return clubType == .driver ||
                clubType == .fairwayWood
                ? 1
                : 0.75

        case .fairway:
            return clubType == .putter
                ? 0.10
                : 0.90

        case .lightRough:
            return clubType == .hybrid ||
                clubType == .iron ||
                clubType == .wedge
                ? 0.90
                : 0.55

        case .deepRough:
            return clubType == .wedge ||
                clubType == .iron
                ? 0.90
                : 0.30

        case .fairwayBunker:
            return clubType == .iron ||
                clubType == .wedge
                ? 0.85
                : 0.20

        case .greensideBunker,
             .pluggedBunker:
            return clubType == .wedge
                ? 1
                : 0.10

        case .green:
            return clubType == .putter
                ? 1
                : 0.05

        case .fringe:
            return clubType == .putter ||
                clubType == .wedge
                ? 0.90
                : 0.30

        case .trees,
             .treeRoots,
             .pineStraw,
             .recovery:
            return clubType == .iron ||
                clubType == .wedge
                ? 0.80
                : 0.25

        case .cartPath,
             .water,
             .penaltyArea,
             .outOfBounds:
            return 0

        case .unknown:
            return 0.60
        }
    }

    private func historicalErrorPenalty(
        for clubID: ClubID,
        history: [RecentShotSummary]
    ) -> Double {
        guard let summary = history.first(
            where: { $0.clubID == clubID }
        ) else {
            return 0
        }

        var penalty = 0.0

        for error in summary.commonErrors {
            switch error {
            case .short, .long, .overHit:
                penalty += 0.05

            case .push, .pull, .fade, .draw:
                penalty += 0.03

            case .slice, .hook,
                 .chunk, .thin,
                 .shank, .top:
                penalty += 0.08

            default:
                penalty += 0.02
            }
        }

        return min(0.30, penalty)
    }

    private func dispersionPenalty(
        for clubID: ClubID,
        summaries: [ClubDispersionSummary]
    ) -> Double {
        guard let summary = summaries.first(
            where: { $0.clubID == clubID }
        ) else {
            return 0
        }

        guard summary.sampleSize >= 3 else {
            return 0
        }

        var penalty = 0.0

        if let deviation =
            summary.distanceStandardDeviationMeters {
            switch deviation {
            case ..<5:
                break
            case 5..<10:
                penalty += 0.03
            case 10..<20:
                penalty += 0.08
            default:
                penalty += 0.15
            }
        }

        if let directionalError =
            summary.meanAbsoluteDirectionalErrorDegrees {
            switch directionalError {
            case ..<3:
                break
            case 3..<7:
                penalty += 0.03
            case 7..<12:
                penalty += 0.08
            default:
                penalty += 0.15
            }
        }

        return min(0.30, penalty)
    }
    private func dispersionConsistencyConfidence(
        _ summary: ClubDispersionSummary?
    ) -> Double {
        guard let summary,
              summary.sampleSize >= 3 else {
            return 0.40
        }

        let distanceComponent: Double

        switch summary.distanceStandardDeviationMeters {
        case nil:
            distanceComponent = 0.50
        case .some(..<5):
            distanceComponent = 1
        case .some(5..<10):
            distanceComponent = 0.80
        case .some(10..<20):
            distanceComponent = 0.55
        default:
            distanceComponent = 0.25
        }

        let directionComponent: Double

        switch summary.meanAbsoluteDirectionalErrorDegrees {
        case nil:
            directionComponent = 0.50
        case .some(..<3):
            directionComponent = 1
        case .some(3..<7):
            directionComponent = 0.80
        case .some(7..<12):
            directionComponent = 0.55
        default:
            directionComponent = 0.25
        }

        return (
            distanceComponent +
            directionComponent
        ) / 2
    }
    private func confidenceForClub(
        club: Club,
        context: ShotContext,
        distanceDifferenceMeters: Double
    ) -> Double {
        let history = context.recentShotHistory.first {
            $0.clubID == club.id
        }

        let dispersion = context.dispersionSummaries.first {
            $0.clubID == club.id
        }

        let sampleConfidence: Double

        switch history?.sampleSize ?? 0 {
        case 20...:
            sampleConfidence = 1
        case 10..<20:
            sampleConfidence = 0.85
        case 5..<10:
            sampleConfidence = 0.65
        case 1..<5:
            sampleConfidence = 0.45
        default:
            sampleConfidence = 0.25
        }

        let distanceConfidence =
            max(0, 1 - distanceDifferenceMeters / 50)

        let consistencyConfidence =
            dispersionConsistencyConfidence(
                dispersion
            )
        let weatherConfidence =
            weatherConfidenceAdjustment(
                for: context.environment.weatherAvailability
            )
        return min(
            1,
            max(
                0,
                sampleConfidence * 0.35 +
                distanceConfidence * 0.30 +
                consistencyConfidence * 0.20 +
                weatherConfidence * 0.15
            )
        )
    }
    private func reasons(
        for club: Club,
        adjustedCarryMeters: Double,
        targetDistanceMeters: Double,
        context: ShotContext
    ) -> [String] {
        var reasons: [String] = []

        reasons.append(
            "Adjusted carry is \(Int(adjustedCarryMeters.rounded())) metres for a target of \(Int(targetDistanceMeters.rounded())) metres."
        )

        if context.environment.wind != nil {
            reasons.append(
                "Carry has been adjusted for wind."
            )
        }

        if context.playableLie != .fairway &&
            context.playableLie != .tee {
            reasons.append(
                "Club suitability has been adjusted for the \(context.playableLie.rawValue) lie."
            )
        }

        if context.recentShotHistory.contains(
            where: { $0.clubID == club.id }
        ) {
            reasons.append(
                "The recommendation includes your recent performance with this club."
            )
        }
        if let dispersion =
            context.dispersionSummaries.first(
                where: { $0.clubID == club.id }
            ) {

            if let deviation =
                dispersion.distanceStandardDeviationMeters {
                reasons.append(
                    "Recent distance variation with this club is approximately \(Int(deviation.rounded())) metres."
                )
            }

            switch dispersion.directionalTendency {
            case .left:
                reasons.append(
                    "Recent shots with this club show a left-miss tendency."
                )

            case .right:
                reasons.append(
                    "Recent shots with this club show a right-miss tendency."
                )

            case .centred:
                reasons.append(
                    "Recent shots with this club are generally centred."
                )

            case .insufficientData:
                break
            }
        }
        switch context.environment.weatherAvailability {
        case .live:
            if context.environment.wind != nil {
                reasons.append(
                    "Live weather data was used."
                )
            }

        case .cached:
            reasons.append(
                "Recent cached weather data was used."
            )

        case .stale:
            reasons.append(
                "Weather data is stale, so confidence has been reduced."
            )

        case .unavailable:
            reasons.append(
                "Live weather was unavailable, so no wind adjustment was applied."
            )
        }
        return reasons
    }
    private func angularDifferenceDegrees(
        _ first: Double,
        _ second: Double
    ) -> Double {
        var difference =
            (second - first)
                .truncatingRemainder(dividingBy: 360)

        if difference > 180 {
            difference -= 360
        }

        if difference < -180 {
            difference += 360
        }

        return difference
    }
    private func weatherConfidenceAdjustment(
        for availability: WeatherAvailability
    ) -> Double {
        switch availability {
        case .live:
            return 1.0
        case .cached:
            return 0.90
        case .stale:
            return 0.70
        case .unavailable:
            return 0.55
        }
    }
    private func routeRiskPenalty(
        for riskLevel: ShotRiskLevel
    ) -> Double {
        switch riskLevel {
        case .extreme:
            return 0.25
        case .high:
            return 0.15
        case .moderate:
            return 0.05
        default:
            return 0
        }

    }
    private func uniqueReasons(
        _ reasons: [String]
    ) -> [String] {
        reasons.reduce(into: []) { result, reason in
            if !result.contains(reason) {
                result.append(reason)
            }
        }
    }
    
}
