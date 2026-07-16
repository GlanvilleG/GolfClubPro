//
//  CaddyExplanation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//

import Foundation


public struct CaddyExplanation:
    Codable,
    Equatable,
    Sendable {


    public let summary:
        String


    public let items:
        [ExplanationItem]


    public let confidence:
        Double


    public init(
        summary:
            String,
        items:
            [ExplanationItem],
        confidence:
            Double
    ) {

        self.summary =
            summary

        self.items =
            items

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )
    }
}
