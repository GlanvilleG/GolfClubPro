//
//  EquipmentPreferences.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct EquipmentPreferences:
    Codable,
    Equatable,
    Sendable {

    public var preferredBall:
        String?

    public var preferredTeeHeightMillimetres:
        Double?

    public init(
        preferredBall: String? = nil,
        preferredTeeHeightMillimetres:
            Double? = nil
    ) {
        self.preferredBall =
            preferredBall

        self.preferredTeeHeightMillimetres =
            preferredTeeHeightMillimetres
    }
}
