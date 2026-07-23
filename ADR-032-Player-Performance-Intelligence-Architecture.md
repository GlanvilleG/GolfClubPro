# ADR-032 — Player Performance Intelligence Architecture
Status: Accepted
Date: 23 July 2026
Decision Owners: Lead Software Architect, Senior Swift Engineer
Supersedes: N/A
Related ADRs: ADR-018, ADR-019, ADR-022, ADR-023

# Context
Sprint 10.5 established the Environmental & Risk Intelligence as the canonical implementation and stabilized the Recommendation Pipeline as the single decision engine. Sprint 10.6 introduces a deterministic Player Performance Intelligence subsystem that derives structured, immutable player intelligence from historical rounds and shots without using Machine Learning. Recommendation engines must consume Player Intelligence rather than raw history. Intelligence is derived once, owned by a dedicated analytics layer, and integrated into RecommendationContext.

Constraints and principles:
- No ML; deterministic analytics only.
- Player Intelligence is immutable and produced by an engine.
- Recommendation engines must not compute statistics or inspect history directly.
- Confidence must be deterministic and explainable.
- Pipeline contracts remain the single integration points.

# Decision
Adopt a Player Performance Intelligence subsystem composed of:
- PlayerPerformanceEngine (deterministic analytics engine)
- PlayerIntelligence (immutable aggregate of intelligence)
- PlayerPerformanceProfile (player-wide metrics)
- ClubPerformanceProfile (per-club metrics)
- PerformanceTrend (trend snapshots and directions)
- DispersionProfile (lateral/longitudinal dispersion)
- DistanceProfile (carry/total distance statistics)
- ConfidenceProfile (explainable confidence factors)
- PerformanceSnapshot (time-stamped analysis outputs)
- (Optional) ShotOutcomeClassification model if existing data supports consistent classification

The subsystem derives intelligence from completed rounds and shots, persists results as immutable snapshots, and exposes them through the RecommendationContext so the Recommendation Pipeline can consume intelligence directly.

# Architecture
Responsibilities by component:
- PlayerPerformanceEngine
  - Inputs: Completed rounds, completed shots, club catalog, existing intelligence snapshots (for rolling windows).
  - Outputs: PlayerIntelligence containing player profile, club profiles, trends, dispersion, distance, confidence, and metadata (sample sizes, freshness, last analysed, outlier counts).
  - Non-responsibilities: No club recommendation, no risk evaluation, no environmental calculations, no presentation.

- PlayerIntelligence (immutable)
  - Aggregates: PlayerPerformanceProfile, [ClubPerformanceProfile], [PerformanceTrend], ConfidenceProfile, metadata.
  - Consumers: Recommendation Pipeline stages via RecommendationContext; Explainability in future.
  - Persistence: Stored as snapshots, versioned, time-stamped.

Integration points:
- Context/Decision boundary: RecommendationContext gains a PlayerIntelligence reference/value.
- Learning pipeline relationship: This subsystem is deterministic analytics over history; future ML learning can augment but must not bypass contracts.

# Data Ownership
- Historical rounds and shots: Owned by Round/History domain.
- Derived statistics, trends, confidence: Owned by Player Performance Intelligence.
- Recommendation engines: Read-only consumers of PlayerIntelligence.

# Deterministic Calculations
ClubPerformanceProfile per club (where sufficient data exists):
- averageCarry, medianCarry
- averageTotalDistance
- lateralDispersion, longitudinalDispersion
- typicalMissDirection
- distanceConsistency, carryConsistency
- observationCount, outlierCount
- lastAnalysedAt
- confidence (explainable composite)

Only statistically meaningful samples are used. Insufficient history is handled gracefully by marking fields unavailable and lowering confidence.

# Trend Calculations
Deterministic trend signals over rolling windows (documented, no ML):
- consistencyImprovement
- dispersionChange
- distanceChange
- clubConfidenceChange
- recentForm
- rollingAverages
Each trend includes: direction (up/flat/down), magnitude (bounded scale), window, sample size, confidence.

# Shot Outcome Classification
If existing data supports consistent labels, introduce ShotOutcomeClassification with cases such as: excellent, good, acceptable, poor, recovery, penalty, punchOut, layUp, approach, chip, putt, recoverySuccess. If data quality is insufficient, defer the dedicated type and retain internal tagging within the engine.

# Confidence Model
ConfidenceProfile expands deterministically using:
- historicalSampleSize
- recencyWeighting (recent rounds)
- clubFamiliarity
- performanceConsistency
- trendConfidence
- environmentalConfidence (as provided by Environmental layer)
- dataFreshness
Confidence remains explainable by exposing factor contributions and raw evidence (counts, windows, timestamps).

# Pipeline Integration
RecommendationContext is extended to include PlayerIntelligence. The Recommendation Pipeline consumes EnvironmentalAssessment, PlayerIntelligence, ShotContext, and RecommendationInputs. Engines must not compute stats or read history; they rely solely on PlayerIntelligence for player-related evidence. Duplicate calculations are eliminated.

# Explainability Readiness
Expose structured evidence without narration:
- "carryMean": 147m for 7-iron with sampleSize: 36
- "missRightCount": 6 of last 10 rounds
- "clubConfidenceRank": 1 of 13 clubs
- Trend records with direction and window metadata
This enables future explanation and narration layers without reprocessing history.

# Future Extensibility
Designed to support future integration without redesigning the Recommendation Pipeline:
- Machine Learning augmentations
- Shot prediction
- Adaptive coaching
- Player confidence modelling
- Practice recommendations
- Skill progression
- Handicap analytics
- Cloud synchronization of intelligence snapshots

# Testing Strategy
Comprehensive tests cover:
- emptyHistory, singleRound, multipleRounds, largeHistories
- outlierHandling
- rollingAverages, dispersionCalculations, distanceStatistics
- trendCalculations, clubStatistics, confidenceCalculations
- pipelineIntegration and regression

# Consequences
Positive:
- Clear separation of analytics from decision-making
- Deterministic, testable player intelligence
- Elimination of duplicate calculations in recommendation stages
- Strong explainability foundation

Negative:
- Additional analytics layer and snapshot persistence
- More domain contracts to maintain
These costs are accepted to ensure scalability and clarity.

# Implementation Notes
- Models are value types where possible; aggregates are immutable.
- Use stable identifiers for clubs and shots.
- Version intelligence snapshots for schema evolution.
- Prefer streaming analysis by round to avoid full-history recomputation.

# References
- ADR-018 — Recommendation Context Architecture
- ADR-019 — Player Performance Learning Architecture
- ADR-022 — Recommendation Pipeline Architecture
- ADR-023 — Multi-Pipeline Product Architecture
