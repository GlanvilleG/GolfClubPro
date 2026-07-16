//
//  ShotDispersionProfileTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import XCTest
@testable import GolfCore

final class ShotDispersionProfileTests:
    XCTestCase {

    func testCreatesShotDispersionProfile() {

        let clubID =
            ClubID()

        let profile =
            ShotDispersionProfile(
                clubID:
                    clubID,
                sampleCount:
                    20,
                averageCarryMeters:
                    180,
                lateralBiasMeters:
                    8,
                distanceStandardDeviationMeters:
                    12,
                lateralStandardDeviationMeters:
                    9,
                shotShape:
                    .fade,
                confidence:
                    0.80
            )

        XCTAssertEqual(
            profile.clubID,
            clubID
        )

        XCTAssertEqual(
            profile.sampleCount,
            20
        )

        XCTAssertEqual(
            profile.averageCarryMeters,
            180
        )

        XCTAssertEqual(
            profile.lateralBiasMeters,
            8
        )

        XCTAssertEqual(
            profile.shotShape,
            .fade
        )

        XCTAssertEqual(
            profile.confidence,
            0.80
        )
    }

    func testClampsInvalidValues() {

        let profile =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    -5,
                averageCarryMeters:
                    -20,
                distanceStandardDeviationMeters:
                    -4,
                lateralStandardDeviationMeters:
                    -3,
                confidence:
                    1.5
            )

        XCTAssertEqual(
            profile.sampleCount,
            0
        )

        XCTAssertEqual(
            profile.averageCarryMeters,
            0
        )

        XCTAssertEqual(
            profile.distanceStandardDeviationMeters,
            0
        )

        XCTAssertEqual(
            profile.lateralStandardDeviationMeters,
            0
        )

        XCTAssertEqual(
            profile.confidence,
            1
        )
    }

    func testIdentifiesRightBias() {

        let profile =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    10,
                lateralBiasMeters:
                    8
            )

        XCTAssertTrue(
            profile.hasDirectionalBias
        )

        XCTAssertTrue(
            profile.isBiasedRight
        )

        XCTAssertFalse(
            profile.isBiasedLeft
        )
    }

    func testIdentifiesLeftBias() {

        let profile =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    10,
                lateralBiasMeters:
                    -6
            )

        XCTAssertTrue(
            profile.hasDirectionalBias
        )

        XCTAssertTrue(
            profile.isBiasedLeft
        )

        XCTAssertFalse(
            profile.isBiasedRight
        )
    }

    func testRequiresFiveSamplesForSufficientData() {

        let insufficient =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    4
            )

        let sufficient =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    5
            )

        XCTAssertFalse(
            insufficient.hasSufficientData
        )

        XCTAssertTrue(
            sufficient.hasSufficientData
        )
    }

    func testSupportsCodableRoundTrip()
        throws {

        let original =
            ShotDispersionProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    30,
                averageCarryMeters:
                    190,
                lateralBiasMeters:
                    -5,
                distanceStandardDeviationMeters:
                    11,
                lateralStandardDeviationMeters:
                    8,
                shotShape:
                    .draw,
                confidence:
                    0.85
            )

        let data =
            try JSONEncoder()
                .encode(
                    original
                )

        let decoded =
            try JSONDecoder()
                .decode(
                    ShotDispersionProfile.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }
}
