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

       public var summary:
           OverallPerformanceSummary

       public var metadata:
           PerformanceMetadata

       public var dispersionProfiles:
           [ShotDispersionProfile]

       public var errorPatternProfiles:
           [ShotErrorPatternProfile]

    public init(
           playerID:
               PlayerID,
           clubs:
               [ClubPerformance] = [],
           characteristics:
               PlayerCharacteristics =
                   PlayerCharacteristics(),
           summary:
               OverallPerformanceSummary =
                   OverallPerformanceSummary(),
           metadata:
               PerformanceMetadata =
                   PerformanceMetadata(),
           dispersionProfiles:
               [ShotDispersionProfile] = [],
           errorPatternProfiles:
               [ShotErrorPatternProfile] = []
       ) {

           self.playerID =
               playerID

           self.clubs =
               clubs

           self.characteristics =
               characteristics

           self.summary =
               summary

           self.metadata =
               metadata

           self.dispersionProfiles =
               dispersionProfiles

           self.errorPatternProfiles =
               errorPatternProfiles
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
public extension PlayerPerformanceModel {

    func dispersionProfile(
        for clubID:
            ClubID
    ) -> ShotDispersionProfile? {

        dispersionProfiles.first {
            $0.clubID == clubID
        }
    }

    func errorPatternProfile(
        for clubID:
            ClubID
    ) -> ShotErrorPatternProfile? {

        errorPatternProfiles.first {
            $0.clubID == clubID
        }
    }
}
public extension PlayerPerformanceModel {

    mutating func setDispersionProfile(
        _ profile:
            ShotDispersionProfile
    ) {
        if let index =
            dispersionProfiles.firstIndex(
                where: {
                    $0.clubID ==
                        profile.clubID
                }
            ) {

            dispersionProfiles[index] =
                profile
        } else {
            dispersionProfiles.append(
                profile
            )
        }
    }

    mutating func setErrorPatternProfile(
        _ profile:
            ShotErrorPatternProfile
    ) {
        if let index =
            errorPatternProfiles.firstIndex(
                where: {
                    $0.clubID ==
                        profile.clubID
                }
            ) {

            errorPatternProfiles[index] =
                profile
        } else {
            errorPatternProfiles.append(
                profile
            )
        }
    }
}
