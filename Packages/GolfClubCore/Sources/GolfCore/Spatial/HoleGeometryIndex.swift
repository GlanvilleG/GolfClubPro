//
//  HoleGeometryIndex.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct HoleGeometryIndex:
    Sendable {

    private let holes: [Hole]

    private let configuration:
        HoleGeometryIndexConfiguration

       public init(
        holes: [Hole],
        configuration:
            HoleGeometryIndexConfiguration =
                HoleGeometryIndexConfiguration(),
      
    ) {
        self.holes = holes
        self.configuration = configuration
        
    }

    public func locate(
        golfer: GeoCoordinate
    ) -> HoleLocationResult {

        guard !holes.isEmpty else {
            return noMatchResult()
        }

        let candidates =
            holes.map {
                makeCandidate(
                    hole: $0,
                    golfer: golfer
                )
            }

        guard let nearest =
                candidates.min(
                    by: {
                        $0.proximityDistance <
                            $1.proximityDistance
                    }
                ),
              nearest.proximityDistance <=
                configuration
                    .maximumHoleDistanceMeters
        else {
            return noMatchResult()
        }

        let locationConfidence =
            confidence(
                candidate: nearest
            )

        return HoleLocationResult(
            hole: nearest.hole,
            confidence: locationConfidence,
            distanceToTeeMeters:
                nearest.distanceToTeeMeters,
            distanceToGreenMeters:
                nearest.distanceToGreenMeters,
            nearestArea: nil,
            requiresConfirmation:
                confidenceRequiresConfirmation(
                    locationConfidence
                )
        )
    }

    private func makeCandidate(
        hole: Hole,
        golfer: GeoCoordinate
    ) -> Candidate {

        let distanceToTee =
            hole.teeLocation.map {
                DistanceCalculator.distanceMeters(
                    from: golfer,
                    to: $0
                )
            }

        let distanceToGreen =
            hole.greenLocation.map {
                DistanceCalculator.distanceMeters(
                    from: golfer,
                    to: $0
                )
            }

        let availableDistances =
            [
                distanceToTee,
                distanceToGreen
            ]
            .compactMap { $0 }

        let proximityDistance =
            availableDistances.min() ??
            Double.greatestFiniteMagnitude

        return Candidate(
            hole: hole,
            distanceToTeeMeters:
                distanceToTee,
            distanceToGreenMeters:
                distanceToGreen,
            proximityDistance:
                proximityDistance
        )
    }

    private func confidence(
        candidate: Candidate
    ) -> HoleLocationConfidence {
        if let teeDistance =
                candidate.distanceToTeeMeters,
           teeDistance <=
                configuration.teeRadiusMeters {

            return .high
        }

        if let greenDistance =
                candidate.distanceToGreenMeters,
           greenDistance <=
                configuration.greenRadiusMeters {

            return .high
        }

        let likelyDistance =
            min(
                configuration.maximumHoleDistanceMeters,
                80
            )

        if candidate.proximityDistance <=
            likelyDistance {

            return .likely
        }

        if candidate.proximityDistance <=
            configuration.maximumHoleDistanceMeters {

            return .possible
        }

        return .none
    }

    private func confidenceRequiresConfirmation(
        _ confidence:
            HoleLocationConfidence
    ) -> Bool {

        switch confidence {
        case .certain,
             .high:
            return false

        case .none,
             .possible,
             .likely:
            return true
        }
    }

    private func noMatchResult()
        -> HoleLocationResult {

        HoleLocationResult(
            hole: nil,
            confidence: .none,
            requiresConfirmation: true
        )
    }

    private struct Candidate:
        Sendable {

        let hole: Hole

        let distanceToTeeMeters:
            Double?

        let distanceToGreenMeters:
            Double?

        let proximityDistance:
            Double
    }
}
