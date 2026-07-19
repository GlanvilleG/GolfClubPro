//
//  SpatialQueryEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct SpatialQueryEngine:
    Sendable {

    private let geometryEngine:
        HoleGeometryEngine

    public init(
        geometryEngine:
            HoleGeometryEngine =
                HoleGeometryEngine()
    ) {
        self.geometryEngine =
            geometryEngine
    }

    public func analyse(
        location: GeoCoordinate,
        geometry: HoleGeometry
    ) -> SpatialAnalysis {
        guard !geometry.areas.isEmpty else {
            return SpatialAnalysis()
        }

        let evaluation =
            geometryEngine.evaluate(
                location:
                    location,
                geometry:
                    geometry
            )

        let nearestArea =
            geometryEngine.nearestArea(
                to:
                    location,
                geometry:
                    geometry
            )

        let nearestHazard =
            nearestHazard(
                to:
                    location,
                geometry:
                    geometry
            )

        return SpatialAnalysis(
            nearestArea:
                nearestArea?.area,
            nearestAreaDistanceMeters:
                nearestArea?
                    .distanceMeters,
            nearestBoundaryDistanceMeters:
                evaluation
                    .nearestBoundaryDistanceMeters,
            nearestHazard:
                nearestHazard?.area,
            nearestHazardDistanceMeters:
                nearestHazard?
                    .distanceMeters,
            insideMappedArea:
                evaluation.primaryArea !=
                    .unknown
        )
    }

    private func nearestHazard(
        to location: GeoCoordinate,
        geometry: HoleGeometry
    ) -> (
        area: HoleArea,
        distanceMeters: Double
    )? {
        var nearest:
            (
                area: HoleArea,
                distanceMeters: Double
            )?

        for area in geometry.areas
        where area.type.isHazard {

            guard let distance =
                    geometryEngine
                        .distanceToBoundary(
                            from:
                                location,
                            of:
                                area
                        )
            else {
                continue
            }

            if let current = nearest,
               distance >=
                current.distanceMeters {
                continue
            }

            nearest = (
                area,
                distance
            )
        }

        return nearest
    }
}
