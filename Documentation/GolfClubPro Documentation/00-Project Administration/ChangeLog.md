
# Architecture Refinement Sprint

### Pass 1 — Repository Cleanup

- Removed obsolete CoreLocationService implementation
- Removed temporary package probe code
- Removed diagnostic and placeholder tests
- Removed dead references and outdated comments
- Verified GolfCore and GolfPlatformApple package structure
- Confirmed all package tests and app build succeed
### Pass 2 — Package Boundary Audit

- Confirmed GolfCore contains no Apple-framework dependencies
- Confirmed GolfPlatformApple contains only platform adapters
- Verified SwiftData remains in the iPhone application layer
- Removed duplicate or misplaced implementations
- Verified iPhone and Watch source ownership
- Confirmed all package tests and application targets build

### Pass 3 – Vocabulary & Naming Audit

The objective is that every class name immediately communicates its responsibility.
- Our vocabulary - updated in 02-Architecture/Ubiquitous Language.md

### Pass 4 — Public API Audit

- Reduced unnecessary public declarations
- Kept cross-module contracts explicit
- Changed read-only external state to public private(set)
- Kept app implementation types internal
- Identified aggregate mutation controls for later refinement
- Verified package tests and application builds

### Pass 5 — DDD Responsibility Audit

- Identified Round as the primary aggregate root
- Classified entities and value objects
- Confirmed engine, service, coordinator and provider responsibilities
- Verified persistence contracts contain no business logic
- Identified direct aggregate mutation for future restriction
- Identified injectable clock requirement for deterministic timestamps
- Recorded future separation of domain events and sync envelopes

### Pass 6 — Dependency and Import Audit

- Confirmed GolfCore contains no Apple or UI framework imports
- Confirmed GolfPlatformApple depends only on GolfCore
- Confirmed SwiftData remains in the iPhone app layer
- Verified package manifests and dependency direction
- Added automated architecture-boundary validation
- Confirmed all package tests and application targets build

### Pass 7 — Test Quality Audit

- Removed placeholder and compile-only tests
- Corrected async assertion patterns
- Replaced fragile floating-point comparisons
- Stabilised date-sensitive tests
- Added shared test fixtures where useful
- Improved behaviour-based test naming
- Added missing boundary cases
- Confirmed package and application test suites pass

### Pass 8 — Documentation Alignment

- Updated System Context to reflect current packages and applications
- Added Container Architecture
- Updated Repository Structure
- Updated Architectural Evolution
- Reconciled ADR references and numbering
- Updated roadmap and milestone status
- Aligned Domain Model with current DDD responsibilities

# Sprint 8 — Recommendation Engine Refactor

### Stage 1 — Recommendation Domain Separation

- Introduced `RecommendationDecision` as the immutable representation of the recommendation outcome.
- Refactored `RecommendationResult` to encapsulate:
  - `RecommendationDecision`
  - `RecommendationExplanation`
  - `RecommendationAuditRecord`
- Separated recommendation decision making from presentation concerns.
- Established Recommendation as a deterministic domain subsystem.

### Stage 2 — Club Scoring Engine

- Extracted club evaluation logic into `ClubScoringEngine`.
- Removed scoring responsibilities from `RecommendationEngine`.
- Centralised:
  - carry adjustments
  - lie adjustments
  - environmental adjustments
  - confidence calculation
  - historical performance
  - dispersion analysis
- Added comprehensive unit test coverage.

### Stage 3 — Recommendation Sorting

- Introduced `RecommendationSorter`.
- Centralised recommendation ordering.
- Removed sorting behaviour from `RecommendationEngine`.
- Added deterministic recommendation ordering tests.

### Stage 4 — Structured Recommendation Explanations

- Introduced `RecommendationExplanation`.
- Introduced `ExplanationItem`.
- Introduced `ExplanationSeverity`.
- Replaced monolithic explanation strings with structured immutable domain objects.
- Separated:
  - summary
  - primary reasons
  - environmental conditions
  - warnings
  - confidence statements
  - course management advice
  - next shot focus
- Added `RecommendationExplanationBuilder`.

### Stage 5 — Environmental Explanation Model

- Introduced structured environmental explanation collection.
- Added support for:
  - live weather
  - cached weather
  - stale weather
  - unavailable weather
  - wind adjustments
  - elevation adjustments
  - temperature reporting
- Updated tests to validate domain objects instead of rendered strings.

### Stage 6 — Recommendation Audit Builder

- Introduced `RecommendationAuditBuilder`.
- Removed audit construction responsibility from `RecommendationEngine`.
- Builder now owns audit enablement decisions.
- Preserved audit record compatibility through structured explanation summaries.
- Added independent audit builder tests.

