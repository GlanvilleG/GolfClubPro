//
//  HoleTransitionDetector.swift
//  GolfClubCore
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation

public struct HoleTransitionDetector:
    Sendable {

    private let configuration:
        HoleTransitionDetectorConfiguration

    private var pendingDestinationHoleID:
        HoleID?

    private var consecutiveDestinationCount:
        Int

    public init(
        configuration:
            HoleTransitionDetectorConfiguration =
                HoleTransitionDetectorConfiguration()
    ) {
        self.configuration =
            configuration

        self.pendingDestinationHoleID =
            nil

        self.consecutiveDestinationCount =
            0
    }

    public mutating func evaluate(
        previous:
            RoundSpatialContext?,
        current:
            RoundSpatialContext
    ) -> HoleTransition {

        guard let previous,
              let previousHole =
                previous.hole
        else {
            resetPendingTransition()
            return .noChange
        }

        guard let currentHole =
                current.hole
        else {
            resetPendingTransition()

            return .locationLost(
                previousHoleID:
                    previousHole.id
            )
        }

        guard currentHole.id !=
                previousHole.id
        else {
            resetPendingTransition()
            return .noChange
        }

        guard current.holeLocationConfidence
                .rawValue >=
                configuration
                    .minimumDestinationConfidence
                    .rawValue
        else {
            resetPendingTransition()

            return .possible(
                fromHoleID:
                    previousHole.id,
                toHoleID:
                    currentHole.id
            )
        }

        if pendingDestinationHoleID ==
            currentHole.id {

            consecutiveDestinationCount += 1
        } else {
            pendingDestinationHoleID =
                currentHole.id

            consecutiveDestinationCount =
                1
        }

        guard consecutiveDestinationCount >=
                configuration
                    .requiredConsecutiveObservations
        else {
            return .possible(
                fromHoleID:
                    previousHole.id,
                toHoleID:
                    currentHole.id
            )
        }

        let transition =
            HoleTransition.confirmed(
                fromHoleID:
                    previousHole.id,
                toHoleID:
                    currentHole.id
            )

        resetPendingTransition()

        return transition
    }

    public mutating func reset() {
        resetPendingTransition()
    }

    private mutating func resetPendingTransition() {
        pendingDestinationHoleID =
            nil

        consecutiveDestinationCount =
            0
    }
}
