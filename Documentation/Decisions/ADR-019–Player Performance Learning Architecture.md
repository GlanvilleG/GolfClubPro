# ADR-019: Player Performance Learning Architecture

**Document ID:** GCP-ADR-019  
**Status:** Accepted  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Decision Makers:** Solution Architecture  
**Related Documents:** ADR-016 Context-Centric Architecture, ADR-017 Course Spatial Index Architecture, ADR-018 Recommendation Context Architecture

---

# Context

The objective of GolfClubPro is to provide recommendations tailored to the individual golfer rather than relying on generic club distances.
Achieving this requires the system to continuously learn each player's actual performance over time.
Without a dedicated learning architecture, recommendation logic would become tightly coupled to statistical calculations and historical data processing.
This would reduce maintainability, make recommendations difficult to explain, and complicate future machine learning integration.

---

# Decision

GolfClubPro shall separate measurement, learning and recommendation into independent architectural responsibilities.
Measured shot outcomes shall be recorded as immutable facts.
Player capability models shall be derived from those facts.
Recommendations shall consume the derived models but shall never modify them.

---

# Architecture

```text
Shot Recorded
      │
      ▼
Shot Outcome Engine
      │
      ▼
Club Performance Engine
      │
      ▼
Player Performance Model
      │
      ▼
Recommendation Engine
      │
      ▼
AI Coach
```

---

# Architectural Layers

## Measurement
Records objective observations.
Examples:

- Carry distance
- Total distance
- Club used
- Strike location
- Wind
- Lie
- Elevation
- Shot outcome

Measurement data shall remain immutable.

---

## Learning

The Club Performance Engine derives player capability models.
Examples:

- Average carry
- Average total distance
- Dispersion
- Confidence
- Consistency
- Typical shot shape

Learning algorithms shall operate independently of recommendation logic.

---

## Recommendation

The Recommendation Engine consumes the Player Performance Model together with Recommendation Context.
Recommendation algorithms shall never modify player statistics.

---

## Explanation

The AI Coach explains recommendations and learning outcomes.
Explanation components shall not influence recommendation scoring.

---

# Player Performance Model

The Player Performance Model represents the golfer's demonstrated ability.
Each club may include:

- Average carry distance
- Average total distance
- Carry standard deviation
- Total standard deviation
- Confidence
- Shot count
- Typical shot shape
- Typical miss pattern

---

# Learning Strategy

Player learning shall use online statistical algorithms.

Preferred implementation:

- Welford's Algorithm

Reasons:

- O(1) update complexity
- Numerically stable
- Suitable for Apple Watch
- Minimal memory usage
- Deterministic behaviour

---

# Responsibilities

## Shot Outcome Engine
Owns:

- Shot measurements.
Does not own:

- Learning.
- Recommendations.

---

## Club Performance Engine

Owns:

- Statistical learning.
- Player capability models.

Does not own:

- Recommendations.

---

## Recommendation Engine

Owns:
Club selection.
- Strategy.

Does not own:

- Learning.

---

## AI Coach

Owns:

- Explanation.
- Coaching.

Does not own:

- Recommendation scoring.
- Learning algorithms.

---

# Engineering Principle EP-003

**Learn from Facts. Recommend from Models.**
Facts are immutable.
Player models are derived from facts.
Recommendations are derived from player models.
Each architectural layer owns only its own responsibility.

---

# Consequences

## Positive

- Clear separation of concerns.
- Explainable recommendations.
- Highly testable.
- Offline capable.
- Future machine learning ready.
- Stable long-term architecture.

## Negative

- Additional domain models.
- Increased persistence requirements.
- Additional statistical processing.

---

# Future Extensions

Future versions may incorporate:

- Seasonal performance trends.
- Environmental normalisation.
- Fatigue modelling.
- Equipment changes.
- Handicap progression.
- Personalised practice recommendations.
- Machine learning augmentation.

These enhancements shall consume the Player Performance Model without altering the architectural boundaries defined in this ADR.

---

# Revision History

| Version | Date | Description |
|----------|------------|---------------------------------------------|
| 1.0.0 | 2026-07-14 | Initial Player Performance Learning Architecture. |
