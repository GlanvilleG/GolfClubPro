# ADR-031 – Environmental Intelligence Architecture

- Status: Accepted
- Date: 2026-07-22
- Sprint: 10.5 – Environmental & Risk Intelligence
- Decision Makers: GolfClubPro Architecture Team
- Supersedes: None
- Superseded By: None

## 1. Context
Recommendation engines were independently interpreting environmental inputs (wind, elevation, lie, course conditions). This caused duplication, inconsistent math, and fragmented confidence modeling. Sprint 10.5 requires a unified environmental layer that interprets raw inputs once and provides immutable assessments to all downstream engines.

## 2. Problem
- Environmental interpretation scattered across multiple engines
- Duplicate wind/elevation/lie calculations
- Inconsistent use of stale/missing weather
- Confidence affected by multiple heuristics
- Harder to test, explain, and audit

## 3. Decision
Introduce a first-class Environmental Intelligence layer:
- EnvironmentalContextEngine performs interpretation only
- Produce immutable EnvironmentalAssessment objects
- Downstream engines consume assessments rather than raw feeds
- Recommendation Pipeline becomes the single deterministic consumer/provider of environmental intelligence

## 4. Assessment Models (Immutable)
- EnvironmentalAssessment
- WeatherAssessment
- TerrainAssessment
- LieAssessment
- CourseConditionAssessment
- HazardAssessment (summary projection of HoleAreaAssessment)
- EnvironmentalConfidence

All conform to Equatable, Codable, Sendable. Assessments are recommendation-time snapshots suitable for audit.

## 5. EnvironmentalContextEngine
Responsibilities:
- Interpret raw weather, terrain, lie, course conditions, GPS
- Derive wind cross/along components (bearing-aware)
- Summarize hazard exposure from HoleAreaAssessment (no re-sampling)
- Compute deterministic EnvironmentalConfidence
- Produce EnvironmentalAssessment

Non-Responsibilities:
- No club recommendation
- No strategy or risk/reward evaluation

## 6. Pipeline Integration
- RecommendationPipeline constructs EnvironmentalAssessment once per execution
- Normalizes wind units (km/h → m/s) and applies conservative defaults when weather absent (age ~ 6h, providerQuality 0.5)
- Threads EnvironmentalAssessment to CaddyRecommendationEngine
- Includes EnvironmentalAssessment in RecommendationPipelineResult (optional) for auditing
- RecommendationEngine aim-offset prefers standardized crosswind
- ClubScoringEngine consumes assessments (wind/lie/terrain/course conditions/confidence)
- ExplanationBuilder renders assessment-driven environmental conditions and confidence

## 7. Confidence Model
EnvironmentalConfidence is deterministic and includes:
- overall [0,1]
- gpsQuality [0,1]
- weatherFreshness [0,1]
- dataCompleteness [0,1]

Roll-up currently uses a simple weighted mean. Future versions may tune weights or adopt geometric means.

## 8. Testing Summary
- New tests assert EnvironmentalAssessment is present in pipeline result
- Backwards-compatible overloads preserve existing tests
- ClubScoringEngine refactor covered by existing scoring tests; future tests can assert course-condition impacts

## 9. Consequences
Positive:
- Single source of truth for environment
- Eliminates duplicate calculations
- Deterministic, auditable inputs
- Easier to test and explain

Negative:
- Additional models and engine
- Slight increase in pipeline construction

## 10. Future Extensibility
Architecture supports:
- Live weather APIs and WeatherKit
- Barometric pressure, humidity, temperature, gusts
- Course superintendent updates and local rules
- Sensor fusion
- ML-assisted environmental projections

No Recommendation Pipeline redesign required.

## 11. Related Documents
- ADR-022 – Recommendation Pipeline Architecture
- ADR-020 – AI Shot Coaching Architecture
- Sprint 10.1 – Probabilistic Hole Area Assessment (HoleAreaAssessmentEngine)
