//
//  RoundOrchestratorSnapshotRecord.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//
import Foundation
import SwiftData

@Model
final class RoundOrchestratorSnapshotRecord {

    @Attribute(.unique)
    var roundID: UUID

    var stateRawValue: String
    var capturedAt: Date
    var localRevision: Int
    var encodedSnapshot: Data

    init(
        roundID: UUID,
        stateRawValue: String,
        capturedAt: Date,
        localRevision: Int,
        encodedSnapshot: Data
    ) {
        self.roundID = roundID
        self.stateRawValue = stateRawValue
        self.capturedAt = capturedAt
        self.localRevision = localRevision
        self.encodedSnapshot = encodedSnapshot
    }
}
