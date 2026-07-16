//
//  ShotErrorPatternProfileTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
import XCTest
@testable import GolfCore

final class ShotErrorPatternProfileTests:
    XCTestCase {

    func testCreatesErrorPatternProfile() {

        let slice =
            ShotErrorFrequency(
                error:
                    .slice,
                occurrenceCount:
                    8,
                percentage:
                    0.40
            )

        let profile =
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    20,
                errors:
                    [slice]
            )

        XCTAssertEqual(
            profile.sampleCount,
            20
        )

        XCTAssertEqual(
            profile.errors,
            [slice]
        )
    }

    func testClampsInvalidFrequencyValues() {

        let frequency =
            ShotErrorFrequency(
                error:
                    .slice,
                occurrenceCount:
                    -3,
                percentage:
                    1.5
            )

        XCTAssertEqual(
            frequency.occurrenceCount,
            0
        )

        XCTAssertEqual(
            frequency.percentage,
            1
        )
    }

    func testReturnsDominantError() {

        let slice =
            ShotErrorFrequency(
                error:
                    .slice,
                occurrenceCount:
                    10,
                percentage:
                    0.50
            )

        let push =
            ShotErrorFrequency(
                error:
                    .push,
                occurrenceCount:
                    4,
                percentage:
                    0.20
            )

        let profile =
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    20,
                errors:
                    [
                        push,
                        slice
                    ]
            )

        XCTAssertEqual(
            profile.dominantError,
            slice
        )
    }

    func testFindsFrequencyForError() {

        let hook =
            ShotErrorFrequency(
                error:
                    .hook,
                occurrenceCount:
                    3,
                percentage:
                    0.15
            )

        let profile =
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    20,
                errors:
                    [hook]
            )

        XCTAssertEqual(
            profile.frequency(
                for:
                    .hook
            ),
            hook
        )
    }

    func testRequiresFiveSamplesForSufficientData() {

        XCTAssertFalse(
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    4
            )
            .hasSufficientData
        )

        XCTAssertTrue(
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    5
            )
            .hasSufficientData
        )
    }

    func testSupportsCodableRoundTrip()
        throws {

        let original =
            ShotErrorPatternProfile(
                clubID:
                    ClubID(),
                sampleCount:
                    25,
                errors:
                    [
                        ShotErrorFrequency(
                            error:
                                .slice,
                            occurrenceCount:
                                8,
                            percentage:
                                0.32
                        )
                    ]
            )

        let data =
            try JSONEncoder()
                .encode(
                    original
                )

        let decoded =
            try JSONDecoder()
                .decode(
                    ShotErrorPatternProfile.self,
                    from:
                        data
                )

        XCTAssertEqual(
            decoded,
            original
        )
    }
}
