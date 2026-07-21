
# ADR-020 – AI Shot Coaching Architecture

- **Status:** Accepted
- **Date:** 2026-07-15
- **Decision Makers:** GolfClubPro Architecture Team
- **Sprint:** Sprint 9 – AI Shot Coaching Engine
- **Supersedes:** None
- **Superseded By:** None

---

# 1. Context

GolfClubPro has evolved beyond a golf GPS and recommendation application.

The Recommendation subsystem determines **what** shot should be played.

Golfers also require assistance with **how** to execute that shot.

Professional golfers rely upon caddies and coaches who provide:

- setup reminders
- alignment advice
- swing thoughts
- confidence reinforcement
- common mistakes
- course management advice

These responsibilities are fundamentally different from recommendation logic.

---

# 2. Problem

RecommendationEngine was beginning to accumulate coaching behaviour.

This would violate:

- Single Responsibility Principle
- Separation of Concerns
- Deterministic Recommendation Pipeline

Recommendation and Coaching must remain independent.

---

# 3. Decision

Introduce an independent **ShotCoachingEngine**.

Recommendation remains deterministic.

ShotCoachingEngine consumes Recommendation outputs but never modifies them.

---

# 4. Coaching Pipeline

```
RecommendationDecision
        │
        ▼
ShotContext
        │
        ▼
HumanModel
        │
        ▼
CoachingConfiguration
        │
        ▼
ShotCoachingEngine
        │
        ▼
ShotPreparationAdvice
```

---

# 5. Responsibilities

Recommendation answers:

> What should the golfer do?

Coaching answers:

> How should the golfer execute the shot?

---

# 6. ShotPreparationAdvice

The coaching subsystem produces immutable coaching guidance.

Includes:

- setup
- alignment
- swing keys
- tempo reminders
- confidence reminders
- common mistakes
- player-specific adjustments

---

# 7. Coaching Levels

Supported coaching levels:

- Off
- Essentials
- Standard
- Professional
- Adaptive AI

---

# 8. Delivery Modes

Supported delivery modes:

- Apple Watch
- iPhone
- Voice
- Post-round Review

---

# 9. Commercialisation

Coaching is intentionally separated from Recommendation.

This enables:

- Free Recommendation
- Premium Coaching
- Professional Coaching
- Enterprise Coaching

without changing RecommendationEngine.

---

# 10. Future Evolution

ShotCoachingEngine will evolve into an adaptive coaching engine using HumanModel and historical player performance.

Recommendation remains deterministic.

Coaching becomes personalised.

---

# 11. Consequences

## Positive

- Clear separation
- Commercial flexibility
- Independent testing
- Scalable coaching

## Negative

- Additional subsystem
- More domain models

These costs are acceptable.

---

# 12. Status

**Accepted**

Shot Coaching is established as an independent subsystem and shall never become part of RecommendationEngine.

class RecommendationEngine {
    // MARK: - Properties
    var recommendations: [Recommendation] = []
    var explanations: [RecommendationExplanation] = []
    
    // MARK: - Methods
    
    func generateRecommendations(for user: User) {
        // Logic to generate recommendations
        // ...
    }
    
    func presentRecommendation(_ recommendation: Recommendation) -> String {
        // Convert structured explanation to human-readable string
        // ...
        return ""
    }
    
    // ADR ALIGNMENT UPDATE 20-07-2026
    
    /// ## Structured Explanations and Rendering
    ///
    /// Recommendation explanations should be constructed as structured domain objects (e.g., RecommendationExplanation)
    /// and only rendered into human-readable strings for persistence or presentation. The structured form remains
    /// the source of truth for reasoning and auditing.
}
