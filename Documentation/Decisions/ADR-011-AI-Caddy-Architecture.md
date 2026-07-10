
# ADR-011: AI Caddy Architecture

**Document ID:** GCP-ADR-011  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** AI Caddy Design, Domain Model, Data Model, Strategic Route and Target Planning, Recommendation Engine  
**Related ADRs:** ADR-003 Domain-Driven Design, ADR-006 Watch-First Architecture, ADR-008 GPS and Golf Club Detection, ADR-009 Course Geometry and Lie Detection, ADR-010 Strategic Route and Target Planning

---

# Context

GolfClubPro is intended to provide personalised, explainable on-course advice.

The AI Caddy must consider:

- Current ball position
- Remaining distance
- Hole geometry
- Route strategy
- Hazards
- Playable lie
- Player equipment
- Historical club performance
- Common miss patterns
- Wind
- Elevation
- Temperature
- Confidence in available data
- Risk of the intended shot
- Preferred position for the following shot

The system must support useful recommendations before sufficient player history exists and improve as more data becomes available.

A purely machine-learning approach would be difficult to explain, test and trust during early development.

A purely rules-based approach would be predictable but may not fully adapt to each golfer over time.

---

# Decision

GolfClubPro will use a **hybrid AI Caddy architecture**.

The architecture will combine:

1. Deterministic golf rules
2. Course strategy logic
3. Player performance statistics
4. Learned player behaviour
5. Optional language-model explanation
6. Human confirmation and correction

The deterministic recommendation engine remains the authoritative decision-support foundation.

Machine-learning and generative-AI components may enhance scoring, personalisation and explanation, but must not replace core safety, state and validation rules.

---

# Architecture Principles

## Explainability

Every recommendation must be traceable to identifiable inputs.

Examples include:

- Target distance
- Adjusted club carry
- Wind effect
- Current lie
- Recent miss pattern
- Route risk
- Hazard intersection
- Recommendation confidence

The system should be able to answer:

- Why this club?
- Why this target?
- Why this direction?
- Why this level of confidence?
- What alternatives were considered?

---

## Deterministic Core

Core recommendation logic should remain deterministic and testable.

The deterministic core includes:

- Route planning
- Target selection
- Obstacle evaluation
- Distance calculation
- Lie suitability
- Wind adjustment
- Elevation adjustment
- Club scoring
- Risk classification
- State validation

These functions belong in GolfCore.

---

## Learning as an Enhancement

Learned player behaviour may modify deterministic scores.

Examples include:

- Actual club carry
- Shot dispersion
- Frequent push or pull
- Short or long tendency
- Lie-specific performance
- Wind-specific performance
- Confidence based on sample size

Learned adjustments should remain bounded so they cannot silently override core constraints.

---

## Generative AI as an Explanation Layer

A language model may convert structured recommendation data into natural language.

Example:

> Use the 6 iron and aim slightly left of the landing zone. Your recent 7-irons from light rough have tended to finish short and right, and the headwind reduces expected carry.

The language model should explain a structured recommendation rather than invent one independently.

---

# Layered Architecture

```text
Location, Weather, Course Data, Player History
                    │
                    ▼
              ShotContext
                    │
                    ▼
          Strategic Route Planning
                    │
                    ▼
        Deterministic Recommendation
                    │
                    ▼
      Personalisation and Learning Layer
                    │
                    ▼
         Explanation and Coaching Layer
                    │
                    ▼
          Apple Watch / iPhone Output
```

---

# Core Components

## ShotContext

The canonical pre-shot decision object.

It combines:

- Player
- Round
- Hole
- Ball position
- Playable lie
- Course area
- Available clubs
- Recent shot history
- Strategy geometry
- Current shot plan
- Environmental context

---

## StrategyEngine

Determines where the golfer should aim.

It combines:

- RoutePlanner
- ObstacleEvaluator
- TargetSelector
- ShotPlanner

The StrategyEngine produces a `ShotPlan`.

---

## RecommendationEngine

Scores available clubs against the current `ShotContext`.

It produces:

- Preferred club
- Alternative clubs
- Adjusted carry
- Distance difference
- Aim offset
- Confidence
- Reasons
- Explanation

---

## Player Learning Engine

The Player Learning Engine will derive player-specific patterns from completed shots.

Examples:

- Average carry by club
- Carry variation
- Directional dispersion
- Miss frequency
- Performance by lie
- Performance by wind
- Performance by target distance

Initial versions may use descriptive statistics rather than machine learning.

---

## Course Knowledge Engine

The Course Knowledge Engine will interpret mapped course information.

It may include:

- Landing zones
- Centre lines
- Hazards
- Bail-out areas
- Preferred misses
- Recovery routes
- Green centre
- Pin location
- Preferred approach angle

---

## Explanation Engine

The Explanation Engine converts structured outputs into concise golfer-facing guidance.

It must preserve:

- Recommendation intent
- Confidence
- Key reasons
- Risk warnings
- Alternatives

