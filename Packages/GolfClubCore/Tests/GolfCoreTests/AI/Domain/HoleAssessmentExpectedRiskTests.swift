//
//  HoleAssessmentExpectedRiskTests.swift
//  GolfClubCore
//
//  Created by Dragon Development on 20/07/2026.
//
import Testing
@testable import GolfCore

@Suite
struct HoleAssessmentExpectedRiskTests {
    
    @Test
    func noAdverseAreasProducesZeroExpectedRisk() {
        
        let assessment =
        HoleAssessment(
            areaAssessments: [],
            overallRisk: .negligible
        )
        
        #expect(
            assessment.expectedRisk ==
            0
        )
    }
    
    @Test
    func singleAdverseAreaUsesItsProbability() {
        
        let assessment =
        HoleAssessment(
            areaAssessments: [
                TestHoleFactory.areaAssessment(
                    type: .water,
                    probability: 0.25
                )
            ],
            overallRisk: .moderate
        )
        
        #expect(
            abs(
                assessment.expectedRisk -
                0.25
            ) < 0.000_001
        )
    }
    
    @Test
    func multipleAdverseAreasCombineProbability() {
        
        let assessment =
        HoleAssessment(
            areaAssessments: [
                TestHoleFactory.areaAssessment(
                    type: .water,
                    probability: 0.20
                ),
                TestHoleFactory.areaAssessment(
                    type: .bunker,
                    probability: 0.10
                )
            ],
            overallRisk: .moderate
        )
        
        #expect(
            abs(
                assessment.expectedRisk -
                0.28
            ) < 0.000_001
        )
    }
    
    @Test
    func nonAdverseAreasDoNotContributeToExpectedRisk() {
        
        let assessment =
        HoleAssessment(
            areaAssessments: [
                TestHoleFactory.areaAssessment(
                    type: .fairway,
                    probability: 0.70
                ),
                TestHoleFactory.areaAssessment(
                    type: .green,
                    probability: 0.20
                )
            ],
            overallRisk: .negligible
        )
        
        #expect(
            assessment.expectedRisk ==
            0
        )
    }
    
    @Test
    func expectedRiskRemainsWithinNormalizedRange() {
        
        let assessment =
        HoleAssessment(
            areaAssessments: [
                TestHoleFactory.areaAssessment(
                    type: .water,
                    probability: 1.5
                ),
                TestHoleFactory.areaAssessment(
                    type: .outOfBounds,
                    probability: -0.5
                )
            ],
            overallRisk: .severe
        )
        
        #expect(
            assessment.expectedRisk >=
            0
        )
        
        #expect(
            assessment.expectedRisk <=
            1
        )
    }
    
    
}
