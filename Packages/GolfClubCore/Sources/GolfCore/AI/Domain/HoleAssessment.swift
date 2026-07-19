//
//  HoleAssessment.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct HoleAssessment:
    Codable,
    Equatable,
    Sendable {

    public let areas:
        [HoleAreaAssessment]

    public let overallRisk:
        HazardRisk

    public init(
        areas: [HoleAreaAssessment],
        overallRisk: HazardRisk
    ) {
        self.areas =
            areas

        self.overallRisk =
            overallRisk
    }

    public var hazardAssessments:
        [HoleAreaAssessment] {

        areas.filter {
            $0.area.type.isHazard
        }
    }

    public var rulesReliefAssessments:
        [HoleAreaAssessment] {

        areas.filter {
            $0.area.type.requiresRulesRelief
        }
    }

    public var sensitiveAreaAssessments:
        [HoleAreaAssessment] {

        areas.filter {
            $0.area.type.isSensitiveArea
        }
    }
}
