//
//  ShotOutcomeEvaluatorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class ShotOutcomeEvaluatorTests:
    XCTestCase {

    private let evaluator =
        ShotOutcomeEvaluator()


    // MARK: - Successful Evaluation


    func testEvaluatorAcceptsMatchingShotIdentity()
    throws {

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

        XCTAssertNoThrow(
            try evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )
        )
    }


    func testExcellentOutcomeWhenTargetAchievedAndHazardAvoided()
    throws {

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
                    shot,
                location:
                    GeoCoordinate(
                        latitude:
                            0,
                        longitude:
                            0
                    ),
                distance:
                    178
            )

        let result =
            try evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )

        XCTAssertEqual(
            result.decisionQuality,
            .excellent
        )

        XCTAssertEqual(
            result.executionQuality,
            .excellent
        )
    }


    // MARK: - Execution Quality


    func testGoodDecisionPoorExecution()
    throws {

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
                    shot,
                location:
                    GeoCoordinate(
                        latitude:
                            0.02,
                        longitude:
                            0
                    ),
                distance:
                    130
            )

        let result =
            try evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )

        XCTAssertEqual(
            result.decisionQuality,
            .good
        )

        XCTAssertEqual(
            result.executionQuality,
            .needsImprovement
        )
    }


    func testGoodExecutionWhenTargetAchieved()
    throws {

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
                    shot,
                location:
                    GeoCoordinate(
                        latitude:
                            0,
                        longitude:
                            0
                    ),
                distance:
                    180
            )

        let result =
            try evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )

        XCTAssertEqual(
            result.executionQuality,
            .excellent
        )

        XCTAssertEqual(
            result.decisionQuality,
            .excellent
        )
    }


    // MARK: - Identity Validation


    func testEvaluatorRejectsDifferentShotIdentity()
    throws {

        let plannedShot =
            makeShot()

        let actualShot =
            makeShot()

        let planned =
            makePlannedOutcome(
                shot:
                    plannedShot
            )

        let actual =
            makeActualOutcome(
                shot:
                    actualShot
            )

        XCTAssertThrowsError(
            try evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )
        ) { error in

            XCTAssertEqual(
                error as?
                    ShotOutcomeEvaluationError,
                .shotIdentityMismatch
            )
        }
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
            Shot
    ) -> PlannedShotOutcome {

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
            acceptableDistanceVarianceMeters:
                15,
            landingArea:
                LandingArea(
                    centre:
                        target,
                    radiusMeters:
                        25
                ),
            avoidZones:
                [
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
                ]
        )
    }


    private func makeActualOutcome(
        shot:
            Shot,
        location:
            GeoCoordinate? = nil,
        distance:
            Double = 180
    ) -> ActualShotOutcome {

        ActualShotOutcome(
            shot:
                shot,
            landingLocation:
                location ??
                GeoCoordinate(
                    latitude:
                        0,
                    longitude:
                        0
                ),
            distanceMeters:
                distance
        )
    }
}
