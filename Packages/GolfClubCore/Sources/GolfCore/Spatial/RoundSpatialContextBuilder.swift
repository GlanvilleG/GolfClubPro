//
//  RoundSpatialContextBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

public struct RoundSpatialContextBuilder:
    Sendable {

    private let holeIndex:
        HoleGeometryIndex

    private let geometryEngine:
        HoleGeometryEngine

    private let lieDetector:
        LieDetector

    public init(
        holes: [Hole],
        indexConfiguration:
            HoleGeometryIndexConfiguration =
                HoleGeometryIndexConfiguration(),
        geometryEngine:
            HoleGeometryEngine =
                HoleGeometryEngine(),
        lieDetector:
            LieDetector =
                LieDetector()
    ) {
        self.holeIndex =
            HoleGeometryIndex(
                holes: holes,
                configuration:
                    indexConfiguration
            )

        self.geometryEngine =
            geometryEngine

        self.lieDetector =
            lieDetector
    }

    public func build(
        golferPosition: GeoCoordinate,
        observedAt: Date
    ) -> RoundSpatialContext {

        let locationResult =
            holeIndex.locate(
                golfer: golferPosition
            )

        guard let hole =
                locationResult.hole
        else {
            return RoundSpatialContext(
                observedAt:
                    observedAt,
                golferPosition:
                    golferPosition,
                hole: nil,
                holeLocationConfidence:
                    .none,
                requiresConfirmation:
                    true
            )
        }

        let remainingDistance =
            hole.greenLocation.map {
                DistanceCalculator
                    .distanceMeters(
                        from:
                            golferPosition,
                        to: $0
                    )
            }

        guard let geometry =
                hole.geometry
        else {
            return RoundSpatialContext(
                observedAt:
                    observedAt,
                golferPosition:
                    golferPosition,
                hole:
                    hole,
                holeLocationConfidence:
                    locationResult
                        .confidence,
                distanceToTeeMeters:
                    locationResult
                        .distanceToTeeMeters,
                distanceToGreenMeters:
                    locationResult
                        .distanceToGreenMeters,
                remainingDistanceMeters:
                    remainingDistance,
                requiresConfirmation:
                    locationResult
                        .requiresConfirmation
            )
        }

        let geometryResult =
            geometryEngine.evaluate(
                location:
                    golferPosition,
                geometry:
                    geometry
            )

        let lieResult =
            lieDetector.detectLie(
                at:
                    golferPosition,
                using:
                    geometry
            )

        let requiresConfirmation =
            locationResult
                .requiresConfirmation ||
            lieResult
                .confirmationRequirement
                .shouldPromptGolfer

        return RoundSpatialContext(
            observedAt:
                observedAt,
            golferPosition:
                golferPosition,
            hole:
                hole,
            holeLocationConfidence:
                locationResult
                    .confidence,
            holeArea:
                geometryResult
                    .primaryArea,
            playableLie:
                lieResult
                    .playableLie,
            distanceToTeeMeters:
                locationResult
                    .distanceToTeeMeters,
            distanceToGreenMeters:
                locationResult
                    .distanceToGreenMeters,
            remainingDistanceMeters:
                remainingDistance,
            nearestBoundaryDistanceMeters:
                geometryResult
                    .nearestBoundaryDistanceMeters,
            requiresConfirmation:
                requiresConfirmation
        )
    }
}
