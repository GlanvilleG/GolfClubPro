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
            environmentalConditions:
                makeEnvironmentalConditions(
                    context: context
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

    private func makeEnvironmentalConditions(context: ShotContext) -> [ExplanationItem] {
        var items: [ExplanationItem] = []

        // Weather availability/advisory messages
        if let snapshot = context.environment.weatherSnapshot {
            switch snapshot.availability {
            case .cached:
                items.append(
                    ExplanationItem(
                        title: "Cached weather",
                        detail: "Recent cached weather data was used.",
                        severity: .advisory
                    )
                )
            case .unavailable:
                items.append(
                    ExplanationItem(
                        title: "Weather unavailable",
                        detail: "No live weather information was available.",
                        severity: .advisory
                    )
                )
            case .stale:
                items.append(
                    ExplanationItem(
                        title: "Stale weather",
                        detail: "Weather data may be out of date.",
                        severity: .advisory
                    )
                )
            case .live:
                break
            }
        } else {
            // No snapshot provided at all – treat as unavailable for explanation purposes
            items.append(
                ExplanationItem(
                    title: "Weather unavailable",
                    detail: "No live weather information was available.",
                    severity: .advisory
                )
            )
        }
        
        if let assessment = context.environmentalAssessment {
            if let weather = assessment.weather {
                items.append(
                    ExplanationItem(
                        title: "Wind (standardized)",
                        detail: String(
                            format: "cross %.1f m/s, along %.1f m/s",
                            weather.crosswindMetersPerSecond,
                            weather.alongWindMetersPerSecond
                        ),
                        severity: .information
                    )
                )
            }
            if let terrain = assessment.terrain, terrain.elevationDeltaMeters != 0 {
                let direction = terrain.elevationDeltaMeters >= 0 ? "uphill" : "downhill"
                items.append(
                    ExplanationItem(
                        title: "Elevation",
                        detail: "\(Int(abs(terrain.elevationDeltaMeters).rounded())) metres \(direction)",
                        severity: .information
                    )
                )
            }

            if let course = assessment.course {
                if course.fairwayRollFactor != 1.0 {
                    let descriptor = course.fairwayRollFactor > 1.0 ? "firm fairways" : "soft/wet fairways"
                    items.append(
                        ExplanationItem(
                            title: "Course conditions",
                            detail: "\(descriptor), roll factor \(String(format: "%.2f", course.fairwayRollFactor))",
                            severity: .information
                        )
                    )
                }
                if course.preferredLies {
                    items.append(
                        ExplanationItem(
                            title: "Preferred lies",
                            detail: "Local rule in effect",
                            severity: .information
                        )
                    )
                }
            }
            let conf = assessment.confidence
            items.append(
                ExplanationItem(
                    title: "Environmental confidence",
                    detail: String(
                        format: "overall %.0f%%, gps %.0f%%, weather %.0f%%",
                        conf.overall * 100,
                        conf.gpsQuality * 100,
                        conf.weatherFreshness * 100
                    ),
                    severity: .information
                )
            )
        }

        if let wind = context.environment.wind {
            items.append(
                ExplanationItem(
                    title: "Wind adjustment",
                    detail: String(
                        format: "%.1f m/s from %.0f°",
                        wind.speedMetersPerSecond,
                        wind.directionDegrees
                    ),
                    severity: .information
                )
            )
        }

        if let elevation = context.environment.elevationChangeMeters {
            let direction = elevation >= 0 ? "uphill" : "downhill"
            items.append(
                ExplanationItem(
                    title: "Elevation adjustment",
                    detail: "\(Int(abs(elevation).rounded())) metres \(direction)",
                    severity: .information
                )
            )
        }

        if let temperature = context.environment.temperatureCelsius {
            items.append(
                ExplanationItem(
                    title: "Temperature",
                    detail: "\(Int(temperature.rounded())) °C",
                    severity: .information
                )
            )
        }

        return items
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

        switch decision.shotPlan.riskLevel {

        case .low:
            return
                "Commit to the selected target."

        case .moderate:
            return
                "Maintain good tempo and commit to the intended line."

        case .high:
            return
                "Prioritise solid contact before distance."

        case .extreme:
            return
                "Recovery to a safe position is the priority."
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
                
        case .playerPattern:
             return ExplanationItem(
                 title:
                     "Player pattern adjustment",
                 detail:
                     "The recommendation has been adjusted using the golfer's historical shot tendencies and performance profile.",
                 severity:
                    .information
                    )
            
        case .weatherInfluence:
            return ExplanationItem(
                title:
                    "Weather influence",
                detail:
                    "The recommendation has been adjusted for the current weather conditions.",
                severity:
                        .information
            )
        }
    }
}
