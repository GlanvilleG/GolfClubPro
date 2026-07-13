//
//  GolfClubCatalogue.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

public protocol GolfClubCatalogue:
    Sendable {

    func golfClubs()
        async throws -> [GolfClub]

    func golfClub(
        id: GolfClubID
    ) async throws -> GolfClub?

    func course(
        id: CourseID
    ) async throws -> Course?

    func holes(
        courseID: CourseID
    ) async throws -> [Hole]
}
