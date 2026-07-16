//
//  PlannedShotOutcomeTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class PlannedShotOutcomeTests:
    XCTestCase {


    // MARK: - Creation


    func testCreatesPlannedShotOutcomeFromShot()
    {

        let shot =
            makeShot()

        let target =
            GeoCoordinate(
                latitude:
                    -39.9000,
                longitude:
                    175.0000
            )

        let landingArea =
            LandingArea(
                centre:
                    target,
                radiusMeters:
                    25
            )

        let outcome =
            PlannedShotOutcome(
                shot:
                    shot,
                targetLocation:
                    target,
                expectedDistanceMeters:
                    180,
                landingArea:
                    landingArea
            )

        XCTAssertEqual(
            outcome.shotID,
            shot.id
        )

        XCTAssertEqual(
            outcome.clubID,
            shot.clubID
        )

        XCTAssertEqual(
            outcome.expectedDistanceMeters,
            180
        )
    }


    // MARK: - Identity


    func testUsesShotIdentity()
    {

        let shotID =
            ShotID()

        let shot =
            makeShot(
                id:
                    shotID
            )

        let outcome =
            makePlannedOutcome(
                shot:
                    shot
            )

        XCTAssertEqual(
            outcome.shotID,
            shotID
        )
    }


    // MARK: - Target Area


    func testStoresLandingArea()
    {

        let landingArea =
            LandingArea(
                centre:
                    GeoCoordinate(
                        latitude:
                            0,
                        longitude:
                            0
                    ),
                radiusMeters:
                    30
            )

        let outcome =
            makePlannedOutcome(
                landingArea:
                    landingArea
            )

        XCTAssertEqual(
            outcome.landingArea,
            landingArea
        )
    }


    // MARK: - Hazard Avoidance


    func testStoresAvoidZones()
    {

        let hazard =
            HazardZone(
                name:
                    "Right Fairway Bunker",
                location:
                    GeoCoordinate(
                        latitude:
                            0.01,
                        longitude:
                            0
                    ),
                radiusMeters:
                    20
            )

        let outcome =
            makePlannedOutcome(
                avoidZones:
                    [hazard]
            )

        XCTAssertEqual(
            outcome.avoidZones.count,
            1
        )

        XCTAssertEqual(
            outcome.avoidZones.first,
            hazard
        )
    }


    // MARK: - Codable


    func testSupportsCodable()
    throws {

        let original =
            makePlannedOutcome()

        let data =
            try JSONEncoder()
                .encode(original)

        let decoded =
            try JSONDecoder()
                .decode(
                    PlannedShotOutcome.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }


    // MARK: - Helpers


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


    private func makePlannedOutcome(
        shot:
            Shot? = nil,
        landingArea:
            LandingArea? = nil,
        avoidZones:
            [HazardZone] = []
    ) -> PlannedShotOutcome {

        let shot =
            shot ??
            makeShot()

        let target =
            GeoCoordinate(
                latitude:
                    0,
                longitude:
                    0
            )

        return PlannedShotOutcome(
            shot:
                shot,
            targetLocation:
                target,
            expectedDistanceMeters:
                180,
            landingArea:
                landingArea ??
                LandingArea(
                    centre:
                        target,
                    radiusMeters:
                        25
                ),
            avoidZones:
                avoidZones
        )
    }
}
