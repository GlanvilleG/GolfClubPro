//
//  TestClubFactory.swift
//  GolfClubCore
//
//  Created by Dragon Development on 21/07/2026.
//
import Foundation
@testable import GolfCore

enum TestClubFactory {

    static func makeClub(
        name: String = "7 Iron",
        type: ClubType = .iron,
        averageCarryMeters: Double? = 145,
        loftDegrees: Double? = nil
    ) -> Club {
        Club(
            name: name,
            type: type,
            loftDegrees: loftDegrees,
            averageCarryMeters: averageCarryMeters
        )
    }

    static func makeDriver(
        averageCarryMeters: Double = 230
    ) -> Club {
        makeClub(name: "Driver", type: .driver, averageCarryMeters: averageCarryMeters)
    }

    static func makeFairwayWood(
        name: String = "3 Wood",
        averageCarryMeters: Double = 210
    ) -> Club {
        makeClub(name: name, type: .fairwayWood, averageCarryMeters: averageCarryMeters)
    }

    static func makeHybrid(
        name: String = "4 Hybrid",
        averageCarryMeters: Double = 195
    ) -> Club {
        makeClub(name: name, type: .hybrid, averageCarryMeters: averageCarryMeters)
    }

    static func makeIron(
        number: Int = 7,
        averageCarryMeters: Double = 145
    ) -> Club {
        makeClub(name: "\(number) Iron", type: .iron, averageCarryMeters: averageCarryMeters)
    }

    static func makeWedge(
        name: String = "Sand Wedge",
        averageCarryMeters: Double = 80,
        loftDegrees: Double? = 56
    ) -> Club {
        makeClub(name: name, type: .wedge, averageCarryMeters: averageCarryMeters, loftDegrees: loftDegrees)
    }

    static func makePutter() -> Club {
        makeClub(name: "Putter", type: .putter, averageCarryMeters: 0)
    }
}

