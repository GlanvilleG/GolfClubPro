//
//  LieDetector.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public struct LieDetector: Sendable {

    private let geometryEngine:
        CourseGeometryEngine

    private let minimumAutomaticConfidence:
        Double

    private let requiredConfidenceThreshold:
        Double

    private let boundaryDistanceMeters:
        Double

    public init(
        geometryEngine:
            CourseGeometryEngine =
                CourseGeometryEngine(),
        minimumAutomaticConfidence:
            Double = 0.75,
        requiredConfidenceThreshold:
            Double = 0.40,
        boundaryDistanceMeters:
            Double = 5
    ) {
        self.geometryEngine =
            geometryEngine

        self.minimumAutomaticConfidence =
            Self.clamp(
                minimumAutomaticConfidence
            )

        self.requiredConfidenceThreshold =
            Self.clamp(
                requiredConfidenceThreshold
            )

        self.boundaryDistanceMeters =
            max(
                0,
                boundaryDistanceMeters
            )
    }

    public func detectLie(
        at coordinate: GeoCoordinate,
        using geometry: HoleGeometry
    ) -> LieDetectionResult {

        let geometryResult =
            geometryEngine.evaluate(
                location: coordinate,
                geometry: geometry
            )

        let inferredLie =
            playableLie(
                for: geometryResult.primaryArea
            )

        let source: LieSource =
            geometryResult.primaryArea == .unknown
            ? .unknown
            : .inferredFromHoleGeometry

        let requirement =
            confirmationRequirement(
                geometryResult:
                    geometryResult,
                inferredLie:
                    inferredLie
            )

        return LieDetectionResult(
            holeArea:
                geometryResult.primaryArea,
            playableLie:
                inferredLie,
            source:
                source,
            confidence:
                geometryResult.confidence,
            distanceToBoundaryMeters:
                geometryResult
                    .nearestBoundaryDistanceMeters,
            confirmationRequirement:
                requirement
        )
    }

    public func confirmationRequirement(
        for result: LieDetectionResult
    ) -> LieConfirmationRequirement {

        let reasons =
            confirmationReasons(
                holeArea:
                    result.holeArea,
                playableLie:
                    result.playableLie,
                confidence:
                    result.confidence ?? 0,
                distanceToBoundaryMeters:
                    result
                        .distanceToBoundaryMeters
            )

        return makeConfirmationRequirement(
            inferredLie:
                result.playableLie,
            confidence:
                result.confidence ?? 0,
            reasons:
                reasons
        )
    }

    private func confirmationRequirement(
        geometryResult: CourseGeometryResult,
        inferredLie: PlayableLie
    ) -> LieConfirmationRequirement {

        let reasons =
            confirmationReasons(
                holeArea:
                    geometryResult.primaryArea,
                playableLie:
                    inferredLie,
                confidence:
                    geometryResult.confidence,
                distanceToBoundaryMeters:
                    geometryResult
                        .nearestBoundaryDistanceMeters
            )

        return makeConfirmationRequirement(
            inferredLie:
                inferredLie,
            confidence:
                geometryResult.confidence,
            reasons:
                reasons
        )
    }

    private func confirmationReasons(
        holeArea: HoleAreaType,
        playableLie: PlayableLie,
        confidence: Double,
        distanceToBoundaryMeters:
            Double?
    ) -> [LieConfirmationReason] {

        var reasons:
            [LieConfirmationReason] = []

        if holeArea == .unknown ||
            playableLie == .unknown {

            reasons.append(
                .unknownArea
            )
        }

        if confidence <
            minimumAutomaticConfidence {

            reasons.append(
                .lowConfidence
            )
        }

        if let distance =
                distanceToBoundaryMeters,
           distance <=
                boundaryDistanceMeters {

            reasons.append(
                .nearBoundary
            )
        }

        if isSensitiveArea(
            holeArea
        ) {
            reasons.append(
                .sensitiveArea
            )
        }

        return Array(
            Set(reasons)
        )
    }

    private func makeConfirmationRequirement(
        inferredLie: PlayableLie,
        confidence: Double,
        reasons: [LieConfirmationReason]
    ) -> LieConfirmationRequirement {

        guard !reasons.isEmpty else {
            return .notRequired
        }

        let requiresConfirmation =
            inferredLie == .unknown ||
            confidence <
                requiredConfidenceThreshold ||
            reasons.contains(
                .unknownArea
            ) ||
            reasons.contains(
                .sensitiveArea
            )

        if requiresConfirmation {
            return .required(
                inferredLie:
                    inferredLie,
                reasons:
                    reasons
            )
        }

        return .recommended(
            inferredLie:
                inferredLie,
            reasons:
                reasons
        )
    }

    private func playableLie(
        for area: HoleAreaType
    ) -> PlayableLie {

        switch area {

        case .tee:
            return .tee

        case .fairway:
            return .fairway

        case .rough:
            return .lightRough

        case .green:
            return .green

        case .fringe:
            return .fringe

        case .bunker:
            return .fairwayBunker

        case .water:
            return .water

        case .trees:
            return .trees

        case .outOfBounds:
            return .outOfBounds

        case .penaltyArea:
            return .penaltyArea

        case .unknown:
            return .unknown

        @unknown default:
            return .unknown
        }
    }

    private func isSensitiveArea(
        _ area: HoleAreaType
    ) -> Bool {

        switch area {
        case .water,
             .outOfBounds,
             .penaltyArea:
            return true

        default:
            return false
        }
    }

    private static func clamp(
        _ value: Double
    ) -> Double {
        min(
            1,
            max(
                0,
                value
            )
        )
    }
}

