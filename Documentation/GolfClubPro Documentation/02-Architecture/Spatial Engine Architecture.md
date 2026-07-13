# Spatial Engine Architecture

**Document ID:** GCP-ARCH-003  
**Status:** Draft  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Owner:** Solution Architecture  
**Related Documents:** ADR-016 Context-Centric Architecture, ADR-006 Watch-First Architecture

---

# Purpose

The Spatial Engine is responsible for transforming raw location observations into a rich, immutable understanding of the golfer's current surroundings.
It provides a single source of spatial truth for GolfClubPro and supplies contextual information to every subsystem requiring knowledge of the course, the golfer's position and the playing environment.
The Spatial Engine intentionally contains **no user interface logic** and **no business workflow logic**. Its responsibility is to understand **where the golfer is**, **what surrounds them**, and **what spatial context currently exists**.

---

# Design Goals

The Spatial Engine has been designed around several principles:

- Build spatial indexes once.
- Perform O(1) lookups wherever practical.
- Avoid repeated geometric calculations.
- Keep algorithms deterministic.
- Support Apple Watch battery efficiency.
- Support future AI reasoning.
- Keep spatial computation independent of orchestration.

---

# High Level Architecture

```text
GPS Observation
        │
        ▼
Apple Location Provider
        │
        ▼
GolfClubLocationCoordinator
        │
        ├──────────────► RoundOrchestrator
        │                      │
        │                      ▼
        │              Active Round State
        │
        ▼
RoundSession
        │
        ▼
RoundSpatialContextInput
        │
        ▼
RoundSpatialContextBuilder
        │
        ▼
RoundSpatialContext
        │
 ┌──────┼───────────────┐
 ▼      ▼               ▼
Lie   Distances     Hazards
        │
        ▼
Recommendation Engine
        │
        ▼
Voice Coach
```

---

# Responsibilities

## Apple Location Provider

Responsible for:

- Receiving Core Location updates.
- Providing timestamped observations.
- Reporting GPS accuracy.
- Remaining platform-specific.

The provider does **not** understand golf.

---

## GolfClubLocationCoordinator

Responsible for:

- Receiving location observations.
- Detecting golf clubs.
- Detecting tee locations.
- Publishing observations.
- Publishing orchestrator outputs.

The coordinator owns the observation stream but does not perform spatial reasoning.

---

## RoundSession

Responsible for:

- Runtime coordination.
- Current active round.
- Receiving observations.
- Building spatial context.
- Exposing current spatial context to the application.

RoundSession does **not** perform geometry calculations.

---

## CourseSpatialIndex

The CourseSpatialIndex is the canonical in-memory representation of a course.

Its purpose is to eliminate repeated searching during a round.

### Current responsibilities

- Hole lookup by ID
- Tee lookup
- Green lookup
- Hole geometry lookup
- Distance calculations

### Future responsibilities

- Bounding boxes
- Spatial grids
- R-tree indexing
- KD-tree nearest neighbour search
- Hazard lookup
- Pin locations
- Dynamic pin positions
- Temporary course modifications

The index is created once when a course is loaded.

---

## RoundSpatialContextInput

The input object forms the contract between application state and spatial computation.

It contains only the information required by the spatial engine.

Current members include:

- Current Hole ID
- Golfer Position
- Observation Time
- Course Spatial Index

Additional context may be added in future without changing the builder interface.

Examples include:

- Wind
- Weather
- Pin Position
- Competition Format
- Course Conditions

---

## RoundSpatialContextBuilder

The builder transforms the input into a complete spatial understanding.

It owns no mutable state.

It performs:

- Hole lookup
- Distance calculations
- Geometry evaluation
- Lie detection
- Boundary evaluation
- Context construction

The builder produces a single immutable RoundSpatialContext.

---

# RoundSpatialContext

RoundSpatialContext is the canonical representation of the golfer's current spatial situation.

It is intentionally immutable.

Typical information includes:

- Current hole
- Hole confidence
- Hole area
- Playable lie
- Distance to tee
- Distance to green
- Remaining distance
- Distance to nearest boundary
- Confirmation requirements

Every downstream subsystem consumes the same context object.

---

# Geometry Evaluation

Geometry evaluation determines where the golfer is within a hole.

Current supported areas include:

- Tee
- Fairway
- Rough
- Green
- Fringe
- Bunker
- Water
- Trees
- Penalty Area
- Cart Path
- Native Area
- Out of Bounds

Future geometry types may be added without affecting consumers.

---

# Lie Detection

Lie detection maps geometry into a golfing interpretation.

Examples include:

| Hole Area | Playable Lie |
|------------|--------------|
| Tee | Tee |
| Fairway | Fairway |
| Rough | Rough |
| Green | Green |
| Fringe | Fringe |
| Bunker | Fairway Bunker or Greenside Bunker |
| Water | Penalty Area |
| Out of Bounds | Out of Bounds |

Lie detection is deterministic.

---

# Performance Strategy

The Spatial Engine follows a "Compute Once, Reuse Many Times" philosophy.

Strategies include:

- Immutable data structures
- Cached dictionaries
- O(1) hole lookup
- Cached tee coordinates
- Cached green coordinates
- Cached geometry
- Minimal allocations
- Lazy evaluation
- Deterministic algorithms

This reduces CPU usage and improves Apple Watch battery life.

---

# Future Spatial Services

The Spatial Engine is expected to grow to include:

## Hazard Engine

Provides:

- Nearest hazard
- Hazard entry point
- Carry distance
- Layup distance

---

## Green Engine

Provides:

- Front distance
- Centre distance
- Back distance
- Green width
- Green depth

---

## Shot Corridor Engine

Provides:

- Fairway width
- Landing area
- Safe miss zones
- Obstruction detection

---

## Wind Engine

Provides:

- Effective wind
- Crosswind
- Headwind
- Tailwind
- Club adjustment

---

## Strategy Engine

Provides:

- Layup recommendation
- Aggressive line
- Conservative line
- Risk analysis
- Expected strokes

---

## Recommendation Engine

Consumes RoundSpatialContext together with:

- Player profile
- Club distances
- Historical dispersion
- Wind
- Elevation
- Match situation

Outputs:

- Recommended club
- Aim point
- Shot type
- Confidence
- Explanation

---

# Future AI Integration

The Spatial Engine intentionally produces a rich context object suitable for AI reasoning.

Future AI services should consume RoundSpatialContext rather than individual GPS observations.

This ensures:

- Consistent reasoning
- Reduced duplicate computation
- Easier testing
- Explainable recommendations

---

# Design Principles

The Spatial Engine shall:

- Remain platform independent.
- Remain deterministic.
- Avoid UI dependencies.
- Avoid orchestration dependencies.
- Avoid network dependencies.
- Avoid mutable global state.
- Be fully unit testable.
- Prefer composition over inheritance.

---

# Architectural Benefits

The Spatial Engine provides:

- Single spatial source of truth.
- Consistent behaviour across iPhone and Apple Watch.
- Efficient lookup performance.
- Reduced battery consumption.
- High testability.
- Extensible architecture.
- AI-ready contextual model.
- Separation of responsibilities.

---

# Revision History

| Version | Date | Description |
|----------|------------|--------------------------------|
| 1.0.0 | 2026-07-14 | Initial Spatial Engine architecture. |
