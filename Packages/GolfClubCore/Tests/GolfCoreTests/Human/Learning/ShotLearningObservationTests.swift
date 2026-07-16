//
//  ShotLearningObservationTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotLearningObservationTests:
    XCTestCase {


    func testCreatesLearningObservation()
    {

        let shot =
            makeShot()

        let planned =
            makePlannedOutcome(
                shot:
                    shot
            )

        let actual =
            makeActualOutcome(
                shot:
                    shot
            )

        let assessment =
            ShotOutcomeAssessment.successful(
                feedback:
                    [
                        "Good strike"
                    ]
            )

        let observation =
            ShotLearningObservation(
                shot:
                    shot,
                plannedOutcome:
                    planned,
                actualOutcome:
                    actual,
                assessment:
                    assessment
            )

        XCTAssertEqual(
            observation.shot.id,
            shot.id
        )

        XCTAssertEqual(
            observation.plannedOutcome.shotID,
            shot.id
        )

        XCTAssertEqual(
            observation.actualOutcome.shotID,
            shot.id
        )
    }


    func testIdentityConsistency()
    {

        let shot =
            makeShot()

        let observation =
            ShotLearningObservation(
                shot:
                    shot,
                plannedOutcome:
                    makePlannedOutcome(
                        shot:
                            shot
                    ),
                actualOutcome:
                    makeActualOutcome(
                        shot:
                            shot
                    ),
                assessment:
                    ShotOutcomeAssessment.successful(
                        feedback:
                            []
                    )
            )

        XCTAssertTrue(
            observation.hasConsistentIdentity
        )
    }


    func testDetectsIdentityMismatch()
    {

        let shot =
            makeShot()

        let differentShot =
            makeShot()

        let observation =
            ShotLearningObservation(
                shot:
                    shot,
                plannedOutcome:
                    makePlannedOutcome(
                        shot:
                            differentShot
                    ),
                actualOutcome:
                    makeActualOutcome(
                        shot:
                            differentShot
                    ),
                assessment:
                    ShotOutcomeAssessment.successful(
                        feedback:
                            []
                    )
            )

        XCTAssertFalse(
            observation.hasConsistentIdentity
        )
    }


    func testSupportsCodableRoundTrip()
    throws {

        let shot =
            makeShot()

        let original =
            ShotLearningObservation(
                shot:
                    shot,
                plannedOutcome:
                    makePlannedOutcome(
                        shot:
                            shot
                    ),
                actualOutcome:
                    makeActualOutcome(
                        shot:
                            shot
                    ),
                assessment:
                    ShotOutcomeAssessment.successful(
                        feedback:
                            [
                                "Good shot"
                            ]
                    )
            )


        let data =
            try JSONEncoder()
                .encode(
                    original
                )

        let decoded =
            try JSONDecoder()
                .decode(
                    ShotLearningObservation.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }


    // MARK: Helpers


    private func makeShot()
        -> Shot {

        Shot(
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
            Shot
    )
        -> PlannedShotOutcome {

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
                LandingArea(
                    centre:
                        target,
                    radiusMeters:
                        25
                )
        )
    }


    private func makeActualOutcome(
        shot:
            Shot
    )
        -> ActualShotOutcome {

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
