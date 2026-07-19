# ADR-027: Probabilistic Shot Modelling

**Status:** Accepted

**Date:** 2026-07-19

**Authors:** GolfClubPro Architecture Team

---

# Context

Traditional golf GPS applications assume that a golfer executes every shot exactly as intended.

Recommendations are therefore based on:

- intended target
- nominal club distance
- environmental conditions

This deterministic approach fails to reflect how golf is actually played.

Professional golfers, recreational golfers and AI systems all exhibit natural shot dispersion resulting from:

- player skill
- swing consistency
- club characteristics
- environmental effects
- fatigue
- pressure
- lie quality

Consequently, strategic decisions should be based on the **probability of outcomes** rather than assuming perfect execution.

---

# Problem Statement

Consider the recommendation:

> Hit Driver 250 metres to the centre of the fairway.

A deterministic model assumes the golfer lands precisely on the intended target.

A probabilistic model recognises that the golfer is more likely to land somewhere within a distribution around the intended target.

The correct strategic question therefore becomes:

> **What is the probability that this golfer will successfully execute the intended shot?**

This represents a fundamental shift in AI decision making.

---

# Decision

GolfClubPro shall model golf shots as probability distributions rather than deterministic trajectories.

Every strategic recommendation shall consider:

- expected landing location
- lateral dispersion
- longitudinal dispersion
- directional bias
- confidence

before evaluating hazards or selecting a target.

---

# Guiding Principle

> **GolfClubPro shall evaluate the probability of outcomes rather than assume perfect execution.**

---

# Shot Dispersion Model

Each shot is represented by an expected landing point surrounded by a dispersion ellipse.

```text
                 Intended Target
                        │
                        ▼
                ─────────X─────────

             ╭────────────────────╮
          ╱                          ╲
        ╱                              ╲
       │              X                 │
        ╲                              ╱
          ╲                          ╱
             ╰────────────────────╯

        Longitudinal Dispersion

      <-------------------------->

      Lateral Dispersion
```

The ellipse represents the probability distribution of possible landing locations.

---

# Dispersion Parameters

The initial dispersion model shall include:

- expected landing point
- lateral standard deviation
- longitudinal standard deviation
- directional bias
- confidence

Future versions may include:

- non-symmetrical distributions
- shot-shape probabilities
- lie-dependent dispersion
- weather-adjusted dispersion
- fatigue modelling

---

# AI Decision Process

Recommendations shall be evaluated using the following sequence:

```text
Player Capability
        │
        ▼
Expected Shot
        │
        ▼
Shot Dispersion
        │
        ▼
Hazard Probability
        │
        ▼
Scoring Opportunity
        │
        ▼
Recommendation
```

The recommendation therefore becomes a probabilistic optimisation rather than a geometric calculation.

---

# Hazard Evaluation

Hazards shall be evaluated using probability rather than proximity.

Examples:

Instead of:

> Water is 8 metres right.

the AI evaluates:

> There is a 27% probability of entering the water.

Likewise:

Instead of:

> Fairway bunker at 215 metres.

the AI evaluates:

> There is a 9% probability of entering the bunker.

This allows strategic recommendations to be personalised to the individual golfer.

---

# Player Modelling

Dispersion shall be calculated using available player data including:

- historical shot locations
- club-specific performance
- directional tendencies
- average carry distance
- consistency
- confidence

As additional data becomes available, dispersion models become increasingly personalised.

---

# Recommendation Strategy

Target selection shall optimise expected scoring outcome rather than simply minimising distance to the hole.

Possible strategic decisions include:

- attacking a pin
- aiming for the centre of the green
- laying up short of hazards
- selecting a safer club
- avoiding one side of the fairway
- intentionally favouring the golfer's natural shot shape

---

# Interaction with Existing Architecture

Probabilistic Shot Modelling extends the Recommendation Pipeline established in ADR-026.

Recommended execution order:

```text
StrategicOptionEngine
        │
        ▼
DispersionEngine
        │
        ▼
HazardProbabilityEngine
        │
        ▼
AdaptiveCoachingEngine
        │
        ▼
WeatherAdjustmentEngine
        │
        ▼
GreenStrategyEngine
        │
        ▼
CaddyRecommendationEngine
```

Each engine contributes additional probabilistic knowledge without changing orchestration responsibilities.

---

# Explainable AI

The recommendation explanation should communicate probability rather than certainty.

Preferred explanations include:

> Aim 8 metres left of centre because your driver typically finishes 11 metres right of target.

or

> A three wood reduces your probability of reaching the bunker from 18% to 4%.

Explanations should avoid presenting uncertain outcomes as guarantees.

---

# Confidence

Each probabilistic model shall produce an independent confidence score.

Confidence shall reflect:

- quantity of historical data
- consistency of player performance
- environmental certainty
- model quality

Overall recommendation confidence is derived from the combined confidence of contributing models.

---

# Data Evolution

The probabilistic model is expected to improve continuously.

Sources include:

- completed rounds
- launch monitor calibration
- GPS shot tracking
- manual corrections
- historical statistics

Older observations may be weighted less heavily than recent performance to reflect changes in the golfer's game.

---

# Extensibility

Future enhancements may include:


- Gaussian mixture models
- Bayesian shot prediction
- Monte Carlo hole simulations
- reinforcement learning
- tournament-specific risk profiles
- pressure modelling
- lie-dependent distributions
- machine-learned player archetypes

The architecture shall remain sufficiently modular to support increasingly sophisticated statistical models without changing pipeline orchestration.

---

# Consequences

## Advantages

- Realistic golf strategy
- Personalised recommendations
- Better hazard avoidance
- Explainable AI decisions
- Continuous learning
- Scalable architecture
- Strong separation between modelling and orchestration

## Trade-offs

- Increased computational complexity
- Additional domain models
- More statistical calculations
- Larger historical data requirements

These trade-offs are accepted because they significantly improve recommendation quality and align with the long-term AI objectives of GolfClubPro.

---

# Relationship to Other ADRs

| ADR | Relationship |
|------|--------------|
| ADR-004 | Uses strongly typed identifiers throughout probabilistic models. |
| ADR-006 | Enables efficient on-device execution within the Watch-first architecture. |
| ADR-023 | Integrates as a specialised AI pipeline within the Multi-Pipeline Product Architecture. |
| ADR-025 | Consumes immutable provider-independent decision snapshots. |
| ADR-026 | Extends the Recommendation Pipeline by introducing probabilistic reasoning as a dedicated modelling stage. |

---

# Future Work

The implementation of this ADR is expected to introduce new domain models and engines, including:

- `ShotDispersionModel`
- `DispersionEngine`
- `HazardProbabilityEngine`
- `ShotShapePredictionEngine`
- `GreenStrategyEngine`
- `ProbabilityDistribution` abstractions
- `MonteCarloSimulationEngine` (future)

---

## Architectural Principle

> **Golf is a game of probabilities, not certainties. GolfClubPro models the likelihood of outcomes, enabling AI recommendations that reflect how golfers actually play rather than how they intend to play.**

