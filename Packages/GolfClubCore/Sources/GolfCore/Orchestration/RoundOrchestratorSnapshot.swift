//
//  RoundOrchestratorSnapshot.swift
//  GolfCore
//
//  Created by Dragon Development on 11/07/2026.
//

import Foundation

public struct RoundOrchestratorSnapshot:
    Codable,
    Equatable,
    Sendable {

    public var roundID: RoundID
    public var state: OrchestratorState

    public var candidateSwing: CandidateSwing?
    public var lastLocation: LocationObservation?

    public var capturedAt: Date
    public var localRevision: Int

    public init(
        roundID: RoundID,
        state: OrchestratorState,
        candidateSwing: CandidateSwing? = nil,
        lastLocation: LocationObservation? = nil,
        capturedAt: Date = Date(),
        localRevision: Int = 1
    ) {
        self.roundID = roundID
        self.state = state
        self.candidateSwing = candidateSwing
        self.lastLocation = lastLocation
        self.capturedAt = capturedAt
        self.localRevision = max(1, localRevision)
    }

    public var hasUnresolvedCandidateSwing: Bool {
        candidateSwing != nil &&
        candidateSwing?.classification == .uncertain
    }
}
