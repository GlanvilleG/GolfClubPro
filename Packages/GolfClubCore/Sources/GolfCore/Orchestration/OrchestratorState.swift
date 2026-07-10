//
//  OrchestratorState.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum OrchestratorState:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case idle
    case detectingGolfClub
    case awaitingRoundConfirmation
    case awaitingHoleDetection
    case awaitingHoleConfirmation
    case awaitingTeeConfirmation
    case awaitingClubSelection
    case clubSelected
    case preparingForShot
    case addressDetected
    case practiceSwingDetected
    case awaitingCommittedSwing
    case validatingCandidateSwing
    case awaitingShotConfirmation
    case shotConfirmed
    case awaitingShotFeedback
    case walkingToBall
    case awaitingLieConfirmation
    case putting
    case holePendingCompletion
    case recovering
}