### Stage 7 — Recommendation Pipeline Stabilisation

- RecommendationEngine now acts as a deterministic orchestration pipeline.
- Recommendation responsibilities now separated into:
  - StrategyEngine
  - ClubScoringEngine
  - RecommendationSorter
  - RecommendationExplanationBuilder
  - RecommendationAuditBuilder
- RecommendationEngine now contains minimal business logic.
- Established stable Recommendation subsystem boundaries.

### Stage 8 — Recommendation Architecture

- Published ADR-020 – AI Shot Coaching Architecture.
- Published ADR-021 – Human Playing Characteristics.
- Published ADR-022 – Recommendation Pipeline Architecture.
- Recommendation subsystem formally declared presentation independent.
- Recommendation subsystem formally separated from:
  - Coaching
  - HumanModel
  - Analytics
  - User Interface

### Stage 9 — Testing

- Added RecommendationExplanationBuilder tests.
- Added RecommendationSorter tests.
- Added RecommendationAuditBuilder tests.
- Updated Recommendation tests to validate structured domain models.
- All GolfCore tests passing following Recommendation subsystem refactor.

### Stage 10 — Future Direction

Recommendation subsystem architecture is now considered stable.

Future development will extend the platform through downstream consumers rather than modifying RecommendationEngine.

Planned future work includes:

- Shot Coaching Engine
- Playing Characteristics
- HumanModel
- Adaptive Learning
- AI Coach
- Recommendation Metrics

# ## Sprint 9 — Recommendation Pipeline Architecture

### Status

Completed.

### Objective

Create a provider-independent, immutable and testable recommendation pipeline that coordinates strategic, player, weather and caddie decision engines.

### Phase 9.1 — Multi-Pipeline Architecture

#### Step 9.1.1 — Architecture Decision

- Added ADR-023: Multi-Pipeline Product Architecture.
- Established pipelines as orchestration components.
- Confirmed that pipelines coordinate domain engines without replacing authoritative domain models.
- Established separation between:
  - builders
  - engines
  - pipelines
  - immutable models
  - persistent domain state

#### Step 9.1.2 — Architectural Responsibilities

- Builders assemble immutable context.
- Engines perform focused calculations.
- Pipelines orchestrate calculations and data flow.
- Domain models remain authoritative.
- Existing domain models are reused rather than duplicated.

### Phase 9.2 — Provider Independence

#### Step 9.2.1 — Architecture Decision

- Added ADR-025: Provider Independence Through Immutable Decision Snapshots.
- Established immutable snapshots between external data providers and decision engines.
- Prevented weather, course, performance and future AI providers from leaking provider-specific representations into the core domain.
- Established provider substitution as a supported architectural requirement.

#### Step 9.2.2 — Immutable Recommendation Inputs

- Introduced immutable recommendation-time input models.
- Separated transient recommendation data from persistent round and shot state.
- Preserved `RoundContext` and `ShotContext` as authoritative domain state.

### Phase 9.3 — AI Recommendation Pipeline

#### Step 9.3.1 — Architecture Decision

- Added ADR-026: AI Recommendation Pipeline.
- Defined the initial recommendation sequence:
  1. validate inputs
  2. determine the strategic option
  3. calculate shot geometry
  4. apply adaptive player coaching
  5. apply weather adjustment
  6. create the final caddie recommendation
  7. return an immutable pipeline result

#### Step 9.3.2 — Recommendation Pipeline

- Added `RecommendationPipeline`.
- Added dependency injection for recommendation engines.
- Added input validation.
- Added failure handling for missing candidate landing zones.
- Added failure handling when the selected club is unavailable.
- Added selected-club carry-distance resolution.
- Added target-distance fallback when average club carry is unavailable.

#### Step 9.3.3 — Recommendation Pipeline Result

- Added `RecommendationPipelineResult`.
- Returned an immutable snapshot containing:
  - strategic option
  - adaptive target adjustment
  - weather adjustment
  - caddie recommendation
- Kept pipeline result construction separate from persistent round state.

#### Step 9.3.4 — Recommendation Pipeline Errors

- Added recommendation-pipeline error handling.
- Added explicit failure cases for:
  - no candidate landing zones
  - unavailable selected club
- Kept pipeline validation failures deterministic and testable.

### Phase 9.4 — Strategic Option Evaluation

#### Step 9.4.1 — Strategic Option Engine Integration

- Integrated `StrategicOptionEngine`.
- Evaluated available landing-zone candidates from the current `ShotContext`.
- Selected the preferred club and target through a focused strategic engine.
- Kept strategic evaluation independent from weather and adaptive coaching.

