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

    public var pendingGolfClubID: GolfClubID?
    public var pendingHoleID: HoleID?
    
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
        localRevision: Int = 1,
        pendingGolfClubID: GolfClubID? = nil,
        pendingHoleID: HoleID? = nil
    ) {
        self.roundID = roundID
        self.state = state
        self.candidateSwing = candidateSwing
        self.lastLocation = lastLocation
        self.capturedAt = capturedAt
        self.localRevision = max(1, localRevision)
        self.pendingGolfClubID = pendingGolfClubID
        self.pendingHoleID = pendingHoleID
    }

    public var hasUnresolvedCandidateSwing: Bool {
        candidateSwing != nil &&
        candidateSwing?.classification == .uncertain
    }
}
