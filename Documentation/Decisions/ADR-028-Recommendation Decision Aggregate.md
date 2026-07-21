
# ADR-028 — Recommendation Decision Aggregate

| Status | Proposed |
|---------|----------|
| ADR | 028 |
| Date | 2026-07-20 |
| Decision Makers | GolfClubPro Architecture Group |
| Applies To | GolfCore |

---

# Context

The Recommendation Pipeline has evolved into a collection of specialised engines, each responsible for a single aspect of golf strategy and shot analysis.

Current pipeline:

```text
RecommendationContext
        │
        ▼
DispersionEngine
        │
        ▼
ShotDispersionModel
        │
        ▼
HoleAreaAssessmentEngine
        │
        ▼
HoleAssessment
        │
        ▼
StrategicOptionEngine
        │
        ▼
StrategicOption
        │
        ▼
RiskRewardAnalysisEngine
        │
        ▼
RiskRewardAnalysis
```

Each engine produces a high-quality immutable domain object.

However, the pipeline currently has no canonical representation of the complete recommendation.

As additional engines are introduced (Explainability, Learning, Weather, AI Caddie, Strokes Gained, etc.) the number of objects passed between components will continue to grow.

Without a single aggregate object this leads to:

- increasing parameter lists
- duplicated plumbing
- unclear ownership of decision data
- versioning difficulties
- tighter coupling between consumers and producers

---

# Problem Statement

The recommendation pipeline requires a single immutable representation of an AI recommendation that captures every analysis performed at a particular point in time.

Consumers should receive one object rather than multiple loosely-related domain models.

---

# Decision

Introduce a new immutable domain object named:

```text
RecommendationEvaluation
```

The Recommendation Pipeline shall produce exactly one RecommendationDecision for every recommendation request.

RecommendationDecision becomes the canonical representation of the AI decision.

Every downstream component consumes RecommendationDecision rather than individual engine outputs.

---

# Initial Structure

```text
RecommendationDecision
│
├── RecommendationContext
│
├── HoleAssessment
│
├── ShotDispersionModel
│
├── StrategicOption
│
├── RiskRewardAnalysis
│
└── createdAt
```

Each member remains immutable.

RecommendationDecision owns no business logic.

It exists solely to aggregate completed analyses.

---

# Responsibilities

RecommendationDecision SHALL:

- aggregate recommendation outputs
- preserve decision consistency
- provide a single API surface
- support future versioning
- enable auditing
- support replay
- support explainability
- support learning

RecommendationDecision SHALL NOT:

- perform calculations
- modify analysis
- perform optimisation
- generate UI text
- execute AI prompts

---

# Ownership

| Component | Responsibility |
|------------|---------------|
| RecommendationPipeline | Builds RecommendationDecision |
| RecommendationDecision | Immutable aggregate |
| AI Caddie | Consumes |
| Watch UI | Consumes |
| Explainability Engine | Consumes |
| Learning Engine | Consumes |
| Statistics Engine | Consumes |
| Cloud Synchronisation | Consumes |

---

# Future Expansion

The aggregate is intentionally designed to expand.

Future versions may include:

```text
RecommendationDecision
│
├── RecommendationContext
├── HoleAssessment
├── ShotDispersionModel
├── StrategicOption
├── RiskRewardAnalysis
│
├── WeatherAnalysis
├── WindAnalysis
├── TerrainAnalysis
├── ConfidenceAnalysis
├── ExplainabilityAnalysis
├── StrokesGainedAnalysis
├── PlayerModel
├── HistoricalPerformance
├── LearningFeedback
├── RecommendationMetadata
└── createdAt
```

Existing consumers remain unchanged.

---

# Recommendation Metadata

Future versions should include metadata describing how the recommendation was produced.

Example:

```text
RecommendationMetadata

engineVersion

algorithmVersion

courseVersion

weatherVersion

generatedBy

executionTime

buildNumber
```

This allows:

- replay
- auditing
- debugging
- AI model comparisons

---

# Architectural Principles

RecommendationDecision follows the existing GolfClubPro architecture.

Each engine:

- owns one responsibility
- performs one calculation
- produces one immutable model

RecommendationDecision simply aggregates them.

This maintains complete separation of concerns.

---

# Benefits

## Simplified APIs

Instead of:

```swift
func presentRecommendation(
    context,
    strategicOption,
    holeAssessment,
    dispersion,
    riskReward,
    weather,
    confidence,
    explainability
)
```

Consumers receive:

```swift
func presentRecommendation(
    decision:
        RecommendationDecision
)
```

---

## Version Stability

Future engines may be added without changing existing public APIs.

---

## Audit Trail

RecommendationDecision becomes a complete historical snapshot.

Every recommendation can be reconstructed.

---

## Explainability

Explainability becomes deterministic.

The explanation references the immutable decision.

---

## Learning

Player outcomes can be compared against the exact recommendation produced at the time.

---

## Cloud Synchronisation

A single object can be serialised and synchronised.

---

## AI Integration

Large Language Models receive one structured object rather than multiple disconnected models.

---

# Consequences

Positive:

- Simpler architecture
- Easier testing
- Reduced coupling
- Better documentation
- Better replay capability
- Better telemetry
- Better AI integration

Negative:

- Slightly larger object graph
- New aggregate model introduced

The advantages significantly outweigh the additional model.

---

# Alternatives Considered

## Pass Individual Models

Rejected.

As engines increase this rapidly becomes difficult to maintain.

---

## Dictionary-Based Decision Object

Rejected.

Weak typing reduces compiler safety.

---

## Mutable Aggregate

Rejected.

Violates immutable domain model principles.

---

# Decision

RecommendationPipeline SHALL return RecommendationDecision as the canonical representation of an AI recommendation.

All downstream systems SHALL consume RecommendationDecision.

RecommendationDecision SHALL remain immutable.

RecommendationDecision SHALL contain no business logic.

---

# Related ADRs

ADR-004 — Strongly Typed Identifiers

ADR-006 — Watch-First Architecture

ADR-027 — Recommendation Pipeline

ADR-028 — Recommendation Decision Aggregate
