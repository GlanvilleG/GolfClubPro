//
//  RoundContextBuilderError.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//
import Foundation

public enum RoundContextBuilderError:
    Error,
    Equatable {

    case noActiveHole

    case multipleActiveHoles

    case holeNotFound(
        HoleID
    )

    case noTargetCoordinate
    case noGreenLocation(HoleID)
}
