# Engineering Principles

## Purpose

## Core Principles

### 1. Engineering Principle EP-001 — Compute Once, Reuse Many Times
optimize for:
1. O(1) lookups wherever practical.
2. Immutable objects.
3. Pre-computed indexes.
4. Lazy evaluation.
5. Cache expensive calculations.
6. Avoid repeated allocation.
7. Keep watch-side algorithms deterministic.
8. Move expensive work to the iPhone where appropriate.
Every milestone should produce a working, testable application.

### 2. Engineering Principle EP-002 - Engines own algorithms
#### Going forward:

* CourseSpatialIndex owns cached data.
* HoleGeometryEngine owns polygon mathematics.
* SpatialQueryEngine owns spatial reasoning.
* RecommendationEngine owns golf decisions.
* StrategyEngine owns tactical reasoning.

No engine duplicates another engine’s responsibility.
### 3. EP-003 — Learn from Facts, Recommend from Models
The project should separate measurement from decision-making.
Shot recorded
        │
        ▼
ClubPerformanceEngine
        │
        ▼
Player Model
        │
        ▼
RecommendationEngine
        │
        ▼
AI Coach


### 4. EP-004 - Preserve Raw Facts
Every statistic in the HumanModel should be derived from recorded shot facts, never entered manually or modified directly. If a statistic is wrong, the source facts are corrected and the model is recomputed or incrementally updated.
- Recorded observations are immutable.
- Models are derived from observations.
- Recommendations are derived from models.
- Facts are never altered to improve recommendations.

### 5. EP-005 — Store Sufficient Statistics
#### Principle
Where continuous statistical learning is required, store the minimum sufficient statistics needed to derive metrics rather than storing redundant calculated values.
#### Rationale
Derived values such as averages and standard deviations can always be recomputed from sufficient statistics. This guarantees consistency, enables O(1) updates, reduces storage requirements, and prevents derived values becoming inconsistent.
#### Examples

* ClubPerformance
* Future PuttingPerformance
* DrivingPerformance
* DispersionModel

### EP-006 — Compose Algorithms from Small, Testable Components
#### Principle
Complex domain algorithms shall be assembled from specialised algorithmic components, each with a single mathematical or domain responsibility.
#### Rationale
Small components are easier to verify, reuse, optimise, and replace independently. Domain engines should orchestrate algorithms rather than embed them.
#### Examples

* ClubLearningEngine composes:
    * WelfordAccumulator
    * ConfidenceCalculator
* RecommendationEngine composes:
    * SpatialRiskEvaluator
    * StrategyEngine
    * future WindAdjustmentEngine

## Production and Test Structure

The repository shall maintain a mirrored structure between production code and its corresponding test code wherever practical.
Each production bounded context shall have a matching test bounded context.
Example:

```
GolfCore
│
├── Human
│   ├── Coaching
│   ├── Model
│   ├── Learning
│   └── Performance
│
GolfCoreTests
│
├── Human
│   ├── Coaching
│   ├── Model
│   ├── Learning
│   └── Performance
```

Benefits include:

- predictable navigation
- simplified maintenance
- clear subsystem ownership
- improved discoverability
- scalable repository organisation

Every production class should have a corresponding test class where appropriate.
Test files shall use the naming convention:

```
<ClassName>Tests.swift
```
The test hierarchy shall mirror the production hierarchy rather than grouping tests by implementation type.

## Coding Principles

CP-001 Prefer Explicit Domain States

CP-002 Immutable Context

CP-003 Value Types First

CP-004 Platform Independent Domain

### CP-005 — Expose Domain Concepts, Hide Algorithm State
#### Principle
Public APIs shall expose domain concepts rather than algorithm implementation details.
Internal algorithm state shall remain encapsulated within the owning domain model or engine.
#### Rationale
Consumers of the domain model should interact using golfing terminology rather than statistical implementation details. This allows learning algorithms to evolve independently without breaking dependent systems.
#### Example
Instead of exposing: carryMean, carryM2, totalMean, totalM2
the public API exposes: averageCarryMeters, averageTotalMeters, carryStandardDeviation, confidence
#### The Recommendation Engine should never know whether those values come from:

* Welford’s Algorithm
* Bayesian estimation
* Machine Learning
* Kalman filtering
* Future hybrid models

# Architecture Principles

AP-001 Context-Centric Architecture

AP-002 Separation of Facts, Models and Decisions

AP-003 Composition over Inheritance

## Performance Principles

PP-001 Optimise Algorithms Before Hardware

PP-002 Cache Stable Data

PP-003 O(1) Where Practical

### AP-004 — Stable Foundation APIs
#### Principle
Reusable mathematical and foundational domain components shall maintain stable public interfaces once validated.
#### Rationale
Higher-level components should depend on stable contracts rather than evolving implementations. This minimises refactoring and enables independent optimisation of foundational algorithms.
#### Examples

* WelfordAccumulator
* DistanceCalculator
* PolygonGeometry
* GeometryProjection

## Testing Principles

TP-001 Test Behaviour, Not Implementation

TP-002 Deterministic Results

TP-003 Domain Before UI

TP-004 Regression First

### TP-005 – Mathematical Foundations Require Independent Verification
Any reusable mathematical component shall be verified against independently calculated reference results or published datasets.
**That means:**

* Welford compared to batch statistics.
* Distance calculations compared to known geodesic results.
* Recommendation probabilities compared to deterministic fixtures.



### 
