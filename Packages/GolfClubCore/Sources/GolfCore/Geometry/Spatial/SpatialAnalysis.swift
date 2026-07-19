//
//  SpatialAnalysis.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import Foundation

public struct SpatialAnalysis:
    Codable,
    Equatable,
    Sendable {

    public let nearestArea:
        HoleArea?

    public let nearestAreaDistanceMeters:
        Double?

    public let nearestBoundaryDistanceMeters:
        Double?

    public let nearestHazard:
        HoleArea?

    public let nearestHazardDistanceMeters:
        Double?

    public let insideMappedArea:
        Bool

    public init(
        nearestArea: HoleArea? = nil,
        nearestAreaDistanceMeters:
            Double? = nil,
        nearestBoundaryDistanceMeters:
            Double? = nil,
        nearestHazard:
            HoleArea? = nil,
        nearestHazardDistanceMeters:
            Double? = nil,
        insideMappedArea:
            Bool = false
    ) {
        self.nearestArea =
            nearestArea

        self.nearestAreaDistanceMeters =
            nearestAreaDistanceMeters

        self.nearestBoundaryDistanceMeters =
            nearestBoundaryDistanceMeters

        self.nearestHazard =
            nearestHazard

        self.nearestHazardDistanceMeters =
            nearestHazardDistanceMeters

        self.insideMappedArea =
            insideMappedArea
    }
}
