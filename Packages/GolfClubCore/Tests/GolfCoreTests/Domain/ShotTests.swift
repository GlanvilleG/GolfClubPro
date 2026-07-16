//
//  ShotTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore

final class ShotTests:
    XCTestCase {

    func testShotCreatesUniqueIdentity()
    {

        let shotA =
            makeShot()

        let shotB =
            makeShot()

        XCTAssertNotEqual(
            shotA.id,
            shotB.id
        )
    }


    func testShotPreservesProvidedIdentity()
    {

        let id =
            ShotID()

        let shot =
            makeShot(
                id:
                    id
            )

        XCTAssertEqual(
            shot.id,
            id
        )
    }


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
}
