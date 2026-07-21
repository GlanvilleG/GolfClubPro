# ADR-025: Provider Independence Through Immutable Decision Snapshots

- **Status:** Accepted
- **Date:** 2026-07-18
- **Authors:** Dragon Development / GolfClubPro Architecture

## Context

GolfClubPro is designed as a modular AI-assisted golf platform.

The Recommendation Pipeline must make decisions using a complete and consistent snapshot of the golfer's current state without directly communicating with external service providers.

Examples of external providers include:

- Apple WeatherKit
- DOTGolf
- Garmin
- Arccos
- Shot Scope
- Future player analytics services
- Future AI strategy engines

These providers are expected to evolve independently throughout the life of the application.

Allowing recommendation engines to directly access provider APIs would tightly couple business logic to infrastructure. This would make testing, replay, auditing, offline operation and future provider replacement significantly more difficult.

## Decision

All recommendation and decision pipelines shall consume **immutable domain snapshots**.

External providers are responsible for collecting data and translating it into GolfClubPro domain models before pipeline execution.

Pipelines shall never directly communicate with provider APIs.

Transient provider data shall be aggregated into immutable input models, currently represented by `RecommendationInputs`, which form part of the `RoundContext` supplied to the Recommendation Pipeline.
External Providers
        │
        ▼
Domain Translation
        │
        ▼
RecommendationInputs
        │
        ▼
RoundContextBuilder
        │
        ▼
RoundContext
        │
        ▼
RecommendationPipeline


## Architectural Principles
### Provider Independence
Recommendation engines operate only on GolfClubPro domain models.
They do not know:
- where weather data originated
- which analytics provider supplied player performance data
- whether information came from the cloud, device, cache or simulation
- how provider authentication is performed
- how provider networking or retry logic is implemented
## Immutable Snapshots
All information required for a recommendation is captured before pipeline execution.
Builders create immutable context snapshots.
Pipelines never mutate contexts.
Engines consume values and return new results.
## Deterministic Execution
Given the same RoundContext, the Recommendation Pipeline should produce the same result.
This supports:
- repeatable unit testing
- historical recommendation replay
- AI and decision auditing
- recommendation comparison
- deterministic debugging
- simulation and what-if analysis
## Separation of Responsibilities
Providers
Providers are responsible for:
- acquiring external data
- authentication
- networking
- retry handling
- caching
- translating provider-specific responses into domain models
## Builders
Builders are responsible for:
- assembling complete immutable context snapshots
- validating that required inputs are available
- combining persistent and transient domain information
## Pipelines
Pipelines are responsible for:
- orchestration
- calling engines in the required sequence
- combining engine outputs
- returning a complete pipeline result
Pipelines do not perform provider access or infrastructure work.
## Engines
Engines are responsible for:
- focused business calculations
- deterministic domain logic
- returning explicit result models
## Weather Provider Abstraction
Weather information may ultimately be supplied by Apple WeatherKit or another provider.
At the Recommendation Pipeline layer, the source must remain abstract.
The pipeline shall receive only the domain model:
*WeatherCondition*
Provider-specific types, identifiers, response payloads and service logic must not enter the pipeline or engine layers.
This permits the weather source to be changed without modifying recommendation logic.
## Recommendation Explanation
Weather information contributes to both the recommendation calculation and the explanation presented to the golfer.
The explanation must describe the effect of the weather, not the provider that supplied it.
Example:
*Take the 7 Iron. Aim 4 metres right. A 22 km/h headwind is expected to reduce carry by approximately 6 metres, so one extra club has been selected.*

The explanation refers to the domain condition and its effect on the shot.
It must not expose infrastructure details such as:
*WeatherKit recommended a 7 Iron.*

The recommendation explanation should be capable of incorporating:
- wind speed
- wind direction
- headwind or tailwind effect
- crosswind effect
- estimated carry adjustment
- temperature effect
- air density effect
- precipitation or wet-ground effect
- confidence in the weather adjustment
## Recommendation Pipeline Implication
The Recommendation Pipeline may orchestrate independent calculations such as:
RoundContext
        │
        ▼
StrategicOptionEngine
        │
        ├───────────────┐
        ▼               ▼
AdaptiveCoaching   WeatherAdjustment
        │               │
        └───────┬───────┘
                ▼
CaddyRecommendation
                │
                ▼
RecommendationExplanation
The final recommendation explanation must have access to the weather adjustment used in the decision.
The provider remains outside this flow.
## Consequences
### Positive Consequences
- Complete provider abstraction
- Easier provider replacement
- Deterministic recommendations
- Simpler unit testing
- Replayable recommendation history
- Improved auditing and traceability
- Support for cached and offline weather data
- Support for simulation and test fixtures
- Strong separation between infrastructure and business logic
- Future providers can be added without changing core recommendation engines
### Trade-offs
- Builders must assemble complete input snapshots before pipeline execution.
- Additional translation layers are required between external providers and domain models.
- Context models may grow as additional decision inputs are introduced.
- Provider freshness and confidence metadata may need to be represented explicitly in domain models.
- Snapshot construction must define behaviour when provider data is unavailable or stale.
### Failure and Degradation Behaviour
The Recommendation Pipeline must remain capable of operating when optional provider data is unavailable.
Where weather information is missing:
- the recommendation may proceed without weather adjustment
- the result should indicate that no weather adjustment was applied
- the explanation must not imply that current weather was considered
- pipeline execution should not directly attempt to contact a provider
Provider retrieval failures are handled before context construction.
### Security and Privacy
External provider credentials, tokens and implementation details must remain within the infrastructure layer.
They must not be stored in:
- RoundContext
- RecommendationInputs
- recommendation results
- recommendation explanations
- engine inputs
Only translated domain information required for the decision may enter the pipeline.
### Future Direction
The current RecommendationInputs model may later evolve into a broader DecisionContext as additional decision capabilities are introduced.
Potential future inputs include:
- green speed
- pin position
- tournament state
- match-play state
- player fatigue
- pressure indicators
- equipment changes
- live course conditions
- confidence and freshness metadata
- cached provider data status
The architectural principle defined by this ADR remains unchanged:
Decision pipelines consume immutable domain snapshots and remain completely independent of external providers.

### Related ADRs
ADR-004 — Strongly Typed Identifiers
ADR-006 — Watch-First Architecture
ADR-023 — Multi-Pipeline Product Architecture
ADR-024 — Immutable Pipeline Contexts


// ADR ALIGNMENT UPDATE 20-07-2026

## Current Immutable Snapshots (Examples)

- RecommendationInputs (candidate landing zones, hole areas, player performance, weather)
- ShotContext / RoundContext (authoritative round/shot state)
- WeatherCondition (normalized provider-independent weather)
- Decision-Time Models (StrategicOption, ShotDispersionModel, HoleAssessment)

These examples illustrate the intended provider-independent boundary between external services and decision engines.
