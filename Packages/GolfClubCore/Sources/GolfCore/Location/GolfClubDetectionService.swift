//
//  GolfClubDetectionService.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public struct GolfClubDetectionConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var maximumHorizontalAccuracyMeters: Double
    public var ambiguityDistanceMeters: Double
    public var minimumConfidence: Double

    public init(
        maximumHorizontalAccuracyMeters: Double = 100,
        ambiguityDistanceMeters: Double = 250,
        minimumConfidence: Double = 0.50
    ) {
        self.maximumHorizontalAccuracyMeters =
            max(0, maximumHorizontalAccuracyMeters)

        self.ambiguityDistanceMeters =
            max(0, ambiguityDistanceMeters)

        self.minimumConfidence =
            min(1, max(0, minimumConfidence))
    }
}

public struct GolfClubDetectionService:
    Sendable {

    private let configuration:
        GolfClubDetectionConfiguration

    public init(
        configuration:
            GolfClubDetectionConfiguration =
                GolfClubDetectionConfiguration()
    ) {
        self.configuration = configuration
    }

    public func detectGolfClub(
        from observation: LocationObservation,
        among golfClubs: [GolfClub]
    ) -> GolfClubDetectionResult {
        if let accuracy =
            observation.horizontalAccuracyMeters,
           accuracy >
            configuration
                .maximumHorizontalAccuracyMeters {

            return GolfClubDetectionResult(
                status: .insufficientAccuracy
            )
        }

        let candidates = golfClubs
            .compactMap { club -> GolfClubDetectionCandidate? in
                let distance =
                    DistanceCalculator.distanceMeters(
                        from: observation.coordinate,
                        to: club.location
                    )

                guard distance <=
                        club.detectionRadiusMeters else {
                    return nil
                }

                let confidence =
                    confidence(
                        distanceMeters: distance,
                        detectionRadiusMeters:
                            club.detectionRadiusMeters,
                        horizontalAccuracyMeters:
                            observation
                                .horizontalAccuracyMeters
                    )

                guard confidence >=
                        configuration
                            .minimumConfidence else {
                    return nil
                }

                return GolfClubDetectionCandidate(
                    golfClubID: club.id,
                    distanceMeters: distance,
                    confidence: confidence
                )
            }
            .sorted {
                if $0.distanceMeters ==
                    $1.distanceMeters {
                    return $0.confidence >
                        $1.confidence
                }

                return $0.distanceMeters <
                    $1.distanceMeters
            }

        guard let first = candidates.first else {
            return GolfClubDetectionResult(
                status: .notFound
            )
        }

        if candidates.count > 1 {
            let second = candidates[1]
            let separation =
                second.distanceMeters -
                first.distanceMeters

            if separation <=
                configuration
                    .ambiguityDistanceMeters {

                return GolfClubDetectionResult(
                    status: .ambiguous,
                    selectedGolfClubID: nil,
                    confidence: first.confidence,
                    candidates: candidates
                )
            }
        }

        return GolfClubDetectionResult(
            status: .detected,
            selectedGolfClubID:
                first.golfClubID,
            confidence:
                first.confidence,
            candidates: candidates
        )
    }

    private func confidence(
        distanceMeters: Double,
        detectionRadiusMeters: Double,
        horizontalAccuracyMeters: Double?
    ) -> Double {
        guard detectionRadiusMeters > 0 else {
            return 0
        }

        let distanceComponent =
            max(
                0,
                1 -
                distanceMeters /
                detectionRadiusMeters
            )

        let accuracyComponent: Double

        if let accuracy =
            horizontalAccuracyMeters {
            accuracyComponent =
                max(
                    0,
                    1 -
                    accuracy /
                    configuration
                        .maximumHorizontalAccuracyMeters
                )
        } else {
            accuracyComponent = 0.70
        }

        return min(
            1,
            max(
                0,
                distanceComponent * 0.75 +
                accuracyComponent * 0.25
            )
        )
    }
}
