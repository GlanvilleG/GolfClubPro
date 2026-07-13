//
//  RecommendationContextTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//

import XCTest
@testable import GolfCore

final class RecommendationContextTests:
    XCTestCase {

    func testStoresRecommendationInputs() {
        let shotContext =
            makeShotContext()

        let spatialContext =
            makeSpatialContext()

        let spatialAnalysis =
            SpatialAnalysis(
                insideMappedArea: true
            )

        let context =
            RecommendationContext(
                shotContext: shotContext,
                spatialContext: spatialContext,
                spatialAnalysis: spatialAnalysis
            )

        XCTAssertEqual(
            context.spatialContext,
            spatialContext
        )

        XCTAssertEqual(
            context.spatialAnalysis,
            spatialAnalysis
        )
    }

    private func makeSpatialContext()
        -> RoundSpatialContext {

        RoundSpatialContext(
            observedAt:
                Date(
                    timeIntervalSince1970:
                        1_700_000_000
                ),
            golferPosition:
                GeoCoordinate(
                    latitude: -39.9300,
                    longitude: 175.0500
                ),
            hole: nil,
            holeLocationConfidence:
                .none,
            requiresConfirmation:
                true
        )
    }

    private func makeShotContext()
        -> ShotContext {

        // Reuse the established test fixture or factory
        // currently used by RecommendationEngineTests.
        fatalError(
            "Replace with the existing ShotContext test factory."
        )
    }
}
