
# ADR-010: Strategic Route and Target Planning

**Document ID:** GCP-ADR-010  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Data Model, Course Geometry, AI Caddy Design  
**Related ADRs:** ADR-003 Domain-Driven Design, ADR-008 GPS and Golf Club Detection, ADR-009 Course Geometry and Lie Detection

---

# Context

A golfer should not always aim directly at the hole or pin.

The correct direction of play may depend on:

- Hole shape
- Doglegs
- Fairway landing areas
- Trees
- Bunkers
- Water hazards
- Out-of-bounds areas
- Ball lie
- Player capability
- Wind
- Preferred position for the next shot
- Safe miss areas

GolfClubPro therefore needs to distinguish between the final destination and the immediate target for the next shot.

A recommendation engine that only calculates the direct bearing and distance to the pin would produce poor advice on shaped holes, recovery shots, lay-ups, and risk-sensitive situations.

---

# Decision

GolfClubPro will use a strategic route and target planning model.

The system will distinguish between:

1. **Final destination**  
   The hole or pin.

2. **Playing route**  
   One or more strategic positions leading toward the final destination.

3. **Immediate target**  
   The location the golfer should aim toward for the next stroke.

4. **Shot plan**  
   The club, bearing, distance, target and rationale for the next shot.

The pin must not automatically become the immediate target.

---

# Domain-Driven Design Decision

Strategic planning will become its own domain capability within GolfCore.

The preferred package organisation is:

```text
GolfCore/
├── Player/
├── Course/
├── Round/
├── Strategy/
├── Recommendation/
├── Analytics/
├── Integrations/
└── Shared/
```

The `Strategy` domain will own route and target concepts.

The `Recommendation` domain will consume strategy outputs and combine them with player performance, weather and historical data.

---

# Core Domain Concepts

## TargetPoint

A specific location that may be selected as the next intended destination.

Target types may include:

- Pin
- Green centre
- Landing zone
- Lay-up
- Bail-out
- Recovery
- Safe miss

---

## PlayingRoute

A planned sequence of target points leading from the current ball position to the hole.

A route may be:

- Direct
- Positional
- Conservative
- Aggressive
- Recovery

---

## LandingZone

A mapped area where the ball may preferably finish.

A landing zone may be defined by:

- Centre point
- Boundary
- Preferred shot number
- Strategic priority
- Risk rating
- Recommended approach angle

---

## ShotPlan

The immediate recommended play.

A ShotPlan may include:

- Aim point
- Bearing
- Target distance
- Preferred club
- Alternative club
- Route strategy
- Risk level
- Confidence
- Rationale

---

## HoleStrategyGeometry

The strategic interpretation of a hole.

It may include:

- Hole centre line
- Landing zones
- Safe corridors
- Hazards
- Bail-out areas
- Green centre
- Pin location
- Preferred approach positions

---

# Route Planning Rules

The route planner should evaluate whether a direct shot is appropriate.

A direct route may be rejected when:

- The target is beyond the player's reliable range.
- A hazard blocks the shot corridor.
- The fairway shape requires positional play.
- Trees obstruct the direct path.
- The current lie restricts shot choice.
- The player's dispersion creates excessive risk.
- Wind makes the direct route unsuitable.
- A lay-up provides a better next-shot position.

---

# Target Hierarchy

The system should generally prefer targets in this order:

```text
Safe playable target
Preferred landing zone
Green centre
Pin location
```

The exact priority depends on the current shot context.

The pin may become the immediate target when:

- The green is reachable.
- The route is clear.
- Risk is acceptable.
- The player's expected dispersion is suitable.
- The current lie supports the required shot.

---

# Obstacle Evaluation

Strategic planning should consider whether the intended shot corridor intersects:

- Trees
- Bunkers
- Water
- Out of bounds
- Penalty areas
- Narrow fairway sections
- Unplayable terrain

The obstacle evaluator should assess both:

- Direct intersection risk
- Expected dispersion risk

---

# Future Positioning

The system should evaluate not only whether the current shot is safe, but also whether the landing position creates a favourable next shot.

Examples:

- Preferred approach distance
- Better angle into the green
- Avoiding a blocked side of the fairway
- Leaving an uphill putt
- Avoiding a short-sided miss

---

# Architecture

```text
Current Ball Position
        │
        ▼
Course Geometry
        │
        ▼
Obstacle Evaluation
        │
        ▼
Candidate Landing Zones
        │
        ▼
Route Planning
        │
        ▼
Target Selection
        │
        ▼
Shot Plan
        │
        ▼
Recommendation Engine
        │
        ▼
AI Caddy Explanation
```

---

# Service Responsibilities

## RoutePlanner

Generates candidate routes from the current ball position to the hole.

## ObstacleEvaluator

Evaluates hazards and blocked corridors.

## TargetSelector

Selects the preferred immediate target.

## ShotPlanner

Converts the selected target into distance, bearing, club options and rationale.

## RecommendationEngine

Combines the ShotPlan with player history, wind, lie and confidence.

---

# GolfCore Boundary

GolfCore may own:

- Strategy models
- Route rules
- Geometry evaluation
- Target selection
- Bearing and distance logic

GolfCore should not directly depend on:

- MapKit
- Core Location
- WeatherKit
- SwiftUI

Platform services should translate Apple framework data into GolfCore domain types.

---

# Consequences

## Positive

- More realistic golf advice
- Supports doglegs and lay-ups
- Enables hazard avoidance
- Supports recovery play
- Improves future AI recommendations
- Separates strategic route choice from club selection

## Negative

- Requires richer course geometry
- Requires mapped landing zones
- Introduces additional domain models
- Requires more testing and calibration

---

# Implementation Sequence

The initial implementation should introduce:

1. `TargetPoint`
2. `TargetPointType`
3. `RouteStrategy`
4. `PlayingRoute`
5. `LandingZone`
6. `HoleStrategyGeometry`
7. `ShotPlan`
8. `ObstacleEvaluator`
9. `RoutePlanner`
10. `TargetSelector`

The first version should remain deterministic and explainable.

Machine learning may influence route scoring later but should not replace the core strategy model.

---

# Testing Requirements

Tests should include:

- Direct route to green
- Dogleg requiring an intermediate target
- Lay-up before a water hazard
- Recovery route from trees
- Safe target selection near out of bounds
- Landing-zone selection based on club range
- Alternative route generation
- Route rejection due to obstacles

---

# Documentation Impact

This decision requires updates to:

- Domain Model
- Data Model
- System Architecture
- AI Caddy Design
- Course Geometry
- Testing Strategy
- Domain Glossary

---

# Future Considerations

Future versions may include:

- Player-specific route scoring
- Dispersion-aware shot corridors
- Wind-adjusted route planning
- Elevation-aware landing zones
- Green slope and pin-access modelling
- Strokes-gained-based strategy
- Tournament-risk profiles
- Coach-defined strategy plans
- Course simulation

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
