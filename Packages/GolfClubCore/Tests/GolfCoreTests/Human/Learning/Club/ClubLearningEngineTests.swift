//
//  ClubLearningEngineTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class ClubLearningEngineTests:
    XCTestCase {
    
    func testFirstShotCreatesProfile()
    throws {
        
        let engine =
        ClubLearningEngine()
        
        let shot =
        makeShot(
            distance:
                180
        )
        
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
                    makeAssessment()
            )
        
        let profile =
            engine.updateDispersionProfile(
                existing:
                    nil,
                observation:
                    observation
            )
        
        XCTAssertEqual(
            profile.sampleCount,
            1
        )
        
        XCTAssertEqual(
            profile.averageCarryMeters,
            180
        )
        
        func testMultipleShotsUpdateAverageCarry()
        throws {

            let engine =
                ClubLearningEngine()

            let firstShot =
                makeShot(
                    distance:
                        180
                )

            let firstObservation =
                makeObservation(
                    shot:
                        firstShot
                )

            let firstProfile =
                engine.updateDispersionProfile(
                    existing:
                        nil,
                    observation:
                        firstObservation
                )


            let secondShot =
                makeShot(
                    distance:
                        190
                )

            let secondObservation =
                makeObservation(
                    shot:
                        secondShot
                )

            let updatedProfile =
                engine.updateDispersionProfile(
                    existing:
                        firstProfile,
                    observation:
                        secondObservation
                )


            XCTAssertEqual(
                updatedProfile.sampleCount,
                2
            )

            XCTAssertEqual(
                updatedProfile.averageCarryMeters,
                185
            )
        }
        
        func testConfidenceIncreasesWithAdditionalShots()
        throws {

            let engine =
                ClubLearningEngine()


            var profile:
                ShotDispersionProfile?


            for distance in stride(
                from:
                    1,
                through:
                    25,
                by:
                    1
            ) {

                let shot =
                    makeShot(
                        distance:
                            Double(
                                170 + distance
                            )
                    )

                let observation =
                    makeObservation(
                        shot:
                            shot
                    )

                profile =
                    engine.updateDispersionProfile(
                        existing:
                            profile,
                        observation:
                            observation
                    )
            }


            XCTAssertEqual(
                profile?
                    .sampleCount,
                25
            )

            XCTAssertEqual(
                profile?
                    .confidence,
                0.5
            )
        }
        
        func testExistingProfileIsUpdatedRatherThanReplaced()
        throws {

            let engine =
                ClubLearningEngine()

            let clubID =
                ClubID()

            let existing =
                ShotDispersionProfile(
                    clubID:
                        clubID,
                    sampleCount:
                        10,
                    averageCarryMeters:
                        180,
                    lateralBiasMeters:
                        5,
                    shotShape:
                        .fade,
                    confidence:
                        0.2
                )


            let shot =
                Shot(
                    roundID:
                        RoundID(),
                    holeID:
                        HoleID(),
                    clubID:
                        clubID,
                    distanceMeters:
                        190
                )


            let observation =
                makeObservation(
                    shot:
                        shot
                )


            let updated =
                engine.updateDispersionProfile(
                    existing:
                        existing,
                    observation:
                        observation
                )


            XCTAssertEqual(
                updated.sampleCount,
                11
            )

            XCTAssertEqual(
                updated.averageCarryMeters,
                180.909,
                accuracy:
                    0.01
            )

            XCTAssertEqual(
                updated.shotShape,
                .fade
            )
        }
        func testLearningHandlesMissingStartLocation()
        throws {

            let engine =
                ClubLearningEngine()

            let shot =
                Shot(
                    roundID:
                        RoundID(),
                    holeID:
                        HoleID(),
                    clubID:
                        ClubID(),
                    distanceMeters:
                        180
                )


            let observation =
                makeObservation(
                    shot:
                        shot
                )


            let profile =
                engine.updateDispersionProfile(
                    existing:
                        nil,
                    observation:
                        observation
                )


            XCTAssertEqual(
                profile.sampleCount,
                1
            )

            XCTAssertEqual(
                profile.lateralBiasMeters,
                0
            )
        }
        func testFirstErrorCreatesPatternProfile()
        throws {

            let engine =
                ClubLearningEngine()


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


            let profile =
                engine.updateErrorPatternProfile(
                    existing:
                        nil,
                    observation:
                        observation
                )


            XCTAssertEqual(
                profile.sampleCount,
                1
            )


            XCTAssertEqual(
                profile.dominantError?
                    .error,
                .slice
            )
        }
        
        func testRepeatedErrorsIncreaseFrequency()
        throws {

            let engine =
                ClubLearningEngine()


            let first =
                makeObservation(
                    shot:
                        makeShotWithError(
                            error:
                                .slice
                        )
                )


            var profile =
                engine.updateErrorPatternProfile(
                    existing:
                        nil,
                    observation:
                        first
                )


            let second =
                makeObservation(
                    shot:
                        makeShotWithError(
                            error:
                                .slice
                        )
                )


            profile =
                engine.updateErrorPatternProfile(
                    existing:
                        profile,
                    observation:
                        second
                )


            XCTAssertEqual(
                profile
                    .frequency(
                        for:
                            .slice
                    )?
                    .occurrenceCount,
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
                        -39.9285,
                    longitude:
                        175.0510
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
    private func makeShotWithError(
        error:
            ShotError
    ) -> Shot {

        var shot =
            makeShot(
                distance:
                    180
            )

        shot.feedback =
            ShotFeedback(
                rawTranscript:
                    "I sliced it",
                classifiedErrors:
                    [error],
                sentiment:
                    .negative
            )

        return shot
    }

    
    private func makeShot(
        distance:
            Double
    ) -> Shot {

        Shot(
            roundID:
                RoundID(),
            holeID:
                HoleID(),
            clubID:
                ClubID(),
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
                distance
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
}
