//
//  CoachingConfiguration.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct CoachingConfiguration:
    Codable,
    Equatable,
    Sendable {

    public let enabled: Bool
    public let level: CoachingLevel
    public let detailLevel: CoachingDetailLevel
    public let deliveryMode: CoachingDeliveryMode

    public init(
        enabled: Bool = true,
        level: CoachingLevel = .standard,
        detailLevel: CoachingDetailLevel = .standard,
        deliveryMode: CoachingDeliveryMode = .watch
    ) {
        self.enabled = enabled
        self.level = level
        self.detailLevel = detailLevel
        self.deliveryMode = deliveryMode
    }
}
