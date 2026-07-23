RecommendationPipeline — Output Consumption Map

This document summarizes where each stage’s output in RecommendationPipeline.execute(context:) is consumed, complementing the execution-order review.

Pipeline Diagram
[Start execute(context)]
  |
  v
[1. Validate Inputs]
  |
  v
[2. StrategicOptionEngine.determineBestOption]
  |--> strategicOption
  |
  v
[3. DispersionEngine.calculate]
  |--> shotDispersion
  |
  v
[4. RiskRewardAnalysisEngine.analyse]   (result not used later)
  |--> riskRewardAnalysis
  |
  v
[5. BearingCalculator.bearingDegrees]
  |--> shotBearingDegrees
  |
  v
[6. HoleAreaAssessmentEngine.assess]
  |--> holeAssessment
  |
  v
[7. Build RecommendationDecisionContext]
  |--> decisionContext (strategicOption, shotDispersion, holeAssessment)
  |
  v
[8. selectedClubDistance(...)]
  |--> clubDistanceMeters
  |
  v
[9. AdaptiveCoachingEngine.adjustTarget]
  |--> adaptiveAdjustment
  |
  v
[10. WeatherAdjustmentEngine.calculate]
  |--> weatherAdjustment?
  |
  v
[11. CaddyRecommendationEngine.create]
  |--> recommendation
  |
  v
[12. Return RecommendationPipelineResult]

Where Each Stage’s Output Is Consumed

• Stage 2 — StrategicOption (output: strategicOption)
   • Consumed by:
      • Stage 3 (DispersionEngine.calculate uses clubID and target)
      • Stage 5 (BearingCalculator uses target)
      • Stage 7 (Decision context includes strategicOption)
      • Stage 8 (selectedClubDistance uses clubID and target)
      • Stage 9 (AdaptiveCoachingEngine.adjustTarget uses plannedTarget and clubID)
      • Stage 11 (CaddyRecommendationEngine.create uses option)

• Stage 3 — ShotDispersionModel (output: shotDispersion)
   • Consumed by:
      • Stage 6 (HoleAreaAssessmentEngine.assess uses shotDispersion)
      • Stage 7 (Decision context includes shotDispersion)

• Stage 4 — RiskRewardAnalysis (output: riskRewardAnalysis)
   • Consumed by:
      • Currently not consumed by any subsequent stage in the shown code path.

• Stage 5 — Shot Bearing Degrees (output: shotBearingDegrees)
   • Consumed by:
      • Stage 6 (HoleAreaAssessmentEngine.assess uses bearing for dispersion rotation)
      • Stage 9 (AdaptiveCoachingEngine.adjustTarget uses bearingDegrees)
      • Stage 10 (WeatherAdjustmentEngine.calculate uses shotBearingDegrees)

• Stage 6 — Hole Assessment (output: holeAssessment)
   • Consumed by:
      • Stage 7 (Decision context includes holeAssessment)

• Stage 7 — RecommendationDecisionContext (output: decisionContext)
   • Consumed by:
      • Stage 8 (uses decisionContext.strategicOption for clubID and target)

• Stage 8 — Club Distance Meters (output: clubDistanceMeters)
   • Consumed by:
      • Stage 10 (WeatherAdjustmentEngine.calculate uses clubDistanceMeters)

• Stage 9 — Adaptive Target Adjustment (output: adaptiveAdjustment)
   • Consumed by:
      • Stage 11 (CaddyRecommendationEngine.create uses adaptiveAdjustment)
      • Stage 12 (included in RecommendationPipelineResult)

• Stage 10 — Weather Adjustment (output: weatherAdjustment?)
   • Consumed by:
      • Stage 11 (CaddyRecommendationEngine.create uses weatherAdjustment)
      • Stage 12 (included in RecommendationPipelineResult)

• Stage 11 — Final Recommendation (output: recommendation)
   • Consumed by:
      • Stage 12 (included in RecommendationPipelineResult)
      • Downstream consumers (UI, persistence, analytics)

• Stage 12 — RecommendationPipelineResult (output: result)
   • Consumed by:
      • External callers of execute(context:) (e.g., application layer for presentation, storage, or auditing)

Notes

• riskRewardAnalysis is computed in Stage 4 but is not currently used downstream in the shown code. This may be intentional for future integration (e.g., feeding explanations, confidence scoring, or sorting).
