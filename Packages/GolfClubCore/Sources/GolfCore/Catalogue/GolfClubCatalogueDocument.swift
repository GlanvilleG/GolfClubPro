//
//  GolfClubCatalogueDocument.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation

public struct GolfClubCatalogueDocument:
    Codable,
    Equatable,
    Sendable {

    public var schemaVersion: Int
    public var golfClubs: [GolfClub]

    public init(
        schemaVersion: Int = 1,
        golfClubs: [GolfClub]
    ) {
        self.schemaVersion = schemaVersion
        self.golfClubs = golfClubs
    }
}
