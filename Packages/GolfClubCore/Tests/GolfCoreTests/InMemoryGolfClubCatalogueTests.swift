//
//  InMemoryGolfClubCatalogueTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import XCTest
@testable import GolfCore

final class InMemoryGolfClubCatalogueTests:
    XCTestCase {

    func testReturnsAllGolfClubs()
        async throws {

        let club = GolfClub(
            name: "Test Club",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            )
        )

        let catalogue =
            InMemoryGolfClubCatalogue(
                clubs: [club]
            )

        let clubs =
            try await catalogue.golfClubs()

        XCTAssertEqual(
            clubs,
            [club]
        )
    }

    func testReturnsCourseByID()
        async throws {

        let course = Course(
            name: "Test Course"
        )

        let club = GolfClub(
            name: "Test Club",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            courses: [course]
        )

        let catalogue =
            InMemoryGolfClubCatalogue(
                clubs: [club]
            )

        let restored =
            try await catalogue.course(
                id: course.id
            )

        XCTAssertEqual(
            restored,
            course
        )
    }

    func testReturnsHolesForCourse()
        async throws {

        let hole = Hole(
            number: 1,
            par: 4,
            lengthMeters: 350
        )

        let course = Course(
            name: "Test Course",
            holes: [hole]
        )

        let club = GolfClub(
            name: "Test Club",
            location: GeoCoordinate(
                latitude: 0,
                longitude: 0
            ),
            courses: [course]
        )

        let catalogue =
            InMemoryGolfClubCatalogue(
                clubs: [club]
            )

        let holes =
            try await catalogue.holes(
                courseID: course.id
            )

        XCTAssertEqual(
            holes,
            [hole]
        )
    }

    func testUnknownCourseReturnsEmptyHoleList()
        async throws {

        let catalogue =
            InMemoryGolfClubCatalogue()

        let holes =
            try await catalogue.holes(
                courseID: CourseID()
            )

        XCTAssertTrue(
            holes.isEmpty
        )
    }
}
