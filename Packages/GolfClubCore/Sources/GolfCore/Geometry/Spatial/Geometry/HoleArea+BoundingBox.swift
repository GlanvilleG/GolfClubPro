//
//  HoleArea+BoundingBox.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public extension HoleArea {

    var boundingBox: GeoBoundingBox? {
        GeoBoundingBox(
            coordinates:
                boundary
        )
    }
}
