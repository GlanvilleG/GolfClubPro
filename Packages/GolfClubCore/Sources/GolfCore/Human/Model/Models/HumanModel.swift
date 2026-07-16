//
//  HumanModel 2.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//


import Foundation

public struct HumanModel:
    Codable,
    Equatable,
    Sendable {

    public let playerID:
        PlayerID

    public var playingCharacteristics:
        PlayerCharacteristics

    public var coachingPreferences:
        CoachingPreferences

    public var equipmentPreferences:
        EquipmentPreferences

    public var performance:
        PlayerPerformanceModel

    public init(
        playerID: PlayerID,
        playingCharacteristics:
            PlayerCharacteristics =
                PlayerCharacteristics(),
        coachingPreferences:
            CoachingPreferences =
                CoachingPreferences(),
        equipmentPreferences:
            EquipmentPreferences =
                EquipmentPreferences(),
        performance:
            PlayerPerformanceModel? = nil
    ) {
        self.playerID =
            playerID

        self.playingCharacteristics =
            playingCharacteristics

        self.coachingPreferences =
            coachingPreferences

        self.equipmentPreferences =
            equipmentPreferences

        self.performance =
            performance ??
            PlayerPerformanceModel(
                playerID: playerID
            )
    }
}

public extension HumanModel {

    var hasConsistentIdentity:
        Bool {

        performance.playerID ==
            playerID
    }
}

public extension HumanModel {

    init(
        playerID: PlayerID,
        playingCharacteristics:
            PlayerCharacteristics,
        coachingPreferences:
            CoachingPreferences,
        equipmentPreferences:
            EquipmentPreferences,
        restoredPerformance:
            PlayerPerformanceModel
    ) throws {

        guard restoredPerformance.playerID ==
                playerID
        else {
            throw HumanModelError
                .inconsistentPlayerIdentity
        }

        self.playerID =
            playerID

        self.playingCharacteristics =
            playingCharacteristics

        self.coachingPreferences =
            coachingPreferences

        self.equipmentPreferences =
            equipmentPreferences

        self.performance =
            restoredPerformance
    }
}

public enum HumanModelError:
    Error,
    Equatable,
    Sendable {

    case inconsistentPlayerIdentity
}
