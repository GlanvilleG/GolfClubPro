//
//  ActiveRoundSnapshotRecord.swift
//  GolfClubPro
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation
import SwiftData

@Model
final class ActiveRoundSnapshotRecord {

    @Attribute(.unique)
    var roundID: UUID

    var capturedAt: Date
    var roundState: String
    var localRevision: Int
    var encodedSnapshot: Data

    init(
        roundID: UUID,
        capturedAt: Date,
        roundState: String,
        localRevision: Int,
        encodedSnapshot: Data
    ) {
        self.roundID = roundID
        self.capturedAt = capturedAt
        self.roundState = roundState
        self.localRevision = localRevision
        self.encodedSnapshot = encodedSnapshot
    }
}
