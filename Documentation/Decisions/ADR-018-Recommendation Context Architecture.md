
# ADR-018: Recommendation Context Architecture

**Document ID:** GCP-ADR-018  
**Status:** Accepted  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Decision Makers:** Solution Architecture  
**Related Documents:** ADR-016 Context-Centric Architecture, ADR-017 Course Spatial Index Architecture

---

# Context

GolfClubPro recommendations require information originating from multiple independent subsystems.

These include:

- Current shot context
- Round state
- Player state
- Spatial analysis
- Environmental conditions
- Future player performance models

Historically these inputs could be supplied individually, resulting in increasing coupling between the Recommendation Engine and its upstream providers.
As additional recommendation factors are introduced, this approach becomes increasingly difficult to maintain and test.

---

# Decision

GolfClubPro shall introduce a single immutable Recommendation Context.
The Recommendation Context becomes the canonical boundary between data acquisition and recommendation logic.
Recommendation engines shall consume context objects rather than interacting directly with GPS, location services, round orchestration or user interface components.

---

# Architecture

```text
Location
        │
Round Engine
        │
Spatial Engine
        │
Player State
        │
Environmental Services
        │
        ▼
RecommendationContext
        │
        ▼
Recommendation Engine
        │
        ▼
Recommendation Result
```

---

# Recommendation Context

The Recommendation Context aggregates:

- ShotContext
- RoundSpatialContext
- SpatialAnalysis

Future versions may also include:

- PlayerPerformanceModel
- WeatherContext
- CourseConditionContext
- CompetitionContext

The Recommendation Context shall remain immutable.

---

# Design Principles

The Recommendation Engine shall:

- Consume immutable context.
- Remain deterministic.
- Remain independent of GPS.
- Remain independent of user interface components.
- Remain independent of Apple platform APIs.
- Produce identical recommendations for identical inputs.

---

# Responsibilities

Recommendation Context owns:

- Recommendation inputs.
- Domain state.
- Context composition.

Recommendation Context does not own:

- Recommendation algorithms.
- Spatial calculations.
- Player learning.
- Environmental data collection.

---

# Consequences

## Positive

- Simplified Recommendation Engine.
- Improved testability.
- Stable architectural boundary.
- Easier future expansion.
- Reduced coupling.

## Negative

- Additional domain object.
- Slight increase in object construction.

---

# Engineering Principle

Recommendations consume immutable context.
Recommendation engines never retrieve information directly from infrastructure services.

---

# Revision History

| Version | Date | Description |
|----------|------------|---------------------------------------------|
| 1.0.0 | 2026-07-14 | Initial Recommendation Context Architecture. |
