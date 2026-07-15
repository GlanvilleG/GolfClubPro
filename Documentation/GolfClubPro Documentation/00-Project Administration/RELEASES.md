
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
