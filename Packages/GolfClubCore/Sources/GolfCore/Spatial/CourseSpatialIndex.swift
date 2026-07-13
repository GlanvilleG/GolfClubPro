//
//  CourseSpatialIndex.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct CourseSpatialIndex:
    Sendable {

    private let holesByID:
        [HoleID: Hole]

    private let teeLocationsByHoleID:
        [HoleID: GeoCoordinate]

    private let greenLocationsByHoleID:
        [HoleID: GeoCoordinate]

    private let geometriesByHoleID:
        [HoleID: HoleGeometry]

    public init(
        holes: [Hole]
    ) {
        self.holesByID =
            Dictionary(
                uniqueKeysWithValues:
                    holes.map {
                        ($0.id, $0)
                    }
            )

        self.teeLocationsByHoleID =
            Dictionary(
                uniqueKeysWithValues:
                    holes.compactMap { hole in
                        guard let teeLocation =
                                hole.teeLocation
                        else {
                            return nil
                        }

                        return (
                            hole.id,
                            teeLocation
                        )
                    }
            )

        self.greenLocationsByHoleID =
            Dictionary(
                uniqueKeysWithValues:
                    holes.compactMap { hole in
                        guard let greenLocation =
                                hole.greenLocation
                        else {
                            return nil
                        }

                        return (
                            hole.id,
                            greenLocation
                        )
                    }
            )

        self.geometriesByHoleID =
            Dictionary(
                uniqueKeysWithValues:
                    holes.compactMap { hole in
                        guard let geometry =
                                hole.geometry
                        else {
                            return nil
                        }

                        return (
                            hole.id,
                            geometry
                        )
                    }
            )
    }

    public var holeCount: Int {
        holesByID.count
    }

    public func hole(
        id: HoleID
    ) -> Hole? {
        holesByID[id]
    }

    public func teeLocation(
        for holeID: HoleID
    ) -> GeoCoordinate? {
        teeLocationsByHoleID[holeID]
    }

    public func greenLocation(
        for holeID: HoleID
    ) -> GeoCoordinate? {
        greenLocationsByHoleID[holeID]
    }

    public func geometry(
        for holeID: HoleID
    ) -> HoleGeometry? {
        geometriesByHoleID[holeID]
    }

    public func distanceToTeeMeters(
        from position: GeoCoordinate,
        holeID: HoleID
    ) -> Double? {
        guard let teeLocation =
                teeLocation(
                    for: holeID
                )
        else {
            return nil
        }

        return DistanceCalculator.distanceMeters(
            from: position,
            to: teeLocation
        )
    }

    public func distanceToGreenMeters(
        from position: GeoCoordinate,
        holeID: HoleID
    ) -> Double? {
        guard let greenLocation =
                greenLocation(
                    for: holeID
                )
        else {
            return nil
        }

        return DistanceCalculator.distanceMeters(
            from: position,
            to: greenLocation
        )
    }
}
