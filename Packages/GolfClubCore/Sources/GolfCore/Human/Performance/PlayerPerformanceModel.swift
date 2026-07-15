//
//  PlayerPerformanceModel.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation

public struct PlayerPerformanceModel:
    Codable,
    Equatable,
    Sendable {

    public let playerID:
        PlayerID

    public var clubs:
        [ClubPerformance]

    public var characteristics:
        PlayerCharacteristics

    public var metadata:
        PerformanceMetadata

    public init(
        playerID: PlayerID,
        clubs:
            [ClubPerformance] = [],
        characteristics:
            PlayerCharacteristics =
                PlayerCharacteristics(),
        metadata:
            PerformanceMetadata =
                PerformanceMetadata()
    ) {
        self.playerID =
            playerID

        self.clubs =
            clubs

        self.characteristics =
            characteristics

        self.metadata =
            metadata
    }
}
public extension PlayerPerformanceModel {

    func performance(
        for clubID: ClubID
    ) -> ClubPerformance? {

        clubs.first {
            $0.clubID == clubID
        }
    }

    var totalRecordedShots:
        Int {

        clubs.reduce(0) {
            $0 + $1.shotCount
        }
    }
}
