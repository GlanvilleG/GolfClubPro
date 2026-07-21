//
//  StrategicDecisionMetrics.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
public struct StrategicDecisionMetrics:
    Codable,
    Equatable,
    Sendable {

    /// Intended carry required to reach the target.
    public let plannedCarryMeters: Double

    /// Internal score used by the strategic engine when
    /// selecting this option.
    public let optionScore: Double

    /// Confidence in the strategic decision.
    public let decisionConfidence: DecisionConfidence

    public init(
        plannedCarryMeters: Double,
        optionScore: Double,
        decisionConfidence: DecisionConfidence
    ) {

        self.plannedCarryMeters =
            max(plannedCarryMeters, 0)

        self.optionScore =
            optionScore

        self.decisionConfidence =
            decisionConfidence
    }

    public static let unavailable =
        StrategicDecisionMetrics(
            plannedCarryMeters: 0,
            optionScore: 0,
            decisionConfidence: .none
        )
    }
