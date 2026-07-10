//
//  OfflineEvent.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public enum OfflineEventStatus:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case pending
    case processing
    case completed
    case failed
    case deferred
    case cancelled
}

public enum OfflineEventType:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case roundStarted
    case teeSetConfirmed
    case holeConfirmed
    case clubSelected
    case clubChanged
    case shotStarted
    case shotFeedbackRecorded
    case shotCompleted
    case lieInferred
    case lieConfirmed
    case lieCorrected
    case puttsRecorded
    case holePending
    case holeCompleted
    case roundCompleted

    case playerUpdated
    case recommendationAuditCreated
    case recommendationDecisionRecorded
    case courseDataUpdated
    case weatherSnapshotUpdated
    case dotGolfSubmissionRequested
}

public struct OfflineEvent:
    Codable,
    Equatable,
    Sendable {

    public let id: OfflineEventID

    public var type: OfflineEventType
    public var status: OfflineEventStatus

    public var roundID: RoundID?
    public var entityID: String?

    public var sequenceNumber: Int?
    public var createdAt: Date
    public var updatedAt: Date

    public var deviceID: DeviceID

    public var attemptCount: Int
    public var lastAttemptAt: Date?
    public var nextAttemptAt: Date?

    public var lastErrorDescription: String?
    public var payloadVersion: Int
    public var payload: Data?

    public init(
        id: OfflineEventID = OfflineEventID(),
        type: OfflineEventType,
        status: OfflineEventStatus = .pending,
        roundID: RoundID? = nil,
        entityID: String? = nil,
        sequenceNumber: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deviceID: DeviceID,
        attemptCount: Int = 0,
        lastAttemptAt: Date? = nil,
        nextAttemptAt: Date? = nil,
        lastErrorDescription: String? = nil,
        payloadVersion: Int = 1,
        payload: Data? = nil
    ) {
        self.id = id
        self.type = type
        self.status = status
        self.roundID = roundID
        self.entityID = entityID
        self.sequenceNumber = sequenceNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deviceID = deviceID
        self.attemptCount = max(0, attemptCount)
        self.lastAttemptAt = lastAttemptAt
        self.nextAttemptAt = nextAttemptAt
        self.lastErrorDescription = lastErrorDescription
        self.payloadVersion = max(1, payloadVersion)
        self.payload = payload
    }
}
