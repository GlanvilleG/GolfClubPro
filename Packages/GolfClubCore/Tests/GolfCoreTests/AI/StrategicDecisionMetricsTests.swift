//
//  StrategicDecisionMetricsTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Testing
@testable import GolfCore

@Suite
struct StrategicDecisionMetricsTests {

    @Test
    func storesDecisionMetrics() {

        let metrics =
            StrategicDecisionMetrics(
                plannedCarryMeters: 165,
                optionScore: 2.75,
                decisionConfidence: .full
            )

        #expect(
            metrics.plannedCarryMeters ==
                165
        )

        #expect(
            metrics.optionScore ==
                2.75
        )

        #expect(
            metrics.decisionConfidence ==
                .full
        )
    }

    @Test
    func plannedCarryCannotBeNegative() {

        let metrics =
            StrategicDecisionMetrics(
                plannedCarryMeters: -20,
                optionScore: 3.5,
                decisionConfidence: .full
            )

        #expect(
            metrics.plannedCarryMeters ==
                0
        )

        #expect(
            metrics.optionScore ==
                3.5
        )
    }

    @Test
    func optionScoreIsPreserved() {

        let metrics =
            StrategicDecisionMetrics(
                plannedCarryMeters: 150,
                optionScore: -1.25,
                decisionConfidence: .full
            )

        #expect(
            metrics.optionScore ==
                -1.25
        )
    }

    @Test
    func unavailableMetricsContainNeutralDefaults() {

        let metrics =
            StrategicDecisionMetrics.unavailable

        #expect(
            metrics.plannedCarryMeters ==
                0
        )

        #expect(
            metrics.optionScore ==
                0
        )

        #expect(
            metrics.decisionConfidence ==
                .none
        )
    }
}
