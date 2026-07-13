//
//  BundledGolfClubCatalogueLoaderTests.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation
import GolfCore
import XCTest
@testable import GolfClubPro

final class BundledGolfClubCatalogueLoaderTests:
    XCTestCase {

    func testLoadsVersionOneDocument()
        throws {

        let bundle =
            try makeTestBundle(
                json:
                    """
                    {
                      "schemaVersion": 1,
                      "golfClubs": []
                    }
                    """
            )

        let loader =
            BundledGolfClubCatalogueLoader(
                bundle: bundle,
                resourceName:
                    "GolfClubCatalogue"
            )

        let document =
            try loader.load()

        XCTAssertEqual(
            document.schemaVersion,
            1
        )

        XCTAssertTrue(
            document.golfClubs.isEmpty
        )
    }

    func testRejectsUnsupportedSchemaVersion()
        throws {

        let bundle =
            try makeTestBundle(
                json:
                    """
                    {
                      "schemaVersion": 99,
                      "golfClubs": []
                    }
                    """
            )

        let loader =
            BundledGolfClubCatalogueLoader(
                bundle: bundle,
                resourceName:
                    "GolfClubCatalogue"
            )

        XCTAssertThrowsError(
            try loader.load()
        ) { error in
            XCTAssertEqual(
                error as?
                    BundledGolfClubCatalogueLoaderError,
                .unsupportedSchemaVersion(99)
            )
        }
    }

    func testMissingResourceThrowsError() {
        let loader =
            BundledGolfClubCatalogueLoader(
                bundle: Bundle(
                    for: Self.self
                ),
                resourceName:
                    "MissingCatalogue"
            )

        XCTAssertThrowsError(
            try loader.load()
        )
    }

    private func makeTestBundle(
        json: String
    ) throws -> Bundle {

        let directory =
            FileManager.default
                .temporaryDirectory
                .appendingPathComponent(
                    UUID().uuidString
                )

        try FileManager.default
            .createDirectory(
                at: directory,
                withIntermediateDirectories:
                    true
            )

        let bundleURL =
            directory.appendingPathComponent(
                "TestCatalogue.bundle"
            )

        try FileManager.default
            .createDirectory(
                at: bundleURL,
                withIntermediateDirectories:
                    true
            )

        let resourceURL =
            bundleURL.appendingPathComponent(
                "GolfClubCatalogue.json"
            )

        try Data(json.utf8).write(
            to: resourceURL
        )

        guard let bundle =
                Bundle(url: bundleURL)
        else {
            throw TestBundleError
                .unableToCreateBundle
        }

        return bundle
    }

    private enum TestBundleError:
        Error {

        case unableToCreateBundle
    }
}
