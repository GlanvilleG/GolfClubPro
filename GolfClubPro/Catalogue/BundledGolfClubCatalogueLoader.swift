//
//  BundledGolfClubCatalogueLoader.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//

import Foundation
import GolfCore

enum BundledGolfClubCatalogueLoaderError:
    Error,
    Equatable,
    Sendable {

    case resourceNotFound(String)
    case unableToReadResource
    case unsupportedSchemaVersion(Int)
    case decodingFailed
}

struct BundledGolfClubCatalogueLoader:
    Sendable {

    private let bundle: Bundle
    private let resourceName: String

    init(
        bundle: Bundle = .main,
        resourceName: String =
            "GolfClubCatalogue"
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load()
        throws -> GolfClubCatalogueDocument {

        guard let url = bundle.url(
            forResource: resourceName,
            withExtension: "json"
        ) else {

            throw BundledGolfClubCatalogueLoaderError
                .resourceNotFound(
                    "\(resourceName).json"
                )
        }

        let data: Data

        do {

            data = try Data(
                contentsOf: url
            )

        } catch {

            throw BundledGolfClubCatalogueLoaderError
                .unableToReadResource
        }

        let decoder =
            GolfClubCatalogueDecoder()

        return try decoder.decode(data)
    }

    func makeCatalogue()
        throws -> InMemoryGolfClubCatalogue {

        let document = try load()

        return InMemoryGolfClubCatalogue(
            clubs: document.golfClubs
        )
    }
}
