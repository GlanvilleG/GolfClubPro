
# ADR-021 – Human Playing Characteristics

- **Status:** Accepted
- **Date:** 2026-07-15
- **Decision Makers:** GolfClubPro Architecture Team
- **Sprint:** Sprint 9 – AI Shot Coaching Engine
- **Supersedes:** None
- **Superseded By:** None

---

# 1. Context

Personalised coaching requires knowledge about the golfer.

RecommendationEngine intentionally remains independent of player-specific learning.

Stable player characteristics are required to support coaching.

---

# 2. Decision

Introduce a HumanModel component named **PlayingCharacteristics**.

This represents long-lived characteristics of the golfer.

It is independent from round statistics and historical performance.

---

# 3. PlayingCharacteristics

The initial model includes:

- dominant hand
- dominant eye
- playing stance
- grip style
- preferred shot shape
- natural tempo
- experience level

Future additions may include:

- flexibility
- strength
- mobility
- preferred trajectory
- equipment preferences

---

# 4. Responsibilities

PlayingCharacteristics represents:

- stable player traits
- physical characteristics
- preferred playing style

It does **not** represent:

- round statistics
- confidence
- current form
- recommendation history

Those belong elsewhere.

---

# 5. HumanModel Structure

```
HumanModel
│
├── PlayingCharacteristics
├── EquipmentProfile
├── PerformanceProfile
├── LearningProfile
└── CoachingProfile
```

PlayingCharacteristics is the foundation.

---

# 6. Coaching Integration

ShotCoachingEngine consumes PlayingCharacteristics.

Example:

Right-handed golfer

↓

Ball position:

Lead (left) heel

Left-handed golfer

↓

Ball position:

Lead (right) heel

Coaching automatically adapts.

---

# 7. Recommendation Independence

RecommendationEngine shall not directly consume PlayingCharacteristics.

Recommendation remains deterministic.

HumanModel is a downstream consumer.

---

# 8. Learning

Future learning systems may update:

- preferred shot shape
- natural tempo
- coaching preferences

These updates shall not alter RecommendationEngine.

---

# 9. Commercialisation

PlayingCharacteristics supports:

- beginner coaching
- personalised coaching
- adaptive AI coaching
- practice recommendations
- equipment fitting

without affecting Recommendation.

---

# 10. Future Evolution

Future versions may include:

- biomechanical profile
- swing DNA
- injury considerations
- fatigue profile
- wearable integration
- AI-derived tendencies

---

# 11. Engineering Principles

PlayingCharacteristics shall:

- be immutable
- be independently testable
- be serialisable
- support versioning
- remain presentation independent

---

# 12. Consequences

## Positive

- Personalised coaching
- HumanModel foundation
- Future AI learning
- Equipment optimisation

## Negative

- Larger HumanModel
- Additional persistence

These costs are acceptable.

---

# 13. Status

**Accepted**

PlayingCharacteristics is established as the first component of the HumanModel and forms the foundation for personalised coaching and adaptive AI.
