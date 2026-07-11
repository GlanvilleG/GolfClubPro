# System Context

**Project:** GolfClubPro  
**Version:** Architecture Milestone 1 (v0.4.0)

---

# Purpose

GolfClubPro is an intelligent golf caddie platform designed for Apple Watch and iPhone.

The platform assists golfers before, during and after a round by combining:

- GPS positioning
- Motion analysis
- Course geometry
- Club performance history
- Strategic route planning
- AI recommendations
- Voice interaction
- Post-round analytics

The architecture follows Domain Driven Design (DDD), Clean Architecture and Ports & Adapters (Hexagonal Architecture).

---

# High-Level Architecture

```
                        Apple Ecosystem
┌──────────────────────────────────────────────────────────┐
│                                                          │
│     Apple Watch              iPhone                      │
│                                                          │
│        SwiftUI              SwiftUI                      │
│           │                    │                         │
│           └────────────┬───────┘                         │
│                        │                                 │
│                 GolfClubPro App                          │
│                        │                                 │
└────────────────────────┼─────────────────────────────────┘
                         │
                         ▼

                GolfPlatformApple
       (Apple Platform Adapter Package)

        AppleLocationProvider
        AppleMotionProvider
        AppleSpeechProvider
        AppleWatchConnectivityProvider
        AppleHealthProvider
        AppleWeatherProvider
        AppleHapticsProvider

                         │
                         ▼

                   GolfCore Package

        Domain
        Round Engine
        Round Orchestrator
        Recommendation Engine
        Strategy Engine
        Detection Services
        Persistence Contracts
        Domain Models

                         │
                         ▼

               External Services

    DotGolf
    OpenAI
    WeatherKit
    SharePoint
    Future Cloud Services
```

---

# Responsibilities

## GolfClubPro

Responsible for:

- SwiftUI User Interface
- Navigation
- Dependency Injection
- SwiftData persistence
- Application lifecycle

Contains no business logic.

---

## GolfPlatformApple

Responsible for interacting with Apple frameworks.

Examples include:

- CoreLocation
- CoreMotion
- WatchConnectivity
- Speech
- HealthKit
- WeatherKit
- Haptics

This package converts Apple framework objects into GolfCore domain objects.

No golf decisions are made inside this package.

---

## GolfCore

Contains all golf knowledge.

Examples:

- Round state machine
- Shot lifecycle
- Lie detection
- Hole detection
- Strategy planning
- Recommendation engine
- Practice swing detection
- Scoring
- Rules
- Analytics

GolfCore contains no platform-specific code.

---

# External Systems

## DotGolf

Provides:

- Courses
- Tee sets
- Hole information
- Competition data

---

## OpenAI

Provides:

- Shot feedback interpretation
- Coaching explanations
- Natural language interaction

---

## Weather

Provides:

- Wind
- Temperature
- Rain
- Playing conditions

Used during recommendation generation.

---

# Architectural Principles

## Domain First

Business rules always reside in GolfCore.

---

## Platform Isolation

Apple frameworks remain isolated within GolfPlatformApple.

---

## Deterministic Engines

Every Engine must be deterministic.

Given identical inputs, the same outputs must be produced.

Examples:

- RecommendationEngine
- RoundEngine
- StrategyEngine

---

## Coordinators

Coordinators orchestrate workflows.

Examples:

- RoundOrchestrator
- PersistentOfflineRoundCoordinator
- (Future) GolfClubLocationCoordinator

---

## Providers

Providers communicate with external systems.

Examples:

- AppleLocationProvider
- AppleMotionProvider
- AppleSpeechProvider

---

## Services

Services perform business operations.

Examples:

- GolfClubDetectionService
- HoleDetectionService
- LieDetector

---

# Package Dependencies

```
GolfClubPro
    │
    ├── GolfCore
    │
    └── GolfPlatformApple
            │
            └── GolfCore
```

GolfCore has no dependency on GolfPlatformApple.

---

# Design Goals

- Offline-first operation
- Deterministic business logic
- Testable domain model
- Platform independence
- AI-assisted recommendations
- Minimal battery consumption
- High reliability during play

---

# Future Packages

The architecture anticipates future expansion.

Potential packages include:

- GolfPlatformGarmin
- GolfPlatformAndroid
- GolfCloud
- GolfAnalytics
- GolfSimulator

No changes to GolfCore should be required when additional platform packages are introduced.

---

# Current Status

Architecture Milestone 1 Completed.

Implemented:

- Domain Driven Design
- Round Engine
- Recommendation Engine
- Strategy Engine
- GPS Detection
- Hole Detection
- Lie Detection
- Practice Swing Detection
- Offline Persistence
- Apple Platform Adapter Layer

Next milestone:

GolfClubLocationCoordinator
