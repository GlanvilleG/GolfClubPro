//
//  InMemoryGolfClubCatalogue.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public actor InMemoryGolfClubCatalogue:
    GolfClubCatalogue {

    private var clubs: [GolfClub]

    public init(
        clubs: [GolfClub] = []
    ) {
        self.clubs = clubs
    }

    public func golfClubs()
        async throws -> [GolfClub] {
        clubs
    }

    public func golfClub(
        id: GolfClubID
    ) async throws -> GolfClub? {
        clubs.first {
            $0.id == id
        }
    }

    public func course(
        id: CourseID
    ) async throws -> Course? {
        clubs
            .flatMap(\.courses)
            .first {
                $0.id == id
            }
    }

    public func holes(
        courseID: CourseID
    ) async throws -> [Hole] {
        clubs
            .flatMap(\.courses)
            .first {
                $0.id == courseID
            }?
            .holes ?? []
    }

    public func replaceAll(
        with clubs: [GolfClub]
    ) {
        self.clubs = clubs
    }
}
