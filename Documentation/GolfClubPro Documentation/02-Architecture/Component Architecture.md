# Component Architecture

**Project:** GolfClubPro  
**Document:** Component Architecture  
**Version:** 0.6  
**Status:** Current (Sprint 10.6)  
**Architecture Style:** Domain-Driven Design (DDD), Clean Architecture, Watch-First, Offline-First

---

# Purpose

This document defines the major software components that make up GolfClubPro, their responsibilities, interactions, dependency rules, and architectural boundaries.

The objective is to ensure:

- Single Responsibility
- High cohesion
- Low coupling
- Deterministic behaviour
- Testability
- Explainability
- Extensibility

---

# Architectural Principles

GolfClubPro follows these architectural principles:

- Domain Driven Design (DDD)
- Clean Architecture
- Composition over inheritance
- Immutable domain models
- Dependency inversion
- Offline-first operation
- Deterministic recommendation generation
- Explicit component boundaries
- Platform independence of core logic

---

# High-Level Component Architecture

```text
                Apple Watch
                     │
               SwiftUI Interface
                     │
      ┌──────────────┴──────────────┐
      │                             │
 Watch Presentation          iPhone Presentation
      │                             │
      └──────────────┬──────────────┘
                     │
             Intelligent Round
               Orchestrator
                     │
         Recommendation Pipeline
                     │
   ┌─────────────────┼─────────────────┐
   │                 │                 │
Round Engine   Environmental     Player Performance
                    Engine            Engine
   │                 │                 │
   └──────────────┬──┴───────┬─────────┘
                  │          │
           Domain Services
                  │
          GolfClubCore Domain
                  │
      Persistence / Synchronisation
```


---

# Component Overview

| Component | Responsibility |
|------------|----------------|
| Watch UI | Golfer interaction |
| iPhone UI | Review, reporting, configuration |
| Intelligent Round Orchestrator | Coordinates the complete round lifecycle |
| Round Engine | Maintains deterministic round state |
| Recommendation Pipeline | Generates shot recommendations |
| Environmental Intelligence | Interprets environmental conditions |
| Player Performance Intelligence | Analyses historical player performance |
| Domain Services | Shared deterministic business logic |
| Persistence | Offline storage and recovery |
| Platform Layer | Apple framework integration |

---

# Core Components

## GolfClubCore

GolfClubCore contains the complete business domain.

Responsibilities:

- Domain models
- Domain services
- Recommendation logic
- Round management
- Player intelligence
- Environmental intelligence

Contains **no Apple framework dependencies**.

---

## GolfPlatformApple

Provides integration with Apple technologies.

Responsibilities:

- Core Location
- HealthKit
- WeatherKit
- SwiftUI
- WatchConnectivity
- AVFoundation
- Haptics

No business rules exist within this layer.

---

# Intelligent Round Orchestrator

Coordinates the complete golfing experience.

Responsibilities:

- Round lifecycle
- Hole progression
- Shot sequencing
- Sensor coordination
- Recommendation requests
- Recovery after interruptions

The Orchestrator owns workflow.

It does **not** calculate recommendations.

---

# Round Engine

Maintains deterministic round state.

Responsibilities:

- Round state machine
- Hole state
- Shot lifecycle
- Practice swing filtering
- Pending evidence handling
- Snapshot recovery

---

# Recommendation Pipeline

The Recommendation Pipeline is responsible for producing deterministic shot recommendations.

It is the primary decision engine.

## Pipeline

```text
RecommendationContext
        │
        ▼
Shot Planning
        │
        ▼
Spatial Analysis
        │
        ▼
Environmental Intelligence
        │
        ▼
Player Intelligence
        │
        ▼
Strategic Option Engine
        │
        ▼
Risk / Reward Engine
        │
        ▼
Club Scoring Engine
        │
        ▼
Recommendation Decision
```

---

# Shot Planning

Responsible for:

- Target selection
- Route strategy
- Landing zone
- Aim point

Produces:

- ShotPlan

---

# Spatial Analysis

Responsible for:

- Hole geometry
- Dispersion analysis
- Landing area analysis
- Hazard proximity

Produces:

- SpatialRiskAssessment

---

# Environmental Intelligence

Introduced in Sprint 10.5.

Responsible for interpreting:

- Wind
- Elevation
- Terrain
- Course condition
- Lie
- Weather confidence
- Hazard information

