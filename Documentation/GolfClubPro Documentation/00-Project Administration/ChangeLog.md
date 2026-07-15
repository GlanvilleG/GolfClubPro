
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