### Phase 9.5 — Shot Geometry

#### Step 9.5.1 — Bearing Calculation

- Added `BearingCalculator`.
- Calculated the geographic bearing from the current ball position to the selected target.
- Used shot bearing for directional coaching and weather adjustment.
- Kept bearing calculation separate from recommendation orchestration.

#### Step 9.5.2 — Club Distance Resolution

- Added club-distance lookup using the selected `ClubID`.
- Used average club carry when available.
- Used geographic target distance as a fallback.
- Added explicit validation when the strategic option selects a club unavailable to the player.

### Phase 9.6 — Adaptive Coaching

#### Step 9.6.1 — Adaptive Coaching Engine Integration

- Integrated `AdaptiveCoachingEngine`.
- Applied player-performance information to target adjustment.
- Used club-specific historical performance where available.
- Preserved the original target when no player-performance model exists.
- Added a neutral adjustment with zero confidence when adaptive information is unavailable.

### Phase 9.7 — Weather Adjustment

#### Step 9.7.1 — Weather Adjustment Engine Integration

- Integrated `WeatherAdjustmentEngine`.
- Used:
  - selected club distance
  - shot bearing
  - current weather conditions
- Preserved an optional weather result when no weather information exists.
- Kept weather calculations independent from player-performance calculations.

### Phase 9.8 — Final Caddie Recommendation

#### Step 9.8.1 — Caddie Recommendation Engine Integration

- Integrated `CaddyRecommendationEngine`.
- Combined:
  - strategic option
  - adaptive coaching adjustment
  - weather adjustment
- Produced the final recommendation without exposing provider-specific data.
- Preserved focused engine responsibilities.

### Phase 9.9 — Pipeline Completion and Validation

#### Step 9.9.1 — Immutable Orchestration

- Confirmed that the pipeline performs orchestration only.
- Confirmed that engines remain responsible for their own calculations.
- Confirmed that persistent domain state remains outside the pipeline result.
- Confirmed that no duplicate recommendation-domain models were introduced.

#### Step 9.9.2 — Tests

- Added tests covering:
  - pipeline validation
  - strategic-option selection
  - club availability
  - club carry-distance selection
  - distance fallback
  - adaptive coaching
  - weather adjustment
  - final recommendation construction
- Preserved deterministic behaviour when optional player or weather information is unavailable.

#### Step 9.9.3A — Pipeline Implementation

- Completed the initial end-to-end recommendation pipeline.
- Confirmed successful compilation.
- Confirmed pipeline dependency integration.
- Confirmed immutable result construction.

#### Step 9.9.3B — Pipeline Validation

- Completed recommendation-pipeline unit tests.
- Confirmed all tests pass.
- Confirmed no behavioural regression in existing round and shot workflows.
- Established the completed Sprint 9 pipeline as the foundation for Sprint 10 probabilistic modelling.
## Sprint 10 — Probabilistic Shot Modelling

### Status

Completed.

### Objective

Extend the recommendation architecture so GolfClubPro evaluates probable shot outcomes rather than assuming perfect execution.

### Phase 10.0 — Probabilistic Modelling Foundation

#### Step 10.0.1 — Architecture Decision

- Added ADR-027: Probabilistic Shot Modelling.
- Established the principle that GolfClubPro shall evaluate the probability of outcomes rather than assume perfect execution.
- Defined future support for:
  - expected landing distributions
  - lateral and longitudinal dispersion
  - directional and distance bias
  - player-specific shot modelling
  - hazard probability
  - Monte Carlo simulation

#### Step 10.0.2 — Immutable Dispersion Models

- Added `ShotDispersionModel`.
- Added separate lateral and longitudinal standard deviations.
- Added lateral and longitudinal bias values.
- Added model confidence.
- Added value clamping for standard deviation and confidence inputs.
- Added `DispersionAxis`.
- Added `DispersionConfidence`.

#### Step 10.0.3 — Player Dispersion Profile Refinement

- Reused the existing `ShotDispersionProfile` as the canonical stored statistical representation.
- Avoided adding duplicate dispersion fields to `PlayerPerformanceModel`.
- Added `distanceBiasMeters` to distinguish expected distance error from average carry distance.
- Added helpers for identifying consistently short and consistently long performance.
- Continued using the existing lateral-bias and shot-shape classifications.

#### Step 10.0.4 — Default Dispersion Provider

- Added `DefaultDispersionProfileProvider`.
- Added conservative fallback dispersion values for clubs without sufficient player history.
- Preserved one canonical `ShotDispersionProfile` representation.
- Avoided introducing duplicate default statistical models.

