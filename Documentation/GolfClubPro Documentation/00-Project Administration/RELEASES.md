
# GolfClubPro Releases

---

# v0.8.5 — Recommendation Architecture Stabilised

**Status**

Released

**Date**

2026-07-15

---

## Highlights

- Recommendation Engine fully decomposed into specialised engines and builders.
- Structured Recommendation Explanation introduced.
- Recommendation Audit Builder introduced.
- Recommendation Pipeline formally documented.
- Stable Recommendation API established.

---

## Architecture

The Recommendation subsystem is now considered architecturally stable.

Core components:

- StrategyEngine
- ClubScoringEngine
- RecommendationSorter
- RecommendationExplanationBuilder
- RecommendationAuditBuilder

RecommendationEngine now performs orchestration only.

---

## Engineering

- Recommendation subsystem refactored.
- Recommendation explanations structured.
- Environmental explanation model introduced.
- Audit subsystem extracted.
- Recommendation API stabilised.

---

## Testing

- All GolfCore tests passing.
- Recommendation subsystem fully regression tested.

---

## Documentation

Published:

- ADR-020
- ADR-021
- ADR-022

Updated:

- CHANGELOG
- Engineering Principles
- Definition of Done

---

## Next Milestone

v0.9.0

AI Shot Coaching Engine

- CoachingConfiguration
- ShotCoachingEngine
- PlayingCharacteristics
- HumanModel foundation
- Personalised coaching

# v0.10.7 — Explainability Engine

**Release Date:** 2026-07-23

## Overview

Sprint 10.7 introduces the **Explainability Engine**, establishing a deterministic explanation layer that transforms recommendation outcomes into structured, auditable reasoning.

This release separates **decision making** from **decision explanation**, enabling future narration, coaching, post-round analysis, and conversational AI without changing the recommendation engine itself.

---

## Highlights

### Explainability Engine

- Introduced `ExplainabilityEngine`.
- Added immutable `RecommendationExplanation`.
- Added structured explanation evidence.
- Added deterministic explanation ordering.
- Added confidence and uncertainty reporting.
- Added support for explaining:
  - Preferred club
  - Alternative clubs
  - Aim strategy
  - Route strategy
  - Environmental influences
  - Player performance influences
  - Spatial risk
  - Strategic reasoning

### Recommendation Pipeline

- Integrated Explainability as a downstream consumer of `RecommendationDecision`.
- Preserved deterministic recommendation behaviour.
- Maintained complete separation between recommendation generation and explanation.

### Recommendation Auditing

- Extended recommendation auditing to include structured explanation output.
- Improved traceability for debugging and post-round analysis.
- Established the foundation for future coaching and recommendation replay.

### Testing

Added comprehensive test coverage for:

- Explanation generation
- Evidence extraction
- Deterministic ordering
- Confidence reporting
- Alternative recommendation explanations
- Audit integration
- Regression testing to ensure recommendation outputs remain unchanged

---

## Documentation

Created

- ADR-033 – Explainability Architecture

Updated

- CHANGELOG.md
- Architectural Evolution.md
- Component Architecture.md
- System Architecture.md
- Architecture.md
- Recommendation Pipeline documentation

---

## Architectural Impact

The runtime architecture now follows a clear layered model:

```text
Recommendation Pipeline
        │
        ▼
RecommendationDecision
        │
        ▼
ExplainabilityEngine
        │
        ▼
RecommendationExplanation
        │
        ├───────────────┐
        │               │
        ▼               ▼
Recommendation Audit   Future Narration
```

This release reinforces the project's architectural principles:

- Deterministic decision making
- Explainable recommendations
- Immutable domain models
- Offline-first operation
- Domain-driven design
- Platform-independent business logic
- Clear separation of concerns

---

## Compatibility

This release introduces no breaking changes.

Recommendation behaviour remains unchanged.

The Explainability Engine derives explanations from existing deterministic recommendation outputs.

---

## Known Limitations

- Natural-language narration is not yet implemented.
- Adaptive coaching is planned for a future release.
- Conversational AI remains a future architectural capability.

---

## Next Milestone

**Sprint 10.8 – Recommendation Narration**

The next sprint will introduce a Narration Engine that transforms structured explanations into concise, golfer-friendly communication while preserving the deterministic reasoning produced by the Explainability Engine.
