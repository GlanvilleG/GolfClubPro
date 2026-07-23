//
//  PerformanceEvidenceBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 23/07/2026.
//

import Foundation

internal struct PerformanceEvidenceBuilder: Sendable {
    internal init() {}

    internal func clubEvidence(
        clubID: ClubID,
        medianCarryMeters: Double?,
        sampleSize: Int,
        carryConsistency: Double?,
        missDirection: MissDirection?
    ) -> [String] {
        var items: [String] = []
        items.append("club=\(clubID)")
        items.append("samples=\(sampleSize)")
        if let median = medianCarryMeters {
            items.append("medianCarry=\(Int(median.rounded()))m")
        }
        if let consistency = carryConsistency {
            let pct = Int((max(0, min(1, consistency)) * 100).rounded())
            items.append("carryConsistency=\(pct)%")
        }
        if let miss = missDirection {
            items.append("missDirection=\(miss.rawValue)")
        }
        return items
    }
}
