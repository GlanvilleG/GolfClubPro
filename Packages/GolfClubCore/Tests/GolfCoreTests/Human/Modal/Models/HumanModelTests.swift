//
//  HumanModelTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//
import XCTest
@testable import GolfCore

final class HumanModelTests:
    XCTestCase {

    func testCreatesAggregateForPlayer() {
        let playerID =
            PlayerID()

        let model =
            HumanModel(
                playerID: playerID
            )

        XCTAssertEqual(
            model.playerID,
            playerID
        )

        XCTAssertEqual(
            model.performance.playerID,
            playerID
        )

        XCTAssertTrue(
            model.hasConsistentIdentity
        )
    }

    func testDefaultsToRightHandedPlayer() {
        let model =
            HumanModel(
                playerID: PlayerID()
            )

        XCTAssertEqual(
            model
                .playingCharacteristics
                .dominantHand,
            .right
        )

        XCTAssertEqual(
            model
                .playingCharacteristics
                .dominantHand
                .leadSide,
            .left
        )
    }

    func testSupportsLeftHandedPlayer() {
        let characteristics =
            PlayerCharacteristics(
                dominantHand: .left
            )

        let model =
            HumanModel(
                playerID: PlayerID(),
                playingCharacteristics:
                    characteristics
            )

        XCTAssertEqual(
            model
                .playingCharacteristics
                .dominantHand
                .leadSide,
            .right
        )
    }

    func testCoachingCanBeDisabled() {
        let preferences =
            CoachingPreferences(
                isCoachingEnabled:
                    false
            )

        let model =
            HumanModel(
                playerID: PlayerID(),
                coachingPreferences:
                    preferences
            )

        XCTAssertFalse(
            model
                .coachingPreferences
                .isCoachingEnabled
        )
    }

    func testRejectsRestoredPerformanceForDifferentPlayer() {
        let result =
            Result {
                try HumanModel(
                    playerID:
                        PlayerID(),
                    playingCharacteristics:
                        PlayerCharacteristics(),
                    coachingPreferences:
                        CoachingPreferences(),
                    equipmentPreferences:
                        EquipmentPreferences(),
                    restoredPerformance:
                        PlayerPerformanceModel(
                            playerID:
                                PlayerID()
                        )
                )
            }

        XCTAssertThrowsError(
            try result.get()
        ) { error in
            XCTAssertEqual(
                error as?
                    HumanModelError,
                .inconsistentPlayerIdentity
            )
        }
    }
}