#### Step 10.0.5 — Dispersion Engine

- Added `DispersionEngine`.
- Added player-specific profile lookup by club.
- Added fallback behaviour when player data is missing or insufficient.
- Converted persistent `ShotDispersionProfile` data into immutable recommendation-time `ShotDispersionModel` values.
- Added unit tests for player-specific and default dispersion behaviour.
- Confirmed successful compile and test execution.

### Phase 10.1 — Probabilistic Hole Area Assessment

#### Step 10.1.1 — Existing Course Domain Reuse

- Reused the existing `HoleArea` model.
- Reused `HoleAreaType` as the canonical course-area classification.
- Avoided introducing duplicate AI-specific types such as `HazardType` or `Hazard`.
- Reused existing classifications:
  - `isHazard`
  - `isPlayingSurface`
  - `requiresRulesRelief`
  - `isSensitiveArea`

#### Step 10.1.2 — Geographic Bounding Box

- Added `GeoBoundingBox`.
- Added coordinate-based bounding-box construction.
- Added point-containment checks.
- Added bounding-box intersection checks.
- Added `HoleArea.boundingBox`.
- Added early spatial filtering so distant course areas are excluded before detailed assessment.

#### Step 10.1.3 — Polygon Containment

- Added point-in-polygon containment support for `HoleArea`.
- Added bounding-box pre-checks before polygon calculations.
- Added handling for invalid boundaries containing fewer than three coordinates.

#### Step 10.1.4 — Risk Models

- Added `HazardRisk`.
- Added risk levels:
  - negligible
  - low
  - moderate
  - high
  - severe
- Added probability-to-risk classification thresholds.
- Added comparable risk ranking.
- Added `HoleAreaAssessment`.
- Added `HoleAssessment`.
- Added filtered assessment access for:
  - hazards
  - areas requiring rules relief
  - sensitive areas

#### Step 10.1.5 — Hole Area Assessment Engine

- Added `HoleAreaAssessmentEngine`.
- Implemented deterministic Gaussian sampling of expected landing outcomes.
- Modelled separate lateral and longitudinal shot dispersion.
- Applied lateral and longitudinal player bias.
- Rotated the dispersion distribution using the intended shot bearing.
- Converted local metre offsets into geographic coordinates.
- Calculated the weighted probability of landing within each `HoleArea`.
- Classified each course-area probability using `HazardRisk`.
- Calculated overall risk from strategically adverse areas.
- Included trees alongside hazards, rules-relief areas and sensitive areas when determining adverse risk.
- Added configurable standard-deviation limits and sampling density.

#### Step 10.1.6 — Recommendation Inputs

- Extended `RecommendationInputs` with `holeAreas`.
- Preserved source compatibility by defaulting `holeAreas` to an empty array.
- Continued treating `RecommendationInputs` as an immutable snapshot of transient recommendation data.

#### Step 10.1.7 — Recommendation Decision Context

- Added `RecommendationDecisionContext`.
- Added:
  - `strategicOption`
  - `shotDispersion`
  - `holeAssessment`
- Kept the context immutable and free from engine dependencies.
- Established the rule that pipelines own engines, engines create models and models do not own engines.

#### Step 10.1.8 — Recommendation Pipeline Integration

- Added `DispersionEngine` as an injected pipeline dependency.
- Added `HoleAreaAssessmentEngine` as an injected pipeline dependency.
- Calculated shot bearing before dispersion-based spatial assessment.
- Generated a `ShotDispersionModel` from the selected strategic option.
- Assessed current-hole areas against the expected landing distribution.
- Created and actively used `RecommendationDecisionContext`.
- Preserved existing adaptive coaching, weather adjustment and final recommendation behaviour.
- Preserved the existing public `RecommendationPipelineResult` contract.

#### Step 10.1.9 — Tests and Validation

- Added `HoleAreaAssessmentEngineTests`.
- Added coverage for targets located inside bunkers.
- Added material-risk classification checks.
- Added overall-risk checks.
- Added bounding-box filtering tests for distant areas.
- Updated throwing tests to support `#require`.
- Confirmed successful compile.
- Confirmed all existing and new tests pass.

## [Sprint 10.2.0] – Recommendation Framework Foundation

### Added
- Introduced the initial Recommendation Pipeline architecture.
- Added RecommendationContext as the canonical input to recommendation processing.
- Implemented deterministic recommendation workflow.
- Established RecommendationDecision as the golfer-facing recommendation model.
- Added initial recommendation unit tests.

