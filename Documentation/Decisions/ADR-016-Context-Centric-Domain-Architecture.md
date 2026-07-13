# ADR-016: Context-Centric Domain Architecture

**Document ID:** GCP-ADR-016  
**Status:** Accepted  
**Date:** 2026-07-13  
**Decision Makers:** Solution Architecture  

## Related Documents

- Domain Model
- System Context
- System Architecture
- Integration Architecture

## Related ADRs

- ADR-003 – Domain-Driven Design
- ADR-007 – Round Engine State Machine
- ADR-008 – GPS and Golf Club Detection
- ADR-009 – Course Geometry and Lie Detection
- ADR-010 – Strategic Route and Target Planning
- ADR-011 – AI Caddy Architecture
- ADR-012 – Weather Integration
- ADR-013 – Offline-First Architecture
- ADR-014 – Intelligent Round Orchestrator
- ADR-015 – Apple Platform Integration

---

# Context

GolfClubPro integrates information from multiple independent domain services including GPS observations, golf club detection, hole geometry, lie detection, weather, player profile, equipment profile, round state, shot history and strategic planning.

Allowing each business engine to query these services independently would duplicate logic, increase coupling and make recommendations difficult to reproduce and audit.

A consistent representation of the golfer's current situation is therefore required.

---

# Decision

GolfClubPro adopts a **Context-Centric Domain Architecture**.

Business engines consume immutable context objects representing the current state of play instead of querying providers, persistence stores or Apple platform services directly.

The initial context object is **RoundSpatialContext**.

---

# Architectural Principles

- Context objects are immutable.
- Context objects contain domain information only.
- Context objects are platform independent.
- Business engines consume context objects but do not construct them.
- Context builders assemble information from providers and domain services.
- Context objects are recreated whenever underlying information changes.

---

# RoundSpatialContext

RoundSpatialContext represents the platform's current understanding of the golfer's playing situation.

It may contain:

- Current hole
- Hole location confidence
- Current hole area
- Playable lie
- Distance to tee
- Distance to green
- Remaining distance
- Nearest hazard
- Boundary distance
- Current playing route
- Location timestamp
- Confirmation requirement

Future context models may include:

- RecommendationContext
- PlayerPerformanceContext
- CoachingContext
- WeatherContext
- CourseStrategyContext

---

# Responsibilities

## Providers

Providers obtain information from external systems.

Examples:

- AppleLocationProvider
- AppleWeatherProvider
- DotGolfProvider (future)

Providers never make business decisions.

## Detection Services

Detection services interpret raw information.

Examples:

- GolfClubDetector
- HoleGeometryIndex
- LieDetector
- HoleTransitionDetector

## Context Builders

Context builders combine providers, detection services and current round state into immutable context objects.

They do not perform recommendation or coaching logic.

## Business Engines

Business engines consume context objects and return deterministic business outcomes.

Examples:

- RecommendationEngine
- StrategyEngine
- PlayerStatisticsEngine
- CoachEngine (future)

## Coordinators

Coordinators determine when contexts should be refreshed.

Examples:

- RoundOrchestrator
- GolfClubLocationCoordinator
- RoundSession

---

# Dependency Direction

```text
External Providers
        │
        ▼
Detection Services
        │
        ▼
Context Builders
        │
        ▼
Immutable Context Objects
        │
        ▼
Business Engines
        │
        ▼
Recommendations / Decisions
```

Business engines must not depend directly on providers or Apple platform APIs.

---

# Immutability

Contexts are point-in-time snapshots.

When new information becomes available, a new context is created instead of mutating the existing one.

Benefits include:

- Deterministic testing
- Recommendation reproducibility
- Audit support
- Offline recovery
- Future AI training

---

# Consequences

## Positive

- Reduced coupling
- Consistent business logic
- Improved testability
- Easier recommendation auditing
- Better Apple Watch and iPhone consistency
- Simplified AI integration

## Negative

- Additional context construction layer
- More domain models to maintain
- Context schemas require version management

---

# Constraints

- Context objects remain platform independent.
- Context objects must not import Apple frameworks.
- SwiftUI views must not construct context objects.
- Business engines must not query providers directly.

---

# Implementation Guidance

Preferred:

```swift
let result = recommendationEngine.recommend(
    using: recommendationContext
)
```

Avoid:

```swift
let result = recommendationEngine.recommend(
    locationProvider: locationProvider,
    weatherProvider: weatherProvider,
    holeRepository: holeRepository,
    playerRepository: playerRepository
)
```

Initially, RoundSpatialContext will be assembled from:

- HoleGeometryIndex
- HoleGeometryEngine
- LieDetector
- Current round state

---

# Relationship to Existing ADRs

ADR-016 does **not** replace ADR-008 through ADR-015.

Those ADRs define individual architectural capabilities.

ADR-016 defines how those capabilities are composed into immutable domain contexts that become the standard inputs to business engines.

---

# Revision History

| Version | Date | Description |
|---------|------------|--------------------------------|
| 1.0.0 | 2026-07-13 | Initial accepted architecture decision |
