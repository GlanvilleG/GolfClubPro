//
//  PerformanceLearningEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class PerformanceLearningEngineTests:
    XCTestCase {


    func testFirstShotCreatesPlayerProfile()
    throws {

        let engine =
            PerformanceLearningEngine()


        let shot =
            makeShot(
                clubID:
                    ClubID()
            )


        let observation =
            makeObservation(
                shot:
                    shot
            )


        let performance =
            PlayerPerformanceModel(
                playerID:
                    PlayerID()
            )


        let updated =
            engine.learn(
                observation:
                    observation,
                performance:
                    performance
            )


        XCTAssertEqual(
            updated.dispersionProfiles.count,
            1
        )


        XCTAssertEqual(
            updated
                .dispersionProfiles
                .first?
                .clubID,
            shot.clubID
        )
    }
    func testSecondShotUpdatesExistingClubProfile()
    throws {

        let engine =
            PerformanceLearningEngine()


        let clubID =
            ClubID()


        let initialShot =
            makeShot(
                clubID:
                    clubID
            )


        var performance =
            engine.learn(
                observation:
                    makeObservation(
                        shot:
                            initialShot
                    ),
                performance:
                    PlayerPerformanceModel(
                        playerID:
                            PlayerID()
                    )
            )


        let secondShot =
            makeShot(
                clubID:
                    clubID
            )


        performance =
            engine.learn(
                observation:
                    makeObservation(
                        shot:
                            secondShot
                    ),
                performance:
                    performance
            )


        XCTAssertEqual(
            performance.dispersionProfiles.count,
            1
        )


        XCTAssertEqual(
            performance
                .dispersionProfiles
                .first?
                .sampleCount,
            2
        )
    }
    func testDifferentClubsCreateSeparateProfiles()
    throws {

        let engine =
            PerformanceLearningEngine()


        var performance =
            PlayerPerformanceModel(
                playerID:
                    PlayerID()
            )


        let driverShot =
            makeShot(
                clubID:
                    ClubID()
            )


        performance =
            engine.learn(
                observation:
                    makeObservation(
                        shot:
                            driverShot
                    ),
                performance:
                    performance
            )


        let ironShot =
            makeShot(
                clubID:
                    ClubID()
            )


        performance =
            engine.learn(
                observation:
                    makeObservation(
                        shot:
                            ironShot
                    ),
                performance:
                    performance
            )


        XCTAssertEqual(
            performance.dispersionProfiles.count,
            2
        )
        
        func testLearningUpdatesDispersionAndErrorProfiles()
        throws {

            let engine =
                PerformanceLearningEngine()


            let shot =
                makeShotWithError(
                    error:
                        .slice
                )


            let observation =
                makeObservation(
                    shot:
                        shot
                )


            let performance =
                PlayerPerformanceModel(
                    playerID:
                        PlayerID()
                )


            let updated =
                engine.learn(
                    observation:
                        observation,
                    performance:
                        performance
                )


            XCTAssertEqual(
                updated.dispersionProfiles.count,
                1
            )


            XCTAssertEqual(
                updated.errorPatternProfiles.count,
                1
            )


            XCTAssertEqual(
                updated
                    .errorPatternProfiles
                    .first?
                    .dominantError?
                    .error,
                .slice
            )
        }
        
        func testSameClubAccumulatesLearning()
        throws {

            let engine =
                PerformanceLearningEngine()


            let clubID =
                ClubID()


            var performance =
                PlayerPerformanceModel(
                    playerID:
                        PlayerID()
                )


            let firstShot =
                makeShotWithError(
                    clubID:
                        clubID,
                    error:
                        .slice
                )


            performance =
                engine.learn(
                    observation:
                        makeObservation(
                            shot:
                                firstShot
                        ),
                    performance:
                        performance
                )


            let secondShot =
                makeShotWithError(
                    clubID:
                        clubID,
                    error:
                        .slice
                )


            performance =
                engine.learn(
                    observation:
                        makeObservation(
                            shot:
                                secondShot
                        ),
                    performance:
                        performance
                )


            XCTAssertEqual(
                performance
                    .dispersionProfile(
                        for:
                            clubID
                    )?
                    .sampleCount,
                2
            )


            XCTAssertEqual(
                performance
                    .errorPatternProfile(
                        for:
                            clubID
                    )?
                    .sampleCount,
                2
            )
        }
        
        func testDifferentClubsMaintainSeparateLearning()
        throws {

            let engine =
                PerformanceLearningEngine()


            var performance =
                PlayerPerformanceModel(
                    playerID:
                        PlayerID()
                )


            let driver =
                makeShotWithError(
                    error:
                        .slice
                )


            performance =
                engine.learn(
                    observation:
                        makeObservation(
                            shot:
                                driver
                        ),
                    performance:
                        performance
                )


            let iron =
                makeShotWithError(
                    error:
                        .thin
                )


            performance =
                engine.learn(
                    observation:
                        makeObservation(
                            shot:
                                iron
                        ),
                    performance:
                        performance
                )


            XCTAssertEqual(
                performance.dispersionProfiles.count,
                2
            )

            XCTAssertEqual(
                performance.errorPatternProfiles.count,
                2
            )
        }
        
    }
    private func makeObservation(
        shot:
            Shot
    ) -> ShotLearningObservation {

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
                makeAssessment()
        )
    }
}
private func makeShot(
    clubID:
        ClubID
) -> Shot {

    Shot(
        roundID:
            RoundID(),
        holeID:
            HoleID(),
        clubID:
            clubID,
        startLocation:
            GeoCoordinate(
                latitude:
                    -39.9300,
                longitude:
                    175.0500
            ),
        distanceMeters:
            180
    )
}
private func makePlannedOutcome(
    shot:
        Shot
) -> PlannedShotOutcome {

    let target =
        GeoCoordinate(
            latitude:
                -39.9300,
            longitude:
                175.0500
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
) -> ActualShotOutcome {

    ActualShotOutcome(
        shot:
            shot,
        landingLocation:
            GeoCoordinate(
                latitude:
                    -39.9295,
                longitude:
                    175.0510
            ),
        distanceMeters:
            shot.distanceMeters
            ?? 180
    )
}
private func makeAssessment()
    -> ShotOutcomeAssessment {

    ShotOutcomeAssessment.successful(
        feedback:
            [
                "Good strike"
            ]
    )
}
private func makeShotWithError(
    clubID:
        ClubID = ClubID(),
    error:
        ShotError
) -> Shot {

    var shot =
        Shot(
            roundID:
                RoundID(),
            holeID:
                HoleID(),
            clubID:
                clubID,
            startLocation:
                GeoCoordinate(
                    latitude:
                        -39.9300,
                    longitude:
                        175.0500
                ),
            endLocation:
                GeoCoordinate(
                    latitude:
                        -39.9285,
                    longitude:
                        175.0510
                ),
            distanceMeters:
                180
        )


    shot.feedback =
        ShotFeedback(
            rawTranscript:
                "Shot feedback",
            classifiedErrors:
                [
                    error
                ],
            sentiment:
                .negative
        )


    return shot
}