### Changed
- Refactored recommendation generation into a staged pipeline.
- Improved separation between recommendation logic and presentation.

### Documentation
- Updated architecture documentation to describe recommendation flow.

---

## [Sprint 10.2.1] – Spatial Analysis & Shot Planning

### Added
- Introduced ShotPlan as the canonical shot planning model.
- Added TargetPoint and RouteStrategy support.
- Implemented spatial shot planning components.
- Added SpatialRiskAssessment support.

### Changed
- Recommendation pipeline now performs structured shot planning prior to club scoring.
- Improved internal pipeline separation between planning and recommendation.

### Tests
- Added ShotPlan validation tests.
- Added spatial planning regression tests.

---

## [Sprint 10.2.2] – Strategic Analysis & Club Scoring

### Added
- Implemented StrategicOptionEngine.
- Implemented RiskRewardAnalysisEngine.
- Added RiskRewardAnalysis and RiskAssessment domain models.
- Added StrategicDecisionMetrics support.
- Implemented ClubScoringEngine.

### Changed
- Recommendation pipeline now evaluates strategic options before club selection.
- Improved deterministic confidence calculations.
- Refined club scoring using risk and strategic analysis.

### Tests
- Added strategic option tests.
- Added risk/reward regression tests.
- Added club scoring validation tests.

---

## [Sprint 10.3A] – Architecture Reconciliation

### Added
- Established architecture reconciliation baseline.
- Completed recommendation subsystem inventory.
- Documented engine responsibilities.
- Documented recommendation execution pipeline.
- Audited domain models and recommendation responsibilities.

### Changed
- Confirmed RecommendationDecision as the golfer-facing decision object.
- Identified documentation drift between implementation and ADRs.
- Updated architectural baseline to align documentation with production code.

### Documentation
- Architecture review completed.
- Recommendation pipeline documented from implementation.
- Technical debt and future refactoring items identified.

---

## [Sprint 10.3B] – Recommendation Architecture Alignment

### Added
- Completed recommendation architecture alignment.
- Reconciled Recommendation Pipeline with production implementation.
- Improved engine responsibility boundaries.
- Standardised recommendation domain terminology.
- Expanded recommendation test support.

### Changed
- Updated ADRs to reflect implemented architecture.
- Eliminated obsolete architectural assumptions.
- Refined RecommendationContext ownership.
- Improved separation between planning, analysis and recommendation.

### Tests
- Updated recommendation test factories.
- Removed obsolete test assumptions.
- Expanded recommendation regression coverage.

---

## [Sprint 10.5] – Environmental & Risk Intelligence

### Added
- Introduced Environmental Intelligence layer.
- Added EnvironmentalContextEngine.
- Added immutable EnvironmentalAssessment model.
- Added environmental confidence evaluation.
- Added environmental pipeline integration.
- Added deterministic environmental analysis.
- Introduced course condition assessment.
- Introduced environmental risk assessment.
- Expanded hazard intelligence.

### Changed
- Recommendation engines now consume environmental assessments rather than raw environmental data.
- Consolidated weather interpretation into a single architectural component.
- Eliminated duplicate environmental calculations across recommendation engines.
- Expanded confidence calculations to include environmental certainty.

### Tests
- Added environmental integration tests.
- Added weather regression tests.
- Added environmental confidence validation.
- Added pipeline integration tests.

### Documentation
- Added ADR-031 – Environmental Intelligence Architecture.
- Updated Recommendation Pipeline documentation.
- Updated Architecture.md.
- Updated Environmental Intelligence documentation.

---

## [Sprint 10.6] – Player Performance Intelligence

### Added
- Introduced PlayerPerformanceEngine.
- Added Player Intelligence layer.
- Added PlayerPerformanceProfile.
- Added ClubPerformanceProfile.
- Added PerformanceTrend analysis.
- Added deterministic player analytics.
- Added historical performance aggregation.
- Added club-specific performance statistics.
- Added player confidence profiling.
- Added recommendation pipeline integration for player intelligence.

### Changed
- Recommendation engines now consume Player Intelligence rather than analysing historical rounds directly.
- Consolidated historical player analytics into a dedicated engine.
- Expanded recommendation confidence using player history and statistical consistency.
- Improved separation between analytics and recommendation decision logic.

### Tests
- Added PlayerPerformanceEngine unit tests.
- Added club statistics validation tests.
- Added trend analysis tests.
- Added recommendation integration tests.
- Expanded regression coverage.

### Documentation
- Added ADR-032 – Player Performance Intelligence Architecture.
- Updated Recommendation Pipeline documentation.
- Updated Player Domain Model.
- Updated Architecture.md.


