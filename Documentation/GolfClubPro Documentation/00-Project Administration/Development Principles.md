
# Development Principles

## Purpose

These principles guide all GolfClubPro development decisions.

## Principles

### 1. Apple Ecosystem First

Prefer Apple-native frameworks before third-party dependencies.

### 2. Offline First

A golfer must be able to complete a round without network connectivity.

### 3. Watch First

The Apple Watch is the primary on-course interface. The iPhone is the analysis and coaching interface.

### 4. GolfCore Is Pure

GolfCore should contain golf business concepts and logic. It should avoid direct dependency on SwiftUI, WeatherKit, CloudKit, Core Location, or SwiftData where practical.

### 5. Strong Typing Over Primitive Types

Use explicit identifiers such as PlayerID, RoundID, ShotID, CourseID, and DotGolfMemberID rather than raw UUIDs or strings.

### 6. Explainable AI

Every AI Caddy recommendation should be explainable in plain language.

### 7. Documentation Before Complexity

Major architectural changes require documentation and an ADR.

### 8. Testable Core

Core logic must be unit-testable independent of the UI.

### 9. No Broken Main Branch

The main branch should always build.

### 10. Build Incrementally

### 11. Engineering Principle EP-001 — Compute Once, Reuse Many Times

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

### 12. Engineering Principle EP-002 - Engines own algorithms
#### Going forward:

* CourseSpatialIndex owns cached data.
* HoleGeometryEngine owns polygon mathematics.
* SpatialQueryEngine owns spatial reasoning.
* RecommendationEngine owns golf decisions.
* StrategyEngine owns tactical reasoning.

No engine duplicates another engine’s responsibility.
### 13. EP-003 — Learn from Facts, Recommend from Models
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
