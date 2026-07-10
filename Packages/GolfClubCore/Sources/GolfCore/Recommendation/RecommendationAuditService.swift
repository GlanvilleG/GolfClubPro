//
//  RecommendationAuditService.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct RecommendationAuditService:
    Sendable {

    public init() {}

    public func recordAccepted(
        clubID: ClubID,
        for auditRecord:
            RecommendationAuditRecord
    ) -> RecommendationAuditRecord {
        var updated = auditRecord
        updated.golferDecision = .accepted
        updated.selectedClubID = clubID
        return updated
    }

    public func recordRejected(
        for auditRecord:
            RecommendationAuditRecord
    ) -> RecommendationAuditRecord {
        var updated = auditRecord
        updated.golferDecision = .rejected
        updated.selectedClubID = nil
        return updated
    }

    public func recordModified(
        selectedClubID: ClubID,
        for auditRecord:
            RecommendationAuditRecord
    ) -> RecommendationAuditRecord {
        var updated = auditRecord
        updated.golferDecision = .modified
        updated.selectedClubID =
            selectedClubID
        return updated
    }

    public func linkShot(
        _ shotID: ShotID,
        to auditRecord:
            RecommendationAuditRecord
    ) -> RecommendationAuditRecord {
        var updated = auditRecord
        updated.actualShotID = shotID
        return updated
    }
}
