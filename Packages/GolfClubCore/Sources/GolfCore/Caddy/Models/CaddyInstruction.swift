//
//  CaddyInstruction.swift
//  GolfClubCore
//
//  Created by Dragon Development on 16/07/2026.
//
//

import Foundation


public struct CaddyInstruction:
    Codable,
    Equatable,
    Sendable {


    public let clubID:
        ClubID


    public let displayText:
        String


    public let spokenText:
        String


    public let targetAdjustmentMeters:
        Double


    public let confidence:
        Double


    public let priority:
        InstructionPriority



    public init(
        clubID:
            ClubID,
        displayText:
            String,
        spokenText:
            String,
        targetAdjustmentMeters:
            Double,
        confidence:
            Double,
        priority:
            InstructionPriority
    ) {

        self.clubID =
            clubID

        self.displayText =
            displayText

        self.spokenText =
            spokenText

        self.targetAdjustmentMeters =
            targetAdjustmentMeters

        self.confidence =
            min(
                1,
                max(
                    0,
                    confidence
                )
            )

        self.priority =
            priority
    }
}

