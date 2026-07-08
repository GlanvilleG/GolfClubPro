//
//  Hole.swift
//  GolfCore
//
//  Created by Dragon Development on 06/07/2026.
//
import Foundation

public struct Hole: Identifiable, Codable, Equatable {
    public let id: UUID
    public var number: Int
    public var par: Int
    public var strokeIndex: Int?
    public var lengthMeters: Double

    public init(
        id: UUID = UUID(),
        number: Int,
        par: Int,
        strokeIndex: Int? = nil,
        lengthMeters: Double
    ) {
        self.id = id
        self.number = number
        self.par = par
        self.strokeIndex = strokeIndex
        self.lengthMeters = lengthMeters
    }
}