Produces immutable:

- EnvironmentalAssessment

Recommendation engines consume this assessment rather than raw environmental data.

---

# Player Performance Intelligence

Introduced in Sprint 10.6.

Responsible for analysing historical performance.

Produces:

- PlayerPerformanceProfile
- ClubPerformanceProfile
- PerformanceTrend
- ConfidenceProfile

Recommendation engines consume Player Intelligence rather than analysing historical rounds directly.

---

# Strategic Option Engine

Evaluates available playing strategies.

Examples:

- Aggressive
- Conservative
- Lay-up
- Recovery

Produces:

- StrategicOption

---

# Risk / Reward Engine

Evaluates strategic options.

Produces:

- RiskAssessment
- RiskRewardAnalysis

Evaluates:

- Hazard exposure
- Penalty probability
- Expected scoring value

---

# Club Scoring Engine

Scores clubs using:

- Distance
- Wind
- Terrain
- Historical performance
- Dispersion
- Strategic fit
- Risk

Produces:

- ClubRecommendation

---

# Recommendation Decision

Produces the golfer-facing recommendation.

Contains:

- ShotPlan
- Preferred club
- Alternative clubs
- Aim adjustment

This is the final deterministic output of the recommendation pipeline.

---

# Environmental Context Engine

Interprets external information into deterministic assessments.

Consumes:

- Weather
- Terrain
- Course conditions
- Lie

Produces:

- EnvironmentalAssessment

No recommendation logic exists here.

---

# Player Performance Engine

Analyses completed rounds.

Produces deterministic player intelligence.

Consumes:

- Completed rounds
- Completed shots

Produces:

- PlayerIntelligence

No recommendation logic exists here.

---

# Persistence

Supports:

- Offline-first operation
- Snapshot recovery
- Recommendation auditing
- Round recovery

Stores:

- Players
- Courses
- Rounds
- Shots
- Performance history

---

# Recommendation Auditing

Optional subsystem.

Stores:

- Recommendation inputs
- Recommendation outputs
- Environmental assessments
- Player intelligence snapshot

Purpose:

- Debugging
- Explainability
- Analytics

---

# Platform Integration

Apple-specific services include:

- WeatherKit
- Core Location
- Watch Connectivity
- HealthKit
- SwiftUI
- Haptics

Business logic must never depend directly upon Apple frameworks.

---

# Dependency Rules

## Allowed

Presentation

↓

Orchestrator

↓

Recommendation Pipeline

↓

Domain Services

↓

Persistence

↓

Platform

---

## Not Allowed

Presentation → Persistence

Recommendation → SwiftUI

Recommendation → WeatherKit

Recommendation → HealthKit

Domain → Apple Frameworks

Player Intelligence → UI

Environmental Intelligence → UI

---

# Testing Strategy

Each component must be independently testable.

Required test categories:

- Unit tests
- Integration tests
- Pipeline tests
- Regression tests
- Performance tests

Deterministic outputs are mandatory.

---

# Planned Components

The following architectural components are planned.

## Explainability Engine

Purpose:

Explain deterministic recommendations.

Consumes:

- RecommendationDecision

Produces:

- RecommendationExplanation

---

## Narration Engine

Purpose:

Generate golfer-friendly narration.

Consumes:

- RecommendationExplanation

Produces:

- RecommendationNarration

No recommendation calculations occur within this component.

---

## Adaptive Coaching

Future capability.

Will consume:

- Player Intelligence
- Recommendation history
- Historical trends

Produces:

- Coaching recommendations
- Practice suggestions
- Long-term player insights

---

# Architectural Boundaries

| Layer | Depends On |
|---------|------------|
| Presentation | Orchestrator |
| Orchestrator | Recommendation Pipeline |
| Recommendation Pipeline | Domain Services |
| Domain Services | Domain Models |
| Persistence | Domain Models |
| Platform | Apple Frameworks |

Dependencies in the reverse direction are prohibited.

---

# Design Goals

The component architecture has been designed to achieve:

- Deterministic recommendations
- Explainable decision making
- High testability
- Platform independence
- Offline-first capability
- Long-term maintainability
- Clear separation of concerns
- Extensibility for future AI capabilities

This architecture provides the foundation for future Explainability, Narration, Adaptive Coaching, and conversational AI while preserving the deterministic recommendation engine as the authoritative source of golfing decisions.
