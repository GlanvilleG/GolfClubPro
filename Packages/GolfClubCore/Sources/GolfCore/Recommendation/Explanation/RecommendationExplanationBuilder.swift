//
//  RecommendationExplanationBuilder.swift
//  GolfClubCore
//
//  Created by Dragon Development on 15/07/2026.
//

import Foundation

public struct RecommendationExplanationBuilder:
    Sendable {

    public init() {}

    public func build(
        decision: RecommendationDecision,
        context: ShotContext,
        spatialRisk: SpatialRiskAssessment
    ) -> RecommendationExplanation {

        RecommendationExplanation(
            summary:
                makeSummary(
                    decision: decision,
                    context: context
                ),
            primaryReasons:
                makePrimaryReasons(
                    decision: decision
                ),
            warnings:
                makeWarnings(
                    spatialRisk: spatialRisk
                ),
            confidenceStatement:
                makeConfidenceStatement(
                    decision: decision
                ),
            courseManagementAdvice:
                makeCourseManagementAdvice(
                    decision: decision
                ),
            nextShotFocus:
                makeNextShotFocus(
                    decision: decision,
                    context: context
                )
        )
    }

    private func makeSummary(
        decision: RecommendationDecision,
        context: ShotContext
    ) -> String {

        guard let preferred =
                decision.preferredClub
        else {
            return
                "No suitable club recommendation is available."
        }

        let clubName =
            context.availableClubs
                .first {
                    $0.id == preferred.clubID
                }?
                .name ??
            "Selected club"

        let targetDistance =
            Int(
                decision
                    .shotPlan
                    .targetDistanceMeters
                    .rounded()
            )

        let adjustedCarry =
            Int(
                preferred
                    .adjustedCarryMeters
                    .rounded()
            )

        return
            "\(clubName) is recommended for the \(targetDistance)-metre target, with an adjusted carry of \(adjustedCarry) metres."
    }

    private func makePrimaryReasons(
        decision: RecommendationDecision
    ) -> [ExplanationItem] {

        guard let preferred =
                decision.preferredClub
        else {
            return []
        }

        return preferred.reasons.map {
            ExplanationItem(
                title: $0,
                detail: nil,
                severity: .information
            )
        }
    }

    private func makeWarnings(
        spatialRisk: SpatialRiskAssessment
    ) -> [ExplanationItem] {

        spatialRisk.reasons.map {
            warningItem(
                for: $0
            )
        }
    }

    private func makeConfidenceStatement(
        decision: RecommendationDecision
    ) -> String? {

        guard let preferred =
                decision.preferredClub
        else {
            return nil
        }

        let percentage =
            Int(
                (
                    preferred.confidence *
                    100
                )
                .rounded()
            )

        return
            "Recommendation confidence is \(percentage) percent."
    }

    private func makeCourseManagementAdvice(
        decision: RecommendationDecision
    ) -> String? {

        let aimOffset =
            decision.aimOffsetDegrees

        let directionDescription: String

        if aimOffset < -0.5 {
            directionDescription =
                "Aim \(Int(abs(aimOffset).rounded())) degrees left of the planned target."
        } else if aimOffset > 0.5 {
            directionDescription =
                "Aim \(Int(aimOffset.rounded())) degrees right of the planned target."
        } else {
            directionDescription =
                "Aim directly at the planned target."
        }

        let rationale =
            decision
                .shotPlan
                .rationale

        guard !rationale.isEmpty else {
            return directionDescription
        }

        return
            "\(directionDescription) \(rationale)"
    }

    private func makeNextShotFocus(
        decision: RecommendationDecision,
        context: ShotContext
    ) -> String? {

        guard decision.preferredClub != nil else {
            return
                "Confirm the lie and target before selecting a club."
        }

        switch context.environment
            .weatherAvailability {

        case .live:
            if context.environment.wind != nil {
                return
                    "Allow for the live wind conditions before committing to the shot."
            }

            return
                "Commit to the selected target and maintain normal tempo."

        case .cached:
            return
                "Cached weather was used; confirm that conditions have not changed."

        case .stale:
            return
                "Weather information is stale; reassess the wind before playing."

        case .unavailable:
            return
                "Wind data is unavailable; verify conditions before committing."
        }
    }

    private func warningItem(
        for reason: RecommendationReason
    ) -> ExplanationItem {

        switch reason {

        case .uncertainPosition:
            return ExplanationItem(
                title:
                    "Position uncertain",
                detail:
                    "The golfer's position could not be confidently matched to mapped course geometry.",
                severity:
                    .caution
            )

        case .lowConfidence:
            return ExplanationItem(
                title:
                    "Confirmation recommended",
                detail:
                    "The current hole, lie or spatial context requires confirmation.",
                severity:
                    .advisory
            )

        case .hazardAvoidance:
            return ExplanationItem(
                title:
                    "Nearby hazard",
                detail:
                    "The recommendation accounts for a nearby bunker, water feature or penalty area.",
                severity:
                    .caution
            )

        case .boundaryRisk:
            return ExplanationItem(
                title:
                    "Near mapped boundary",
                detail:
                    "The golfer is close to the edge of a mapped course area.",
                severity:
                    .caution
            )

        case .routeSafety:
            return ExplanationItem(
                title:
                    "Route risk",
                detail:
                    "The planned shot route includes additional course-management risk.",
                severity:
                    .advisory
            )

        case .distanceFit:
            return ExplanationItem(
                title:
                    "Distance fit",
                detail:
                    "The selected club closely matches the required distance.",
                severity:
                    .information
            )

        case .lieSuitability:
            return ExplanationItem(
                title:
                    "Lie suitability",
                detail:
                    "The club is suitable for the golfer's current lie.",
                severity:
                    .information
            )

        case .recovery:
            return ExplanationItem(
                title:
                    "Recovery shot",
                detail:
                    "The recommendation prioritises returning the ball to a playable position.",
                severity:
                    .advisory
            )

        case .layup:
            return ExplanationItem(
                title:
                    "Lay-up recommended",
                detail:
                    "The recommendation favours positioning over maximum distance.",
                severity:
                    .advisory
            )

        case .aggressiveOption:
            return ExplanationItem(
                title:
                    "Aggressive option",
                detail:
                    "The selected strategy accepts additional risk for a potentially better outcome.",
                severity:
                    .advisory
            )

        case .conservativeOption:
            return ExplanationItem(
                title:
                    "Conservative option",
                detail:
                    "The selected strategy prioritises control and reduced risk.",
                severity:
                    .information
            )
        }
    }
}
