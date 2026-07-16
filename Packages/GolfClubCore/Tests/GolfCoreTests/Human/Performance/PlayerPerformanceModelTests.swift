//
//  PlayerPerformanceModelTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//


import XCTest
@testable import GolfCore

final class PlayerPerfomanceModelTests:
    XCTestCase {
    
    func testDefaultsToEmptyAdaptationProfiles() {
        
        let model =
        PlayerPerformanceModel(
            playerID:
                PlayerID()
        )
        
        XCTAssertTrue(
            model.dispersionProfiles.isEmpty
        )
        
        XCTAssertTrue(
            model.errorPatternProfiles.isEmpty
        )
    }
    func testFindsDispersionProfileByClubID() {
        
        let clubID =
        ClubID()
        
        let profile =
        ShotDispersionProfile(
            clubID:
                clubID,
            sampleCount:
                10
        )
        
        let model =
        PlayerPerformanceModel(
            playerID:
                PlayerID(),
            dispersionProfiles:
                [profile]
        )
        
        XCTAssertEqual(
            model.dispersionProfile(
                for:
                    clubID
            ),
            profile
        )
    }
    func testFindsErrorPatternProfileByClubID() {
        
        let clubID =
        ClubID()
        
        let profile =
        ShotErrorPatternProfile(
            clubID:
                clubID,
            sampleCount:
                10
        )
        
        let model =
        PlayerPerformanceModel(
            playerID:
                PlayerID(),
            errorPatternProfiles:
                [profile]
        )
        
        XCTAssertEqual(
            model.errorPatternProfile(
                for:
                    clubID
            ),
            profile
        )
    }
    func testSetDispersionProfileReplacesExistingClubProfile() {
        
        let clubID =
        ClubID()
        
        var model =
        PlayerPerformanceModel(
            playerID:
                PlayerID(),
            dispersionProfiles:
                [
                    ShotDispersionProfile(
                        clubID:
                            clubID,
                        sampleCount:
                            5
                    )
                ]
        )
        
        let updated =
        ShotDispersionProfile(
            clubID:
                clubID,
            sampleCount:
                12
        )
        
        model.setDispersionProfile(
            updated
        )
        
        XCTAssertEqual(
            model.dispersionProfiles.count,
            1
        )
        
        XCTAssertEqual(
            model.dispersionProfile(
                for:
                    clubID
            ),
            updated
        )
    }
    func testSetErrorPatternProfileAppendsNewClubProfile() {
        
        let profile =
        ShotErrorPatternProfile(
            clubID:
                ClubID(),
            sampleCount:
                8
        )
        
        var model =
        PlayerPerformanceModel(
            playerID:
                PlayerID()
        )
        
        model.setErrorPatternProfile(
            profile
        )
        
        XCTAssertEqual(
            model.errorPatternProfiles,
            [profile]
        )
    }
}
