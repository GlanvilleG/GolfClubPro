//
//  RoundOrchestratorEvent.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum RoundOrchestratorEvent:
    Codable,
    Equatable,
    Sendable {

    case locationUpdated(LocationObservation)

    case golfClubDetected(
        GolfClubID,
        confidence: Double
    )

    case roundConfirmed
    case roundRejected

    case holeDetected(
        HoleID,
        confidence: Double
    )

    case holeConfirmed(HoleID)
    case teeSetSelected(TeeSetID)

    case clubSelected(ClubID)
    case clubChanged(ClubID)

    case addressDetected
    case swingDetected(SwingObservation)
    case impactDetected(ImpactObservation)
    case golferDepartedShotOrigin
    case candidateSwingTimeout

    case shotConfirmedByGolfer
    case practiceSwingConfirmedByGolfer
    case candidateSwingRejected

    case voiceFeedbackReceived(String)

    case lieConfirmed(PlayableLie)
    case lieCorrected(PlayableLie)

    case puttsRecorded(Int)
    case holeCompletionRequested
    case roundCompletionRequested

    case connectivityChanged(Bool)
    case applicationRestored
}
