
# ADR-022 – Recommendation Pipeline Architecture

- **Status:** Accepted
- **Date:** 2026-07-15
- **Decision Makers:** GolfClubPro Architecture Team
- **Sprint:** Sprint 8.5 – Recommendation Architecture Stabilisation
- **Supersedes:** None
- **Superseded By:** None

---

# 1. Context

The Recommendation subsystem has evolved significantly since the initial implementation.

Originally, the RecommendationEngine was responsible for:

- Creating the shot strategy
- Scoring clubs
- Sorting recommendations
- Constructing explanations
- Creating audit records
- Returning recommendation results

As the project matured, these responsibilities expanded, causing RecommendationEngine to violate the Single Responsibility Principle and become increasingly difficult to maintain, test and extend.

The project vision has also expanded beyond simple club recommendations to include:

- AI Coaching
- HumanModel
- Adaptive Learning
- Post-round Analytics
- Apple Watch
- iPhone
- Voice Coaching

To support this future architecture the Recommendation subsystem must become deterministic, stable and reusable.

---

# 2. Problem

RecommendationEngine had accumulated multiple responsibilities including business logic, explanation generation and audit construction.

This resulted in:

- Tight coupling
- Difficult unit testing
- Large source file
- Feature creep
- Poor separation of concerns

Future coaching functionality risked being incorrectly implemented inside RecommendationEngine.

---

# 3. Decision

RecommendationEngine shall become a deterministic orchestration engine.

It shall no longer construct explanations, audits or presentation objects.

Its responsibility is limited to coordinating the recommendation pipeline.

Business logic is delegated to specialised engines and builders.

---

# 4. Recommendation Pipeline

```
ShotContext
      │
      ▼
StrategyEngine
      │
      ▼
ClubScoringEngine
      │
      ▼
RecommendationSorter
      │
      ▼
RecommendationDecision
      │
      ▼
RecommendationExplanationBuilder
      │
      ▼
RecommendationAuditBuilder
      │
      ▼
RecommendationResult
```

RecommendationEngine orchestrates this pipeline only.

---

# 5. Architectural Components

## StrategyEngine

**Responsibility**

Determine the optimal shot strategy.

Produces:

- ShotPlan

---

## ClubScoringEngine

**Responsibility**

Evaluate every available club against the current shot.

Responsibilities include:

- distance suitability
- lie suitability
- historical performance
- dispersion
- environmental adjustments
- confidence

Produces:

- ClubRecommendation

---

## RecommendationSorter

**Responsibility**

Sort candidate recommendations.

Produces:

- Ordered recommendation list

---

## RecommendationDecision

**Responsibility**

Represents the golfing decision.

Contains:

- ShotPlan
- Preferred Club
- Alternative Clubs
- Aim Offset

RecommendationDecision contains no presentation logic.

---

## RecommendationExplanationBuilder

**Responsibility**

Construct a structured explanation describing the recommendation.

Produces:

- RecommendationExplanation

Including:

- summary
- primary reasons
- environmental conditions
- warnings
- confidence statement
- course management advice
- next shot focus

---

## RecommendationAuditBuilder

**Responsibility**

Create RecommendationAuditRecord for analytics and traceability.

Produces:

- RecommendationAuditRecord

Only when audit is enabled.

---

## RecommendationResult

RecommendationResult is the immutable output of the Recommendation subsystem.

Contains:

- RecommendationDecision
- RecommendationExplanation
- RecommendationAuditRecord?

---

# 6. Design Principles

The Recommendation subsystem adopts the following principles.

## Deterministic

The same RecommendationContext shall always produce the same RecommendationResult.

No hidden state.

No randomness.

---

## Immutable

RecommendationDecision

RecommendationExplanation

RecommendationResult

shall be immutable value objects.

---

## Single Responsibility

Each component performs exactly one responsibility.

Examples:

StrategyEngine

↓

Strategy

ClubScoringEngine

↓

Scoring

