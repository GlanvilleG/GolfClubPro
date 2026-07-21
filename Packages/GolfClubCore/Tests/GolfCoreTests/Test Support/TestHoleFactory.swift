//
//  TestHoleFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//

import Foundation
@testable import GolfCore

enum TestHoleFactory {

    static func area(
        type: HoleAreaType,
        boundary: [GeoCoordinate] = []
    ) -> HoleArea {

        HoleArea(
            type: type,
            boundary: boundary
        )
    }

    static func areaAssessment(
        type: HoleAreaType,
        probability: Double
    ) -> HoleAreaAssessment {

        HoleAreaAssessment(
            area: area(type: type),
            probability: probability,
            risk: HazardRisk.classify(
                probability: probability
            )
        )
    }

    static func areaAssessment(
        area: HoleArea,
        probability: Double
    ) -> HoleAreaAssessment {

        HoleAreaAssessment(
            area: area,
            probability: probability,
            risk: HazardRisk.classify(
                probability: probability
            )
        )
    }
}
extension TestHoleFactory {

    static func square(
        type: HoleAreaType,
        centre: GeoCoordinate,
        sizeDegrees: Double = 0.0001
    ) -> HoleArea {

        let d = sizeDegrees / 2

        return HoleArea(
            type: type,
            boundary: [
                GeoCoordinate(
                    latitude: centre.latitude - d,
                    longitude: centre.longitude - d
                ),
                GeoCoordinate(
                    latitude: centre.latitude - d,
                    longitude: centre.longitude + d
                ),
                GeoCoordinate(
                    latitude: centre.latitude + d,
                    longitude: centre.longitude + d
                ),
                GeoCoordinate(
                    latitude: centre.latitude + d,
                    longitude: centre.longitude - d
                )
            ]
        )
    }
}
