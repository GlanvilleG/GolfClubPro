//
//  CurrentRoundRecommendation.swift
//  GolfClubCore
//
//  Created by Dragon Development on 17/07/2026.
//
import Foundation

public struct CurrentRoundRecommendation: Sendable {

    public let recommendation: CaddyRecommendation

    public let explanation: CaddyExplanation

    public let instruction: CaddyInstruction

    public init(
        recommendation: CaddyRecommendation,
        explanation: CaddyExplanation,
        instruction: CaddyInstruction
    ) {
        self.recommendation = recommendation
        self.explanation = explanation
        self.instruction = instruction
    }
}
