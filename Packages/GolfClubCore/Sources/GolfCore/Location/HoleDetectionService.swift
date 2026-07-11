//
//  HoleDetectionService.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public struct HoleDetectionConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var maximumHorizontalAccuracyMeters: Double
    public var ambiguityDistanceMeters: Double
    public var minimumConfidence: Double
    public var previousHoleBoost: Double

    public init(
        maximumHorizontalAccuracyMeters: Double = 50,
        ambiguityDistanceMeters: Double = 15,
        minimumConfidence: Double = 0.45,
        previousHoleBoost: Double = 0.08
    ) {
        self.maximumHorizontalAccuracyMeters =
            max(0, maximumHorizontalAccuracyMeters)

        self.ambiguityDistanceMeters =
            max(0, ambiguityDistanceMeters)

        self.minimumConfidence =
            min(1, max(0, minimumConfidence))

        self.previousHoleBoost =
            min(0.25, max(0, previousHoleBoost))
    }
}

public struct HoleDetectionService:
    Sendable {

    private let configuration:
        HoleDetectionConfiguration

    public init(
        configuration:
            HoleDetectionConfiguration =
                HoleDetectionConfiguration()
    ) {
        self.configuration = configuration
    }

    public func detectHole(
        from observation: LocationObservation,
        among holes: [Hole],
        previouslyCompletedHoleNumber: Int? = nil
    ) -> HoleDetectionResult {
        if let accuracy =
            observation.horizontalAccuracyMeters,
           accuracy >
            configuration
                .maximumHorizontalAccuracyMeters {

            return HoleDetectionResult(
                status: .insufficientAccuracy
            )
        }

        let candidates = holes
            .compactMap { hole -> HoleDetectionCandidate? in
                guard let tee =
                        hole.teeLocation else {
                    return nil
                }

                let distance =
                    DistanceCalculator.distanceMeters(
                        from: observation.coordinate,
                        to: tee
                    )

                guard distance <=
                        hole
                            .teeDetectionRadiusMeters else {
                    return nil
                }

                var confidence =
                    confidence(
                        distanceMeters: distance,
                        detectionRadiusMeters:
                            hole
                                .teeDetectionRadiusMeters,
                        horizontalAccuracyMeters:
                            observation
                                .horizontalAccuracyMeters
                    )

                if let previous =
                    previouslyCompletedHoleNumber,
                   isLikelyNextHole(
                        candidateNumber: hole.number,
                        previousNumber: previous,
                        totalHoles: holes.count
                   ) {
                    confidence +=
                        configuration.previousHoleBoost
                }

                confidence =
                    min(1, max(0, confidence))

                guard confidence >=
                        configuration
                            .minimumConfidence else {
                    return nil
                }

                return HoleDetectionCandidate(
                    holeID: hole.id,
                    distanceToTeeMeters: distance,
                    confidence: confidence
                )
            }
            .sorted {
                if $0.distanceToTeeMeters ==
                    $1.distanceToTeeMeters {
                    return $0.confidence >
                        $1.confidence
                }

                return $0.distanceToTeeMeters <
                    $1.distanceToTeeMeters
            }

        guard let first = candidates.first else {
            return HoleDetectionResult(
                status: .notFound
            )
        }

        if candidates.count > 1 {
            let second = candidates[1]
            let separation =
                second.distanceToTeeMeters -
                first.distanceToTeeMeters

            if separation <=
                configuration
                    .ambiguityDistanceMeters {

                return HoleDetectionResult(
                    status: .ambiguous,
                    selectedHoleID: nil,
                    confidence: first.confidence,
                    candidates: candidates
                )
            }
        }

        return HoleDetectionResult(
            status: .detected,
            selectedHoleID: first.holeID,
            confidence: first.confidence,
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
                distanceComponent * 0.80 +
                accuracyComponent * 0.20
            )
        )
    }

    private func isLikelyNextHole(
        candidateNumber: Int,
        previousNumber: Int,
        totalHoles: Int
    ) -> Bool {
        guard totalHoles > 0 else {
            return false
        }

        let expected =
            previousNumber == totalHoles
            ? 1
            : previousNumber + 1

        return candidateNumber == expected
    }
}
