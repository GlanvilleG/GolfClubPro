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
}
