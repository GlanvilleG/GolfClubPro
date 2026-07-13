//
//  Create GolfClubCatalogueDecoder.swift
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//

//
//  GolfClubCatalogueDecoder.swift
//  GolfClubPro
//
//  Created by Dragon Development on 14/07/2026.
//

import Foundation
import GolfCore

struct GolfClubCatalogueDecoder {

    func decode(
        _ data: Data
    ) throws -> GolfClubCatalogueDocument {

        let document: GolfClubCatalogueDocument

        do {
            document = try JSONDecoder().decode(
                GolfClubCatalogueDocument.self,
                from: data
            )

        } catch let DecodingError.keyNotFound(
            key,
            context
        ) {

            print(
                """
                Catalogue decoding failed: missing key '\(key.stringValue)'
                Path: \(context.codingPath.map(\.stringValue).joined(separator: "."))
                Description: \(context.debugDescription)
                """
            )

            throw BundledGolfClubCatalogueLoaderError
                .decodingFailed

        } catch let DecodingError.typeMismatch(
            type,
            context
        ) {

            print(
                """
                Catalogue decoding failed: type mismatch for \(type)
                Path: \(context.codingPath.map(\.stringValue).joined(separator: "."))
                Description: \(context.debugDescription)
                """
            )

            throw BundledGolfClubCatalogueLoaderError
                .decodingFailed

        } catch let DecodingError.valueNotFound(
            type,
            context
        ) {

            print(
                """
                Catalogue decoding failed: value not found for \(type)
                Path: \(context.codingPath.map(\.stringValue).joined(separator: "."))
                Description: \(context.debugDescription)
                """
            )

            throw BundledGolfClubCatalogueLoaderError
                .decodingFailed

        } catch let DecodingError.dataCorrupted(
            context
        ) {

            print(
                """
                Catalogue decoding failed: corrupted data
                Path: \(context.codingPath.map(\.stringValue).joined(separator: "."))
                Description: \(context.debugDescription)
                """
            )

            throw BundledGolfClubCatalogueLoaderError
                .decodingFailed

        } catch {

            print(
                "Catalogue decoding failed: \(error)"
            )

            throw BundledGolfClubCatalogueLoaderError
                .decodingFailed
        }

        guard document.schemaVersion == 1 else {

            throw BundledGolfClubCatalogueLoaderError
                .unsupportedSchemaVersion(
                    document.schemaVersion
                )
        }

        return document
    }
}