RecommendationSorter

↓

Ordering

RecommendationExplanationBuilder

↓

Explanation

RecommendationAuditBuilder

↓

Audit

---

## Presentation Independent

Recommendation shall not contain:

- UI rendering
- localisation
- formatted presentation
- Apple Watch behaviour
- iPhone behaviour
- Voice behaviour

Presentation consumes RecommendationResult.

---

## Coaching Independent

Recommendation shall not perform coaching.

Recommendation answers:

> What should the golfer do?

Coaching answers:

> How should the golfer execute the shot?

These are separate responsibilities.

---

## HumanModel Independent

Recommendation shall not directly depend upon HumanModel.

HumanModel shall consume RecommendationDecision when generating coaching.

---

# 7. Public API

The following domain objects are considered stable.

- RecommendationDecision
- RecommendationExplanation
- RecommendationResult

Breaking changes require a new ADR.

Future enhancements shall be additive.

---

# 8. Future Extension Points

The Recommendation subsystem intentionally provides extension points.

## AI Coaching

Consumes:

- RecommendationDecision
- RecommendationExplanation

Produces:

- ShotPreparationAdvice

---

## HumanModel

Consumes:

- RecommendationDecision

Produces:

- Personalised coaching adjustments

---

## Adaptive Learning

Consumes:

- RecommendationAuditRecord

Produces:

- Updated player model

---

## Analytics

Consumes:

- RecommendationAuditRecord

Produces:

- Long-term performance insights

---

# 9. Consequences

## Positive

- Small RecommendationEngine
- High testability
- Stable public API
- Clear architectural boundaries
- Easy future extension
- Independent builders
- Independent engines

---

## Negative

- More classes
- Slight increase in object construction
- Additional dependency injection

These costs are considered acceptable for improved maintainability.

---

# 10. RecommendationEngine Responsibilities

RecommendationEngine is responsible only for:

1. Validate RecommendationContext
2. Create ShotPlan
3. Score candidate clubs
4. Sort recommendations
5. Create RecommendationDecision
6. Build RecommendationExplanation
7. Build RecommendationAuditRecord
8. Return RecommendationResult

RecommendationEngine shall contain no business logic beyond orchestration.

---

# 11. Recommendation Subsystem Boundary

The Recommendation subsystem ends with RecommendationResult.

Everything beyond RecommendationResult is outside the subsystem.

Examples include:

- Shot Coaching Engine
- HumanModel
- AI Coach
- Apple Watch UI
- iPhone UI
- Voice Coach
- Analytics
- Learning Engine

These consume RecommendationResult but shall not modify RecommendationEngine.

---

# 12. Engineering Principles

The Recommendation subsystem adheres to the following principles.

- Single Responsibility Principle
- Immutable Domain Objects
- Deterministic Decision Pipeline
- Builder Pattern for Complex Domain Objects
- Engine Pattern for Domain Calculations
- Presentation Separation
- Coaching Separation
- HumanModel Separation
- Test-First Architecture

---

# 13. Success Criteria

The Recommendation subsystem is considered architecturally complete when:

- RecommendationEngine contains orchestration only.
- All business logic resides in specialised engines.
- All complex object construction resides in builders.
- RecommendationResult is immutable.
- The public API is stable.
- All unit tests pass.
- Future coaching functionality requires no RecommendationEngine modifications.

---

# 14. Related ADRs

- ADR-004 – Strongly Typed Identifiers
- ADR-006 – Watch-First Architecture
- ADR-022 – Recommendation Pipeline Architecture

Future:

- ADR-023 – AI Shot Coaching Architecture
- ADR-024 – Human Playing Characteristics
- ADR-025 – Adaptive Learning Pipeline

---

# 15. Status

**Accepted**

This ADR formally freezes the Recommendation subsystem architecture following Sprint 8.5.

Future enhancements shall extend the subsystem through downstream consumers rather than modifying the Recommendation pipeline itself.
