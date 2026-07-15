//
//  CoachingPreferences.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct CoachingPreferences:
    Codable,
    Equatable,
    Sendable {

    public var isCoachingEnabled:
        Bool

    public var preferredDetailLevel:
        CoachingDetailLevel

    public var preferredDeliveryMode:
        CoachingDeliveryMode

    public init(
        isCoachingEnabled: Bool = true,
        preferredDetailLevel:
            CoachingDetailLevel =
                .standard,
        preferredDeliveryMode:
            CoachingDeliveryMode =
                .watch
    ) {
        self.isCoachingEnabled =
            isCoachingEnabled

        self.preferredDetailLevel =
            preferredDetailLevel

        self.preferredDeliveryMode =
            preferredDeliveryMode
    }
}
