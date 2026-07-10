//
//  OfflineEventQueue.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum OfflineEventQueueError:
    Error,
    Equatable,
    Sendable {

    case eventNotFound
    case eventAlreadyCompleted
    case invalidSequenceNumber
}

public struct OfflineEventQueue:
    Sendable {

    public init() {}

    public func enqueue(
        type: OfflineEventType,
        roundID: RoundID? = nil,
        entityID: String? = nil,
        sequenceNumber: Int? = nil,
        deviceID: DeviceID,
        payload: Data? = nil,
        into events: [OfflineEvent]
    ) -> [OfflineEvent] {
        var updatedEvents = events

        let resolvedSequence: Int?

        if roundID != nil {
            resolvedSequence =
                sequenceNumber ??
                nextSequenceNumber(
                    for: roundID,
                    in: events
                )
        } else {
            resolvedSequence = sequenceNumber
        }

        let event = OfflineEvent(
            type: type,
            roundID: roundID,
            entityID: entityID,
            sequenceNumber: resolvedSequence,
            deviceID: deviceID,
            payload: payload
        )

        updatedEvents.append(event)

        return sorted(updatedEvents)
    }

    public func markProcessing(
        eventID: OfflineEventID,
        at date: Date = Date(),
        in events: [OfflineEvent]
    ) throws -> [OfflineEvent] {
        try updateEvent(
            eventID: eventID,
            in: events
        ) { event in
            guard event.status != .completed else {
                throw OfflineEventQueueError
                    .eventAlreadyCompleted
            }

            event.status = .processing
            event.attemptCount += 1
            event.lastAttemptAt = date
            event.updatedAt = date
            event.lastErrorDescription = nil
        }
    }

    public func markCompleted(
        eventID: OfflineEventID,
        at date: Date = Date(),
        in events: [OfflineEvent]
    ) throws -> [OfflineEvent] {
        try updateEvent(
            eventID: eventID,
            in: events
        ) { event in
            event.status = .completed
            event.updatedAt = date
            event.nextAttemptAt = nil
            event.lastErrorDescription = nil
        }
    }

    public func markFailed(
        eventID: OfflineEventID,
        errorDescription: String,
        retryAt: Date? = nil,
        at date: Date = Date(),
        in events: [OfflineEvent]
    ) throws -> [OfflineEvent] {
        try updateEvent(
            eventID: eventID,
            in: events
        ) { event in
            guard event.status != .completed else {
                throw OfflineEventQueueError
                    .eventAlreadyCompleted
            }

            event.status = .failed
            event.updatedAt = date
            event.nextAttemptAt = retryAt
            event.lastErrorDescription =
                errorDescription
        }
    }

    public func pendingEvents(
        from events: [OfflineEvent],
        at date: Date = Date()
    ) -> [OfflineEvent] {
        sorted(
            events.filter { event in
                switch event.status {
                case .pending:
                    return true

                case .failed, .deferred:
                    guard let nextAttemptAt =
                        event.nextAttemptAt else {
                        return true
                    }

                    return nextAttemptAt <= date

                case .processing,
                     .completed,
                     .cancelled:
                    return false
                }
            }
        )
    }

    public func nextSequenceNumber(
        for roundID: RoundID?,
        in events: [OfflineEvent]
    ) -> Int {
        let highestSequence = events
            .filter { $0.roundID == roundID }
            .compactMap(\.sequenceNumber)
            .max() ?? 0

        return highestSequence + 1
    }

    public func containsDuplicate(
        _ event: OfflineEvent,
        in events: [OfflineEvent]
    ) -> Bool {
        events.contains { existing in
            existing.id == event.id ||
            (
                existing.roundID == event.roundID &&
                existing.type == event.type &&
                existing.sequenceNumber ==
                    event.sequenceNumber
            )
        }
    }

    private func updateEvent(
        eventID: OfflineEventID,
        in events: [OfflineEvent],
        mutation: (inout OfflineEvent) throws -> Void
    ) throws -> [OfflineEvent] {
        var updatedEvents = events

        guard let index = updatedEvents.firstIndex(
            where: { $0.id == eventID }
        ) else {
            throw OfflineEventQueueError.eventNotFound
        }

        try mutation(&updatedEvents[index])

        return sorted(updatedEvents)
    }

    private func sorted(
        _ events: [OfflineEvent]
    ) -> [OfflineEvent] {
        events.sorted { first, second in
            switch (
                first.sequenceNumber,
                second.sequenceNumber
            ) {
            case let (firstSequence?, secondSequence?):
                if firstSequence ==
                    secondSequence {
                    return first.createdAt <
                        second.createdAt
                }

                return firstSequence <
                    secondSequence

            case (.some, .none):
                return true

            case (.none, .some):
                return false

            case (.none, .none):
                return first.createdAt <
                    second.createdAt
            }
        }
    }
}
