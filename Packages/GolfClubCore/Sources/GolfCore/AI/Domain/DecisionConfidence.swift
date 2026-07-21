//
//  Untitled.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Foundation

public struct DecisionConfidence:
    Codable,
    Equatable,
    Comparable,
    Sendable {

    public let value:
        Double

    public init(
        value:
            Double
    ) {
        self.value =
            min(
                max(value, 0),
                1
            )
    }

    public static let none =
        DecisionConfidence(
            value: 0
        )

    public static let full =
        DecisionConfidence(
            value: 1
        )

    public static func < (
        lhs:
            DecisionConfidence,
        rhs:
            DecisionConfidence
    ) -> Bool {

        lhs.value <
            rhs.value
    }
}
