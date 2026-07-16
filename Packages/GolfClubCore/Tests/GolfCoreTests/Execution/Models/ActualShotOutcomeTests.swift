//
//  ActualShotOutcomeTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class ActualShotOutcomeTests:
    XCTestCase {

    func testCreatesActualShotOutcome() {

        let shot =
            makeShot()

        let location =
            GeoCoordinate(
                latitude:
                    -39.9,
                longitude:
                    175.0
            )

        let outcome =
            ActualShotOutcome(
                shot:
                    shot,
                landingLocation:
                    location,
                distanceMeters:
                    180
            )

        XCTAssertEqual(
            outcome.shotID,
            shot.id
        )

        XCTAssertEqual(
            outcome.distanceMeters,
            180
        )
    }
    func testNegativeDistanceIsClamped() {

        let shot =
        makeShot()
        
        let outcome =
            ActualShotOutcome(
                shot:
                    shot,
                landingLocation:
                    GeoCoordinate(
                        latitude:
                            0,
                        longitude:
                            0
                    ),
                distanceMeters:
                    -20
            )

        XCTAssertEqual(
            outcome.distanceMeters,
            0
        )
    }
    func testCalculatesDistanceFromTarget()
    {

        let target =
            GeoCoordinate(
                latitude:
                    0,
                longitude:
                    0
            )

        let shot =
        makeShot()
        
        let outcome =
            ActualShotOutcome(
                shot:
                    shot,
                landingLocation:
                    GeoCoordinate(
                        latitude:
                            0.001,
                        longitude:
                            0
                    ),
                distanceMeters:
                    110
            )

        XCTAssertGreaterThan(
            outcome.distanceFrom(target),
            100
        )
    }
    func testCalculatesDistanceFromLocation() {

        let origin =
            GeoCoordinate(
                latitude: 0,
                longitude: 0
            )

        let shot =
        makeShot()
        
        let outcome =
            ActualShotOutcome(
                shot:
                    shot,
                landingLocation:
                    GeoCoordinate(
                        latitude: 0.001,
                        longitude: 0
                    ),
                distanceMeters:
                    110
            )

        XCTAssertGreaterThan(
            outcome.distanceFrom(origin),
            100
        )
    }
    func testSupportsCodable()
    throws {

        let shot =
        makeShot()
        
        let original =
            ActualShotOutcome(
                shot:
                    shot,
                landingLocation:
                    GeoCoordinate(
                        latitude:
                            -39.9,
                        longitude:
                            175.0
                    ),
                distanceMeters:
                    180
            )

        let data =
            try JSONEncoder()
                .encode(original)

        let decoded =
            try JSONDecoder()
                .decode(
                    ActualShotOutcome.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }
    private func makeShot(
        id:
            ShotID = ShotID()
    ) -> Shot {

        Shot(
            id:
                id,
            roundID:
                RoundID(),
            holeID:
                HoleID(),
            clubID:
                ClubID()
        )
    }
    private func makeActualOutcome(
        shot:
            Shot
    ) -> ActualShotOutcome {

        ActualShotOutcome(
            shot:
                shot,
            landingLocation:
                GeoCoordinate(
                    latitude:
                        0,
                    longitude:
                        0
                ),
            distanceMeters:
                180
        )
    }
}
