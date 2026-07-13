//
//  SpatialQueryResult.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct SpatialQueryResult:
    Codable,
    Equatable,
    Sendable {

    public var nearestArea:
        HoleArea?

    public var nearestAreaDistanceMeters:
        Double?

    public var insideMappedArea:
        Bool

    public init(
        nearestArea: HoleArea? = nil,
        nearestAreaDistanceMeters: Double? = nil,
        insideMappedArea: Bool = false
    ) {
        self.nearestArea =
            nearestArea

        self.nearestAreaDistanceMeters =
            nearestAreaDistanceMeters

        self.insideMappedArea =
            insideMappedArea
    }
}
