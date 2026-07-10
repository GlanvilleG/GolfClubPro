//
//  TargetPoint.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum TargetPointType: String, Codable, CaseIterable, Sendable {
    case pin
    case greenCentre
    case landingZone
    case layup
    case bailout
    case recovery
    case safeMiss
}

public struct TargetPoint: Codable, Equatable, Sendable {
    public let id: TargetPointID
    public var location: GeoCoordinate
    public var type: TargetPointType
    public var label: String?

    public init(
        id: TargetPointID = TargetPointID(),
        location: GeoCoordinate,
        type: TargetPointType,
        label: String? = nil
    ) {
        self.id = id
        self.location = location
        self.type = type
        self.label = label
    }
}
