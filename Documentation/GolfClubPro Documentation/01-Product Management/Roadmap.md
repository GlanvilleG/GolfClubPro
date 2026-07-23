
Architecture Milestone 1
Architecture Refinement Sprint
GolfCore package boundary
GolfPlatformApple package
Offline round persistence foundation
Round Orchestrator foundation
Location detection foundation
Practice-swing handling
GolfClubLocationCoordinator - next

## Milestone: Explainability Snapshot Integration

- Status: In Progress (Sprint 10.7)
- Scope:
  - Stabilize RecommendationEvidenceSnapshot (schema v1)
  - Persist snapshot via audit (feature-flagged)
  - Map snapshot to structured and public evidence deterministically
- Next Steps:
  - Approve input boundary fields for EnvironmentalAssessment, StrategicOption, RiskRewardAnalysis, Hole/Hazard and Dispersion summaries
  - Wire snapshot creation at pipeline/engine boundary (no recalculation)
  - Integrate ExplainabilityEngine mapping to consume snapshot (preserving public RecommendationExplanation)
  - Expand tests for replay/regression and stale/missing evidence handling
- Outcome:
  - Deterministic replay and auditing
  - Richer explainability without recalculation
  - Ready for future narration and post-round review
