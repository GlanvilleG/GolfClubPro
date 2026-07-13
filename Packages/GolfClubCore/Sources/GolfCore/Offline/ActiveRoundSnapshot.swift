//
//  ActiveRoundSnapshot.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct ActiveRoundSnapshot:
    Codable,
    Equatable,
    Sendable {

    public var round: Round

    public var capturedAt: Date
    public var deviceID: DeviceID
    public var localRevision: Int

    public var pendingEvents: [OfflineEvent]

    public var cachedCourseGeometry: HoleGeometry?
    public var cachedStrategyGeometry: HoleStrategyGeometry?
    public var cachedWeatherSnapshot: WeatherSnapshot?

    public init(
        round: Round,
        capturedAt: Date = Date(),
        deviceID: DeviceID,
        localRevision: Int = 1,
        pendingEvents: [OfflineEvent] = [],
        cachedCourseGeometry: HoleGeometry? = nil,
        cachedStrategyGeometry: HoleStrategyGeometry? = nil,
        cachedWeatherSnapshot: WeatherSnapshot? = nil
    ) {
        self.round = round
        self.capturedAt = capturedAt
        self.deviceID = deviceID
        self.localRevision = max(1, localRevision)
        self.pendingEvents = pendingEvents
        self.cachedCourseGeometry = cachedCourseGeometry
        self.cachedStrategyGeometry = cachedStrategyGeometry
        self.cachedWeatherSnapshot = cachedWeatherSnapshot
    }

    public var hasPendingEvents: Bool {
        pendingEvents.contains {
            $0.status == .pending ||
            $0.status == .failed ||
            $0.status == .deferred
        }
    }

    public var nextSequenceNumber: Int {
        let highestSequence = pendingEvents
            .compactMap(\.sequenceNumber)
            .max() ?? 0

        return highestSequence + 1
    }
}
