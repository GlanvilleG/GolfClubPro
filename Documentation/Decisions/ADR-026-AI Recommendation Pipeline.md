
# ADR-026: AI Recommendation Pipeline

**Status:** Accepted

**Date:** 2026-07-19

**Authors:** GolfClubPro Architecture Team

---

# Context

GolfClubPro's primary objective is to provide intelligent, explainable, and personalised caddie recommendations while maintaining a clean, testable architecture.

As AI capabilities expand (player modelling, weather, hazard analysis, green strategy, dispersion modelling, etc.), there is a risk that recommendation logic becomes tightly coupled and difficult to maintain.

The Recommendation Pipeline establishes a dedicated orchestration layer that coordinates specialised calculation engines while preserving clear separation of responsibilities.

---

# Decision

GolfClubPro shall implement AI recommendations using a dedicated **Recommendation Pipeline**.

The Recommendation Pipeline shall:

- orchestrate specialised engines
- never contain business calculations
- never communicate directly with external providers
- never mutate domain models
- operate only on immutable domain context
- return an immutable recommendation result

---

# Architecture

```text
                 RoundContext
                       │
                       ▼
             RecommendationInputs
                       │
                       ▼
          RecommendationPipeline
                       │
     ┌─────────────────┼─────────────────┐
     ▼                 ▼                 ▼
Strategic        Adaptive         Weather
OptionEngine   CoachingEngine AdjustmentEngine
     │                 │                 │
     └────────────┬────┴─────────────────┘
                  ▼
      CaddyRecommendationEngine
                  │
                  ▼
   RecommendationPipelineResult
```

---

# Pipeline Responsibilities

The Recommendation Pipeline is responsible for:

- validating orchestration inputs
- selecting the best strategic option
- deriving geometric values required by downstream engines
- invoking each engine in the correct order
- assembling the final recommendation result

The pipeline is **not responsible** for:

- shot strategy
- weather calculations
- player modelling
- risk assessment
- explanation generation
- provider integration

---

# Engine Responsibilities

## StrategicOptionEngine

Responsible for:

- evaluating candidate landing zones
- selecting the preferred strategic option
- balancing scoring opportunity against risk

Returns:

- StrategicOption

---

## AdaptiveCoachingEngine

Responsible for:

- adjusting the target using player tendencies
- compensating for consistent directional errors
- producing personalised target adjustments

Returns:

- AdaptiveTargetAdjustment

---

## WeatherAdjustmentEngine

Responsible for:

- wind influence
- carry adjustments
- lateral movement
- environmental effects

Returns:

- WeatherAdjustment

---

## CaddyRecommendationEngine

Responsible for:

- combining all engine outputs
- producing golfer-facing explanations
- determining recommendation confidence
- identifying recommendation reasons

Returns:

- CaddyRecommendation

---

# Domain Context

The pipeline operates exclusively on immutable domain models.

Primary inputs include:

- RoundContext
- ShotContext
- HoleContext
- RecommendationInputs

No engine communicates directly with:

- WeatherKit
- GPS providers
- network services
- persistence layers

Provider data must be translated into domain models before entering the pipeline.

This extends the principles established in ADR-025.

---

# Geometry

The pipeline may derive simple geometric values required by downstream engines.

Examples include:

- bearing between current position and target
- effective shot distance

Complex geometry shall remain encapsulated in reusable utilities such as:

- DistanceCalculator
- BearingCalculator

---

# Recommendation Order

The execution order is fixed.

1. Validate pipeline inputs.
2. Determine the strategic option.
3. Derive geometry.
4. Apply player adaptation.
5. Apply weather adjustments.
6. Generate the golfer recommendation.
7. Return immutable results.

This order ensures each engine receives complete upstream information while avoiding circular dependencies.

---

# RecommendationPipelineResult

The pipeline returns an immutable result containing:

- StrategicOption
- AdaptiveTargetAdjustment
- WeatherAdjustment
- CaddyRecommendation

This enables downstream consumers to inspect intermediate AI decisions without recalculating them.

---

# Recommendation Reasons

Recommendation reasons describe **why** the recommendation changed rather than **what** data source produced it.

Examples include:

- hazardAvoidance
- playerPattern
- weatherInfluence

This keeps explanations independent of implementation details such as WeatherKit.

---

# Confidence

Confidence is produced incrementally.

Each engine contributes confidence based on the certainty of its own calculation.

The final recommendation confidence is derived from the combined engine outputs rather than any single component.

This allows future AI models to contribute confidence without altering pipeline orchestration.

---

# Error Handling

The Recommendation Pipeline validates only orchestration-level concerns.

Current validation includes:

- no candidate landing zones
- selected club unavailable

Missing optional golfer calibration data (for example, average carry distance) is **not** treated as an error.

Reasonable fallbacks are preferred whenever possible.

---

# Extensibility

Future AI engines should integrate by adding a new immutable calculation stage.

Examples include:

- DispersionEngine
- GreenStrategyEngine
- LieAssessmentEngine
- ShotShapePredictionEngine
- RecoveryStrategyEngine
- PuttingRecommendationEngine

The Recommendation Pipeline remains the single orchestration point regardless of the number of calculation engines.

---

# Consequences

## Advantages

- Highly testable
- Deterministic
- Explainable AI decisions
- Provider independence
- Strong separation of concerns
- Easy to extend
- Immutable execution flow
- Simple unit testing through engine isolation

## Trade-offs

- Slightly more orchestration code
- More domain models
- More engine interfaces

These trade-offs are accepted because they significantly improve maintainability and long-term extensibility.

---

# Relationship to Other ADRs

| ADR | Relationship |
|------|--------------|
| ADR-004 | Uses strongly typed identifiers throughout the pipeline. |
| ADR-006 | Supports the Watch-first architecture by enabling lightweight recommendation execution on Apple Watch. |
| ADR-023 | Implements the Multi-Pipeline Product Architecture through a dedicated Recommendation Pipeline. |
| ADR-025 | Consumes immutable provider-independent decision snapshots and remains isolated from external providers. |

---

# Future Work

Potential future enhancements include:

- conversational explanation generation using natural language synthesis
- multi-shot strategic planning
- confidence visualisation
- probabilistic dispersion modelling
- machine learning player adaptation
- tournament versus social play strategy profiles
- explainable AI audit logging
- simulation-based recommendation comparison

---

## Architectural Principle

> **The Recommendation Pipeline orchestrates AI decision making; engines perform calculations, domain models provide immutable context, and recommendations remain explainable, deterministic, and independent of external providers.**

---

I believe this ADR marks the point where the project moves from "building an application" to "building an AI decision platform." It captures the architectural patterns we've established over the past several sprints and provides a stable foundation for the more advanced caddie intelligence planned in Sprint 10.0.
