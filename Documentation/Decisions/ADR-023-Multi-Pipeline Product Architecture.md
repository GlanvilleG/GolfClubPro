# ADR-023 — Multi-Pipeline Product Architecture
Status: Accepted
Date: 17 July 2026
Decision Owners: GolfClubPro Architecture Team
Supersedes: Portions of ADR-011 and ADR-014
Related ADRs: ADR-003, ADR-006, ADR-016, ADR-018, ADR-022

# Context
GolfClubPro has evolved from a distance measurement application into an intelligent golf assistant capable of:
understanding player behaviour;
analysing course risk;
adapting recommendations;
incorporating weather;
providing natural explanations;
delivering Apple Watch instructions.
The initial architecture introduced several specialised engines:
Player Performance Learning
Risk Analysis
Strategic Route Planning
Weather Adjustment
Caddy Recommendation
Caddy Explanation
Caddy Instruction
As the number of intelligent components increased, architectural review identified a risk that future development would converge on a central orchestration component containing excessive responsibility.
The previous Intelligent Round Orchestrator concept defined in ADR-014 provided round-level coordination but risked becoming a "God Object" responsible for:
collecting context;
making decisions;
applying strategy;
formatting user responses;
managing learning.
This would reduce maintainability and increase coupling as new capabilities are introduced.
A scalable architecture is required to support future capabilities including:
tournament strategy;
advanced AI coaching;
computer vision;
green intelligence;
strokes gained analytics;
cloud learning;
multi-platform delivery.
# Decision
GolfClubPro will adopt a Multi-Pipeline Product Architecture.
The system will be organised into independent but composable pipelines:
Context Pipeline
Decision Pipeline
Presentation Pipeline
Learning Pipeline
Each pipeline has a defined responsibility and communicates through stable domain contracts.
# Target Architecture
                    Golf Reality
                         |
                         v

              +-------------------+
              | Context Pipeline  |
              +-------------------+

                         |
                         v

              +-------------------+
              | Decision Pipeline |
              +-------------------+

                         |
                         v

          +----------------------------+
          | Presentation Pipeline      |
          +----------------------------+

                         |
                         v

              Apple Watch / iPhone UI


                         ^
                         |
                         v

              +-------------------+
              | Learning Pipeline |
              +-------------------+
# Pipeline Responsibilities
## 4.1 Context Pipeline
Purpose:
Establish the current truth of the golf environment.

Responsibilities:
round state;
active hole;
player position;
shot history;
lie information;
course geometry;
weather state.
Produces:
RoundContext
The Context Pipeline must not:
select clubs;
calculate strategy;
generate recommendations.
## 4.2 Decision Pipeline
Purpose:
Determine the optimal action based on available context.

Responsibilities:
player pattern adjustment;
risk assessment;
strategic route selection;
weather influence;
club recommendation.
Existing engines become decision stages:
AdaptiveCoachingEngine

↓

RiskModelEngine

↓

StrategicDecisionEngine

↓

WeatherAdjustmentEngine

↓

CaddyRecommendationEngine
Produces:
DecisionContext
## 4.3 Presentation Pipeline
Purpose:
Convert decisions into human interaction.

Responsibilities:
explanation generation;
voice output;
Apple Watch display;
haptic priority.
Existing engines:
CaddyExplanationEngine

↓

CaddyInstructionEngine
Produces:
CurrentRoundRecommendation
## 4.4 Learning Pipeline
Purpose:
Improve future recommendations through player feedback.

Responsibilities:
shot outcome capture;
performance updates;
dispersion learning;
behavioural pattern discovery.
Produces:
PlayerPerformanceModel
The Learning Pipeline operates independently from the live decision process where possible.
# Architectural Principles
## Principle 1 — Context is the Source of Truth
All decisions must originate from a defined context snapshot.
No intelligence engine should independently retrieve:
GPS;
round state;
player history;
course data.
## Principle 2 — Pipelines Communicate Through Contracts
Pipeline outputs become stable interfaces.
Examples:
RoundContext

DecisionContext

CurrentRoundRecommendation

PlayerPerformanceModel
Future changes should extend contracts rather than introduce direct dependencies.
## Principle 3 — New Capability Through Composition
Future capabilities should be introduced as pipeline stages.
Example:
Adding Green Speed Intelligence:
Decision Pipeline

Risk

↓

Green Speed Stage

↓

Strategy
not by modifying existing engines.
# Impact on Existing ADRs
This ADR does not invalidate previous architectural decisions.
It refines implementation responsibility.
## Superseded ADR Comments
### ADR-011 — AI Caddy Architecture
Status: Partially superseded
The AI Caddy concept remains valid.
Superseded portion:
AI Caddy as a single architectural component.
Replacement:
AI Caddy functionality is distributed across:
Decision Pipeline
+
Presentation Pipeline

### ADR-014 — Intelligent Round Orchestrator
Status: Partially superseded
The requirement for round-level coordination remains valid.
Superseded portion:
A single intelligent orchestrator containing business logic.
Replacement:
Round coordination is implemented through:
Context Pipeline
Decision Pipeline
Presentation Pipeline
Learning Pipeline

# ADR Status Matrix
ADR	Title	Status	Action
ADR-001	Repository Structure	Active	Keep
ADR-002	Documentation Strategy	Active	Keep
ADR-003	Domain Driven Design	Active	Keep
ADR-004	Strongly Typed Identifiers	Active	Keep
ADR-005	SwiftData Persistence	Active	Keep
ADR-006	Watch First Architecture	Active	Keep
ADR-007	Round Engine State Machine	Active	Keep
ADR-008	GPS and Golf Club Detection	Active	Keep
ADR-009	Course Geometry and Lie Detection	Active	Keep
ADR-010	Strategic Route and Target Planning	Active	Keep
ADR-011	AI Caddy Architecture	Modified	Superseded by ADR-023 where architecture conflicts
ADR-012	Weather Integration	Active	Keep
ADR-013	Offline First Architecture	Active	Keep
ADR-014	Intelligent Round Orchestrator	Modified	Superseded by ADR-023 where orchestration conflicts
ADR-015	Apple Platform Integration	Active	Keep
ADR-016	Context-Centric Domain Architecture	Active	Foundation
ADR-017	Spatial Index Architecture	Active	Keep
ADR-018	Recommendation Context Architecture	Active	Foundation
ADR-019	Player Performance Learning Architecture	Active	Keep
ADR-020	AI Shot Coaching Architecture	Active	Keep
ADR-021	Human Playing Characteristics	Active	Keep
ADR-022	Recommendation Pipeline Architecture	Active	Foundation
ADR-023	Multi-Pipeline Product Architecture	Accepted	Current architectural authority

# Consequences
## Positive
Clear separation of responsibilities.
Easier testing.
Reduced coupling.
New AI capabilities can be added incrementally.
Supports Apple Watch, iPhone, and Cloud implementations.
Enables multiple product experiences from the same intelligence core.
## Negative
More abstraction layers.
More domain contracts.
Additional initial development effort.
These costs are accepted because GolfClubPro is evolving into a long-lived intelligent platform rather than a single-purpose application.
# Implementation Impact
The next development sequence becomes:
Sprint 9.9.1
Context Pipeline
    RoundContextBuilder
    Context Models
Sprint 9.9.2
Decision Pipeline
Sprint 9.9.3
Presentation Pipeline
Sprint 9.9.4
Round Pipeline Integration


## Decision: Accepted.

# ADR-023 becomes the current architectural reference for future GolfClubPro development.