It must not contradict the structured recommendation.

---

# Recommendation Output

A recommendation should contain structured fields before any natural-language summary is generated.

Expected output includes:

- Selected route
- Immediate target
- Target bearing
- Target distance
- Preferred club
- Alternative clubs
- Wind adjustment
- Aim offset
- Risk level
- Confidence
- Supporting reasons
- Human-readable explanation

---

# Confidence Model

Recommendation confidence should consider:

- GPS accuracy
- Course geometry quality
- Lie detection confidence
- Weather availability
- Player-history sample size
- Club carry reliability
- Route risk
- Hazard proximity
- Data freshness

Low-confidence recommendations should be presented cautiously.

Example:

> Likely 7 iron, but confirm the lie because the ball appears close to the fairway boundary.

---

# Human Authority

The golfer remains the final decision-maker.

The golfer may:

- Reject a recommendation
- Choose another club
- Correct the lie
- Correct ball position
- Select another target
- Ignore the suggested route

These choices should be retained as learning signals where appropriate.

---

# Safety and Trust

The AI Caddy must not create distraction or delay play.

The Apple Watch experience should prioritise:

- Short recommendations
- Clear confidence
- Minimal prompts
- Voice interaction
- Haptic alerts only when useful

The system should avoid overconfidence when data is incomplete.

---

# Privacy

Player performance data may be sensitive personal information.

AI processing should prefer on-device or private Apple-platform services where practical.

Data should not be sent to external AI services without:

- Clear user consent
- Defined purpose
- Secure transport
- Appropriate retention controls

---

# Offline Operation

The deterministic AI Caddy must work without network access using cached:

- Course geometry
- Player clubs
- Historical summaries
- Active round data
- Recent weather data where available

Network-based AI explanation should be optional and must not block play.

---

# Model Evolution

The architecture will evolve through stages.

## Stage 1: Deterministic Rules

- Distance matching
- Lie adjustment
- Wind adjustment
- Route risk
- Recent error penalties
- Explainable scoring

## Stage 2: Statistical Personalisation

- Average carry
- Dispersion
- Sample-size confidence
- Lie-specific performance
- Directional tendencies

## Stage 3: Predictive Models

- Expected landing distribution
- Expected miss
- Club outcome probability
- Route success probability

## Stage 4: Advanced Agentic Caddy

- Multi-shot planning
- Continuous round context
- Strategy adaptation
- Coaching dialogue
- Practice-plan generation

---

# Alternatives Considered

## Pure Rules Engine

Not selected as the final architecture because it would limit long-term personalisation.

It remains the foundation of the chosen hybrid design.

## Pure Machine Learning

Rejected because early data volumes will be limited and recommendations would be difficult to explain and test.

## Generative AI as Primary Decision-Maker

Rejected because language models may produce inconsistent or unsupported recommendations.

Generative AI may explain or summarise structured outputs but should not independently control core golf decisions.

---

# Consequences

## Positive

- Explainable recommendations
- Useful from the first round
- Improves with player history
- Testable core logic
- Supports offline operation
- Allows future machine-learning integration
- Reduces dependence on external AI services

## Negative

- More architectural layers
- Requires disciplined data modelling
- Requires calibration of deterministic rules
- Requires monitoring of learned adjustments
- Explanation and recommendation logic must remain aligned

---

# Implementation Guidance

The following components should be developed in sequence:

1. ShotContext
2. StrategyEngine
3. RecommendationEngine
4. Player statistics
5. Club-performance summaries
6. Dispersion model
7. LearningEngine
8. ExplanationEngine
9. Recommendation audit record
10. On-device model integration

---

# Testing Requirements

Tests should cover:

- Club selection by distance
- Wind adjustment
- Lie adjustment
- Recent miss-pattern adjustment
- Hazard-aware target selection
- Confidence calculation
- No-history behaviour
- Incomplete-data behaviour
- Recommendation explanation
- Alternative club ranking
- Deterministic repeatability
- Rejection of invalid or unsafe routes

---

# Auditability

Each generated recommendation should be reproducible from its stored inputs.

Future persistence may include a recommendation audit record containing:

- ShotContext snapshot
- Candidate clubs
- Candidate routes
- Scoring inputs
- Final scores
- Selected recommendation
- Confidence
- Explanation
- Golfer decision
- Actual outcome

This supports debugging, learning and trust.

---

# Documentation Impact

This decision requires ongoing updates to:

- AI Caddy Design
- System Architecture
- Domain Model
- Data Model
- Database Design
- API Specification
- Testing Strategy
- Privacy and Security documentation
- Domain Glossary

---

# Future Considerations

Future versions may include:

- Apple Foundation Models integration
- On-device embeddings
- Local player model
- Bayesian recommendation confidence
- Strokes-gained optimisation
- Coach-configurable strategy
- Tournament-mode risk profiles
- Voice-based coaching dialogue
- Round-level autonomous planning
- Practice-plan generation

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
