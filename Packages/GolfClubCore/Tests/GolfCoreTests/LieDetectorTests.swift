//
//  LieDetectorTests.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import XCTest
@testable import GolfCore

final class LieDetectorTests: XCTestCase {

    private let detector = LieDetector()

    func testDetectsFairwayInsidePolygon() {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .fairway,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 0, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 0)
                    ]
                )
            ]
        )

        let result = detector.detectLie(
            at: GeoCoordinate(latitude: 5, longitude: 5),
            using: geometry
        )

        XCTAssertEqual(result.courseArea, .fairway)
        XCTAssertEqual(result.playableLie, .fairway)
        XCTAssertEqual(result.source, .inferredFromCourseGeometry)
        XCTAssertEqual(result.confidence, 0.75)
    }

    func testReturnsUnknownOutsidePolygon() {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .fairway,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 0, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 0)
                    ]
                )
            ]
        )

        let result = detector.detectLie(
            at: GeoCoordinate(latitude: 20, longitude: 20),
            using: geometry
        )

        XCTAssertEqual(result.courseArea, .unknown)
        XCTAssertEqual(result.playableLie, .unknown)
        XCTAssertEqual(result.source, .unknown)
    }

    func testBunkerMapsToGreensideBunker() {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .bunker,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 0, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 10),
                        GeoCoordinate(latitude: 10, longitude: 0)
                    ]
                )
            ]
        )

        let result = detector.detectLie(
            at: GeoCoordinate(latitude: 5, longitude: 5),
            using: geometry
        )

        XCTAssertEqual(result.courseArea, .bunker)
        XCTAssertEqual(result.playableLie, .greensideBunker)
    }

    func testIgnoresInvalidPolygon() {
        let geometry = CourseGeometry(
            areas: [
                CourseArea(
                    type: .fairway,
                    boundary: [
                        GeoCoordinate(latitude: 0, longitude: 0),
                        GeoCoordinate(latitude: 1, longitude: 1)
                    ]
                )
            ]
        )

        let result = detector.detectLie(
            at: GeoCoordinate(latitude: 0.5, longitude: 0.5),
            using: geometry
        )

        XCTAssertEqual(result.courseArea, .unknown)
        XCTAssertEqual(result.playableLie, .unknown)
    }
    func testLieFarFromBoundaryDoesNotRequireConfirmation() {
        let result = LieDetectionResult(
            courseArea: .fairway,
            playableLie: .fairway,
            source: .inferredFromCourseGeometry,
            confidence: 0.90,
            distanceToBoundaryMeters: 20
        )

        let requirement =
            detector.confirmationRequirement(for: result)

        XCTAssertEqual(requirement, .notRequired)
    }
    func testLieNearBoundaryRecommendsConfirmation() {
        let result = LieDetectionResult(
            courseArea: .fairway,
            playableLie: .fairway,
            source: .inferredFromCourseGeometry,
            confidence: 0.82,
            distanceToBoundaryMeters: 2
        )

        let requirement =
            detector.confirmationRequirement(for: result)

        XCTAssertTrue(requirement.shouldPromptGolfer)

        guard case let .recommended(lie, reasons) = requirement else {
            return XCTFail("Expected recommended confirmation")
        }

        XCTAssertEqual(lie, .fairway)
        XCTAssertTrue(reasons.contains(.nearBoundary))
    }
    func testUnknownAreaRequiresConfirmation() {
        let result = LieDetectionResult(
            courseArea: .unknown,
            playableLie: .unknown,
            source: .unknown,
            confidence: 0,
            distanceToBoundaryMeters: nil
        )

        let requirement =
            detector.confirmationRequirement(for: result)

        guard case let .required(_, reasons) = requirement else {
            return XCTFail("Expected required confirmation")
        }

        XCTAssertTrue(reasons.contains(.unknownArea))
    }
    func testWaterNearBoundaryRequiresConfirmation() {
        let result = LieDetectionResult(
            courseArea: .water,
            playableLie: .water,
            source: .inferredFromCourseGeometry,
            confidence: 0.55,
            distanceToBoundaryMeters: 1.5
        )

        let requirement =
            detector.confirmationRequirement(for: result)

        guard case let .required(_, reasons) = requirement else {
            return XCTFail("Expected required confirmation")
        }

        XCTAssertTrue(reasons.contains(.sensitiveArea))
        XCTAssertTrue(reasons.contains(.nearBoundary))
    }
}
