//
//  RoundSpatialContextInput.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct RoundSpatialContextInput:
    Sendable {

    public let currentHoleID:
        HoleID?

    public let golferPosition:
        GeoCoordinate

    public let observedAt:
        Date

    public let courseIndex:
        CourseSpatialIndex

    public init(
        currentHoleID: HoleID?,
        golferPosition: GeoCoordinate,
        observedAt: Date,
        courseIndex: CourseSpatialIndex
    ) {
        self.currentHoleID =
            currentHoleID

        self.golferPosition =
            golferPosition

        self.observedAt =
            observedAt

        self.courseIndex =
            courseIndex
    }
}
