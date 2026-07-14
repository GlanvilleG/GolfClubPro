# ADR-017: Course Spatial Index Architecture

**Document ID:** GCP-ADR-017  
**Status:** Accepted  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Decision Makers:** Solution Architecture  
**Related Documents:** ADR-016 Context-Centric Architecture, GCP-ARCH-003 Spatial Engine Architecture

---

# Context

GolfClubPro continuously processes GPS observations while a golfer moves around the course. During a round, spatial information is required by numerous subsystems including:

- Hole detection
- Distance calculations
- Lie detection
- Geometry evaluation
- Recommendation Engine
- AI Coach
- Voice Assistant
- Hazard analysis
- Strategy Engine

A naïve implementation repeatedly searches collections of holes and associated geometry whenever new observations arrive.
Although an individual course contains relatively few holes, these searches occur at a high frequency throughout an entire round and become increasingly expensive as additional spatial capabilities are introduced.
Furthermore, multiple spatial services require access to the same course information, leading to duplicated lookup logic and inconsistent responsibilities.

---

# Decision

GolfClubPro will introduce a **CourseSpatialIndex** as the canonical in-memory representation of a loaded golf course.
The index will be constructed once when a course is loaded and will provide constant-time lookup of all frequently accessed spatial information.
All spatial services will obtain course information exclusively through the CourseSpatialIndex.

---

# Responsibilities

The CourseSpatialIndex is responsible for:

- Hole lookup by HoleID
- Tee location lookup
- Green location lookup
- Hole geometry lookup
- Cached spatial data
- Efficient distance queries
- Spatial indexing support

The index is **not** responsible for:

- Hole detection
- GPS processing
- Round orchestration
- User interface logic
- Recommendation logic
- AI reasoning

---

# Architectural Position

```text
Course Catalogue
        │
        ▼
CourseSpatialIndex
        │
        ├───────────────┐
        ▼               ▼
RoundSpatialContextBuilder
        │
        ▼
RoundSpatialContext
        │
 ┌──────┼───────────────┐
 ▼      ▼               ▼
Lie   Distances     Geometry
        │
        ▼
Recommendation Engine
```

---

# Design Principles

The CourseSpatialIndex shall:

- Be immutable after construction.
- Be created once per loaded course.
- Provide O(1) lookups wherever practical.
- Hide internal storage structures.
- Remain independent of application state.
- Remain independent of UI frameworks.
- Remain deterministic.
- Be fully unit testable.

---

# Current Contents

The initial implementation contains cached access to:

- Hole objects
- Tee locations
- Green locations
- Hole geometry

The implementation uses dictionaries internally to provide constant-time lookup by HoleID.

---

# Future Expansion

The CourseSpatialIndex is designed to evolve without changing its public responsibilities.
Planned additions include:

## Spatial Bounding Boxes

Each hole will expose a pre-computed bounding rectangle allowing rapid rejection of distant geometry.

---

## Hazard Index

Cached access to:

- Bunkers
- Water hazards
- Penalty areas
- Trees
- Native areas

---

## Green Model

Cached information including:

- Front
- Centre
- Back
- Green dimensions
- Pin locations

---

## Spatial Grid

A regular grid may be introduced to reduce candidate geometry before polygon testing.

---

## R-tree

If future course models become substantially more detailed, an R-tree may replace simple dictionaries for geometry lookup while preserving the public API.

---

## KD-tree

Nearest-neighbour searches may be accelerated using a KD-tree for:

- Hole proximity
- Hazard proximity
- Green proximity
- Landing area searches

---

# Performance Considerations

The introduction of the CourseSpatialIndex reduces repeated computation during a round.

Instead of:

```text
GPS Observation
        │
Repeated Array Search
        │
Geometry Search
        │
Distance Calculation
```

the runtime becomes:

```text
GPS Observation
        │
O(1) Hole Lookup
        │
Cached Geometry
        │
Distance Calculation
```

This significantly reduces CPU usage during continuous GPS tracking.

---

# Apple Watch Considerations

The CourseSpatialIndex supports the watch-first architecture by:

- Reducing repeated allocations.
- Minimising collection traversal.
- Reducing CPU utilisation.
- Improving battery efficiency.
- Supporting deterministic execution.

The index is intended to remain resident in memory for the duration of an active round.

---

# Relationship to ADR-016

ADR-016 established the Context-Centric Architecture in which all golf intelligence is derived from a common contextual model.

The CourseSpatialIndex provides the spatial foundation that enables efficient construction of that context.

The relationship is therefore:

```text
CourseSpatialIndex
        │
        ▼
RoundSpatialContextBuilder
        │
        ▼
RoundSpatialContext
        │
        ▼
Golf Intelligence
```

---

# Consequences

## Positive

- Single source of spatial truth.
- Constant-time hole lookup.
- Reduced CPU utilisation.
- Reduced battery consumption.
- Simplified spatial services.
- Improved separation of responsibilities.
- Easier unit testing.
- Stable foundation for future AI capabilities.

## Negative

- Slight increase in memory usage.
- Additional index construction during course loading.
- New component requiring maintenance.

These trade-offs are considered acceptable given the significant runtime performance improvements.

---

# Alternatives Considered

## Direct Array Searching

Rejected because repeated linear searches would occur throughout every round.

---

## Multiple Independent Caches

Rejected because duplicated caches create inconsistent behaviour and increase maintenance complexity.

---

## Database-backed Spatial Queries

Rejected because all spatial computation during a round should remain fully offline and deterministic.

---

# Implementation Guidance

All future spatial services should depend upon the CourseSpatialIndex rather than directly traversing course collections.
New spatial capabilities should extend the index rather than introducing additional lookup structures elsewhere in the system.

---

# Revision History

| Version | Date | Description |
|----------|------------|------------------------------------------|
| 1.0.0 | 2026-07-14 | Initial Course Spatial Index architecture decision. |
