//
//  RoundSpatialContextBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

public struct RoundSpatialContextBuilder:
    Sendable {

    private let geometryEngine:
        HoleGeometryEngine

    private let lieDetector:
        LieDetector

    public init(
        geometryEngine:
            HoleGeometryEngine =
                HoleGeometryEngine(),
        lieDetector:
            LieDetector =
                LieDetector()
    ) {
        self.geometryEngine =
            geometryEngine

        self.lieDetector =
            lieDetector
    }

    public func build(
        input: RoundSpatialContextInput
    ) -> RoundSpatialContext {

        guard let currentHoleID =
                input.currentHoleID,
              let hole =
                input.courseIndex.hole(
                    id: currentHoleID
                )
        else {
            return makeUnknownContext(
                input: input
            )
        }

        let distanceToTee =
            input.courseIndex
                .distanceToTeeMeters(
                    from:
                        input.golferPosition,
                    holeID:
                        currentHoleID
                )

        let distanceToGreen =
            input.courseIndex
                .distanceToGreenMeters(
                    from:
                        input.golferPosition,
                    holeID:
                        currentHoleID
                )

        guard let geometry =
                input.courseIndex.geometry(
                    for: currentHoleID
                ),
              !geometry.areas.isEmpty
        else {
            return RoundSpatialContext(
                observedAt:
                    input.observedAt,
                golferPosition:
                    input.golferPosition,
                hole:
                    hole,
                holeLocationConfidence:
                    .certain,
                distanceToTeeMeters:
                    distanceToTee,
                distanceToGreenMeters:
                    distanceToGreen,
                remainingDistanceMeters:
                    distanceToGreen,
                requiresConfirmation:
                    false
            )
        }

        let geometryResult =
            geometryEngine.evaluate(
                location:
                    input.golferPosition,
                geometry:
                    geometry
            )

        let lieResult =
            lieDetector.detectLie(
                at:
                    input.golferPosition,
                using:
                    geometry
            )

        return RoundSpatialContext(
            observedAt:
                input.observedAt,
            golferPosition:
                input.golferPosition,
            hole:
                hole,
            holeLocationConfidence:
                .certain,
            holeArea:
                geometryResult.primaryArea,
            playableLie:
                lieResult.playableLie,
            distanceToTeeMeters:
                distanceToTee,
            distanceToGreenMeters:
                distanceToGreen,
            remainingDistanceMeters:
                distanceToGreen,
            nearestBoundaryDistanceMeters:
                geometryResult
                    .nearestBoundaryDistanceMeters,
            requiresConfirmation:
                lieResult
                    .confirmationRequirement
                    .shouldPromptGolfer
        )
    }

    private func makeUnknownContext(
        input: RoundSpatialContextInput
    ) -> RoundSpatialContext {
        RoundSpatialContext(
            observedAt:
                input.observedAt,
            golferPosition:
                input.golferPosition,
            hole:
                nil,
            holeLocationConfidence:
                .none,
            requiresConfirmation:
                true
        )
    }
}
