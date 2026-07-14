//
//  SpatialRiskEvaluatorTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
import XCTest
@testable import GolfCore

final class SpatialRiskEvaluatorTests:
    XCTestCase {

    private let evaluator =
        SpatialRiskEvaluator()

    func testClearMappedAreaHasNoPenalty() {
        let result =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        insideMappedArea:
                            true
                    ),
                spatialContext:
                    makeSpatialContext(
                        requiresConfirmation:
                            false
                    )
            )

        XCTAssertEqual(
            result.penalty,
            0,
            accuracy: 0.0001
        )

        XCTAssertTrue(
            result.reasons.isEmpty
        )
    }

    func testUnknownAreaAddsPositionUncertaintyReason() {
        let result =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        insideMappedArea:
                            false
                    ),
                spatialContext:
                    makeSpatialContext(
                        requiresConfirmation:
                            true
                    )
            )

        XCTAssertTrue(
            result.reasons.contains(
                .uncertainPosition
            )
        )

        XCTAssertFalse(
            result.reasons.contains(
                .lowConfidence
            )
        )
    }
    func testRequiresConfirmationAddsLowConfidenceReason()
    {
        let result =
        evaluator.evaluate(
            analysis:
                SpatialAnalysis(
                    insideMappedArea: true
                ),
            spatialContext:
                makeSpatialContext(
                    requiresConfirmation: true
                )
        )
        
        XCTAssertTrue(
            result.reasons.contains(
                .lowConfidence
            )
        )
        
        XCTAssertFalse(
            result.reasons.contains(
                .uncertainPosition
            )
        )
    }
    
    func testNearbyBunkerAddsHazardPenalty() {
        let bunker =
            GeometryTestFactory.makeSquareArea(
                type: .bunker
            )

        let result =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        nearestHazard:
                            bunker,
                        nearestHazardDistanceMeters:
                            4,
                        insideMappedArea:
                            true
                    ),
                spatialContext:
                    makeSpatialContext()
            )

        XCTAssertGreaterThan(
            result.penalty,
            0
        )

        XCTAssertTrue(
            result.reasons.contains(
                .hazardAvoidance
            )
        )
    }

    func testNearbyPenaltyAreaPenalisesMoreThanBunker() {
        let bunkerResult =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        nearestHazard:
                            GeometryTestFactory
                                .makeSquareArea(
                                    type: .bunker
                                ),
                        nearestHazardDistanceMeters:
                            4,
                        insideMappedArea:
                            true
                    ),
                spatialContext:
                    makeSpatialContext()
            )

        let penaltyAreaResult =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        nearestHazard:
                            GeometryTestFactory
                                .makeSquareArea(
                                    type:
                                        .penaltyArea
                                ),
                        nearestHazardDistanceMeters:
                            4,
                        insideMappedArea:
                            true
                    ),
                spatialContext:
                    makeSpatialContext()
            )

        XCTAssertGreaterThan(
            penaltyAreaResult.penalty,
            bunkerResult.penalty
        )
    }

    func testNearBoundaryAddsBoundaryRiskReason() {
        let result =
            evaluator.evaluate(
                analysis:
                    SpatialAnalysis(
                        nearestBoundaryDistanceMeters:
                            3,
                        insideMappedArea:
                            true
                    ),
                spatialContext:
                    makeSpatialContext()
            )

        XCTAssertTrue(
            result.reasons.contains(
                .boundaryRisk
            )
        )
    }

    private func makeSpatialContext(
        requiresConfirmation:
            Bool = false
    ) -> RoundSpatialContext {

        RoundSpatialContext(
            observedAt:
                Date(
                    timeIntervalSince1970:
                        1_700_000_000
                ),
            golferPosition:
                GeometryTestFactory
                    .defaultCentre,
            hole:
                nil,
            holeLocationConfidence:
                .certain,
            requiresConfirmation:
                requiresConfirmation
        )
    }
}
