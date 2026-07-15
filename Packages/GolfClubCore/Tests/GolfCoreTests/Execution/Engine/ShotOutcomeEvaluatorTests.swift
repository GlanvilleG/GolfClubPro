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


    // MARK: - Excellent Outcome

    func testExcellentOutcomeWhenTargetAchievedAndHazardAvoided()
    throws {

        let planned =
            makePlannedShotOutcome(
                expectedDistanceMeters:
                    180,
                targetRadiusMeters:
                    25,
                hazardRadiusMeters:
                    20
            )

        let actual =
            makeActualShotOutcome(
                distanceMeters:
                    178,
                insideTarget:
                    true,
                insideHazard:
                    false
            )

        let result =
            evaluator.evaluate(
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

        XCTAssertTrue(
            result.feedback.contains {
                $0.contains(
                    "planned landing area"
                )
            }
        )
    }


    // MARK: - Good Decision Poor Execution

    func testGoodDecisionPoorExecution()
    throws {

        let planned =
            makePlannedShotOutcome(
                expectedDistanceMeters:
                    180,
                targetRadiusMeters:
                    25,
                hazardRadiusMeters:
                    20
            )

        let actual =
            makeActualShotOutcome(
                distanceMeters:
                    145,
                insideTarget:
                    false,
                insideHazard:
                    false
            )

        let result =
            evaluator.evaluate(
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


    // MARK: - Good Execution Poor Strategy

    func testGoodExecutionButTargetNotAchieved()
    throws {

        let planned =
            makePlannedShotOutcome(
                expectedDistanceMeters:
                    180,
                targetRadiusMeters:
                    25,
                hazardRadiusMeters:
                    20
            )

        let actual =
            makeActualShotOutcome(
                distanceMeters:
                    180,
                insideTarget:
                    false,
                insideHazard:
                    false
            )

        let result =
            evaluator.evaluate(
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
            .poor
        )
    }


    // MARK: - Poor Outcome

    func testPoorOutcomeWhenTargetMissedAndHazardHit()
    throws {

        let planned =
            makePlannedShotOutcome(
                expectedDistanceMeters:
                    180,
                targetRadiusMeters:
                    25,
                hazardRadiusMeters:
                    20
            )

        let actual =
            makeActualShotOutcome(
                distanceMeters:
                    130,
                insideTarget:
                    false,
                insideHazard:
                    true
            )

        let result =
            evaluator.evaluate(
                planned:
                    planned,
                actual:
                    actual
            )

        XCTAssertEqual(
            result.decisionQuality,
            .poor
        )

        XCTAssertEqual(
            result.executionQuality,
            .needsImprovement
        )

        XCTAssertTrue(
            result.feedback.contains {
                $0.contains(
                    "outside"
                )
            }
        )
    }


    // MARK: - Helpers


    private func makePlannedShotOutcome(
        expectedDistanceMeters:
            Double,
        targetRadiusMeters:
            Double,
        hazardRadiusMeters:
            Double
    ) -> PlannedShotOutcome {

        PlannedShotOutcome(
            shotID:
                ShotID(),
            clubID:
                ClubID(),
            targetLocation:
                GeoCoordinate(
                    latitude:
                        0,
                    longitude:
                        0
                ),
            expectedDistanceMeters:
                expectedDistanceMeters,
            landingArea:
                LandingArea(
                    centre:
                        GeoCoordinate(
                            latitude:
                                0,
                            longitude:
                                0
                        ),
                    radiusMeters:
                        targetRadiusMeters
                ),
            avoidZones:
                [
                    HazardZone(
                        name:
                            "Fairway Bunker",
                        location:
                            GeoCoordinate(
                                latitude:
                                    0.01,
                                longitude:
                                    0
                            ),
                        radiusMeters:
                            hazardRadiusMeters
                    )
                ]
        )
    }


    private func makeActualShotOutcome(
        distanceMeters:
            Double,
        insideTarget:
            Bool,
        insideHazard:
            Bool
    ) -> ActualShotOutcome {

        let location:
            GeoCoordinate

        if insideTarget {

            location =
                GeoCoordinate(
                    latitude:
                        0,
                    longitude:
                        0
                )

        } else if insideHazard {

            location =
                GeoCoordinate(
                    latitude:
                        0.01,
                    longitude:
                        0
                )

        } else {

            location =
                GeoCoordinate(
                    latitude:
                        0.02,
                    longitude:
                        0
                )
        }

        return ActualShotOutcome(
            shotID:
                ShotID(),
            landingLocation:
                location,
            distanceMeters:
                distanceMeters
        )
    }
}
