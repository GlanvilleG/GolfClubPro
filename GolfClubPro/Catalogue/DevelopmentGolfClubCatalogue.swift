//
//  DevelopmentGolfClubCatalogue.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//

import GolfCore

enum DevelopmentGolfClubCatalogue {

    static func makeCatalogue()
        -> InMemoryGolfClubCatalogue {

        let hole1 = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350,
            teeLocation: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            greenLocation: GeoCoordinate(
                latitude: -39.9275,
                longitude: 175.0520
            )
        )

        let hole10 = Hole(
            number: 10,
            par: 4,
            lengthMeters: 380,
            teeLocation: GeoCoordinate(
                latitude: -39.9310,
                longitude: 175.0490
            ),
            greenLocation: GeoCoordinate(
                latitude: -39.9280,
                longitude: 175.0470
            )
        )

        let course = Course(
            name: "Main Course",
            holes: [
                hole1,
                hole10
            ]
        )

        let golfClub = GolfClub(
            name: "Development Golf Club",
            location: GeoCoordinate(
                latitude: -39.9300,
                longitude: 175.0500
            ),
            detectionRadiusMeters: 1_000,
            courses: [course]
        )

        return InMemoryGolfClubCatalogue(
            clubs: [golfClub]
        )
    }
}
