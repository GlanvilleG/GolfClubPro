//
//  CourseGeometryEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct CourseGeometryConfiguration:
    Codable,
    Equatable,
    Sendable {

    public var boundaryConfirmationDistanceMeters:
        Double

    public var clearInteriorConfidence:
        Double

    public var boundaryConfidence:
        Double

    public var unknownConfidence:
        Double

    public init(
        boundaryConfirmationDistanceMeters:
            Double = 5,
        clearInteriorConfidence:
            Double = 0.90,
        boundaryConfidence:
            Double = 0.65,
        unknownConfidence:
            Double = 0.20
    ) {
        self.boundaryConfirmationDistanceMeters =
            max(
                0,
                boundaryConfirmationDistanceMeters
            )

        self.clearInteriorConfidence =
            Self.clamp(
                clearInteriorConfidence
            )

        self.boundaryConfidence =
            Self.clamp(
                boundaryConfidence
            )

        self.unknownConfidence =
            Self.clamp(
                unknownConfidence
            )
    }

    private static func clamp(
        _ value: Double
    ) -> Double {
        min(
            1,
            max(0, value)
        )
    }
}

public struct CourseGeometryEngine:
    Sendable {

    private let configuration:
        CourseGeometryConfiguration

    public init(
        configuration:
            CourseGeometryConfiguration =
                CourseGeometryConfiguration()
    ) {
        self.configuration =
            configuration
    }

    public func evaluate(
        location: GeoCoordinate,
        geometry: HoleGeometry
    ) -> CourseGeometryResult {
        let matches =
            geometry.areas.compactMap {
                evaluate(
                    location: location,
                    area: $0
                )
            }

        let containingMatches =
            matches.filter(
                \.containsLocation
            )

        guard !containingMatches.isEmpty else {
            let nearestBoundary =
                matches
                    .map(
                        \.distanceToBoundaryMeters
                    )
                    .min()

            return CourseGeometryResult(
                primaryArea: .unknown,
                matches: matches,
                nearestBoundaryDistanceMeters:
                    nearestBoundary,
                confidence:
                    configuration
                        .unknownConfidence,
                requiresConfirmation: true
            )
        }

        let orderedMatches =
            containingMatches.sorted {
                priority(
                    for: $0.areaType
                ) >
                priority(
                    for: $1.areaType
                )
            }

        let primary =
            orderedMatches[0]

        let nearestBoundary =
            containingMatches
                .map(
                    \.distanceToBoundaryMeters
                )
                .min()

        let isNearBoundary =
            (
                nearestBoundary ??
                .greatestFiniteMagnitude
            ) <=
            configuration
                .boundaryConfirmationDistanceMeters

        let isAmbiguous =
            containingMatches.count > 1 &&
            priority(
                for: containingMatches[0]
                    .areaType
            ) ==
            priority(
                for: containingMatches[1]
                    .areaType
            )

        let requiresConfirmation =
            isNearBoundary ||
            isAmbiguous

        let confidence =
            requiresConfirmation
            ? configuration.boundaryConfidence
            : configuration
                .clearInteriorConfidence

        return CourseGeometryResult(
            primaryArea: primary.areaType,
            matches: matches,
            nearestBoundaryDistanceMeters:
                nearestBoundary,
            confidence: confidence,
            requiresConfirmation:
                requiresConfirmation
        )
    }

    public func contains(
        _ location: GeoCoordinate,
        in area: HoleArea
    ) -> Bool {
        guard area.boundary.count >= 3 else {
            return false
        }

        let origin =
            area.boundary[0]

        let projectedLocation =
            GeometryProjection.project(
                location,
                relativeTo: origin
            )

        let polygon =
            area.boundary.map {
                GeometryProjection.project(
                    $0,
                    relativeTo: origin
                )
            }

        return PolygonGeometry.contains(
            point: projectedLocation,
            polygon: polygon
        )
    }

    public func distanceToBoundary(
        from location: GeoCoordinate,
        of area: HoleArea
    ) -> Double? {
        guard area.boundary.count >= 2 else {
            return nil
        }

        let origin =
            area.boundary[0]

        let projectedLocation =
            GeometryProjection.project(
                location,
                relativeTo: origin
            )

        let polygon =
            area.boundary.map {
                GeometryProjection.project(
                    $0,
                    relativeTo: origin
                )
            }

        return PolygonGeometry
            .distanceToBoundary(
                point: projectedLocation,
                polygon: polygon
            )
    }

    private func evaluate(
        location: GeoCoordinate,
        area: HoleArea
    ) -> CourseGeometryAreaMatch? {
        guard let boundaryDistance =
                distanceToBoundary(
                    from: location,
                    of: area
                )
        else {
            return nil
        }

        return CourseGeometryAreaMatch(
            areaType: area.type,
            containsLocation:
                contains(
                    location,
                    in: area
                ),
            distanceToBoundaryMeters:
                boundaryDistance
        )
    }

    private func priority(
        for area: HoleAreaType
    ) -> Int {
        switch area {
        case .outOfBounds:
            return 100

        case .water:
            return 95

        case .penaltyArea:
            return 90

        case .bunker:
            return 85

        case .green:
            return 80

        case .fringe:
            return 75

        case .tee:
            return 70

        case .fairway:
            return 60

        case .rough:
            return 50

        case .trees:
            return 40

        case .unknown:
            return 0
        case .cartPath:
            return 10
        case .nativeArea:
            return 20
        }
    }
}
