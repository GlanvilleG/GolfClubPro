//
//  PlayingCharacteristics.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct PlayerCharacteristics:
    Codable,
    Equatable,
    Sendable {

    public var dominantHand:
        DominantHand

    public init(
        dominantHand:
            DominantHand = .right
    ) {
        self.dominantHand =
            dominantHand
    }
    public enum DominantHand:
        String,
        Codable,
        CaseIterable,
        Sendable {

        case right
        case left

        public var leadSide:
            BodySide {

            switch self {
            case .right:
                return .left

            case .left:
                return .right
            }
        }

        public var trailSide:
            BodySide {

            switch self {
            case .right:
                return .right

            case .left:
                return .left
            }
        }
    }
    public enum BodySide:
        String,
        Codable,
        CaseIterable,
        Sendable {

        case left
        case right
    }
}
