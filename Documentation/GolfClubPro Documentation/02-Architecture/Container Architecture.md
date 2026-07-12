# Container Architecture

**Document ID:** GCP-ARC-003  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Solution Architecture

---

# Purpose

This document describes the principal deployable and code containers that make up GolfClubPro.

---

# Containers

## GolfClubPro iPhone Application

Responsibilities:

- SwiftUI interface
- Application lifecycle
- Dependency composition
- SwiftData persistence
- Detailed round review
- Course-data management
- Synchronisation management

Depends on:

- GolfCore
- GolfPlatformApple

---

## GolfClubPro Watch Application

Responsibilities:

- Watch-first round interaction
- Club selection
- Voice feedback capture
- Motion observation
- Haptics
- Immediate round prompts
- Temporary offline continuation

Depends on:

- GolfCore
- GolfPlatformApple where Watch adapters are required

---

## GolfCore Package

Responsibilities:

- Domain entities and value objects
- Round Engine
- Round Orchestrator
- Strategy and recommendation logic
- Golf-club and hole detection
- Lie detection
- Offline models and persistence contracts
- Domain tests

Must not depend on:

- Apple frameworks
- SwiftUI
- SwiftData
- Application targets

---

## GolfPlatformApple Package

Responsibilities:

- Apple framework adapters
- Translation of Apple types into GolfCore models
- Core Location integration
- Future Core Motion, Speech, WeatherKit, WatchConnectivity, HealthKit, and haptics adapters

Depends on:

- GolfCore

Must not own:

- Golf rules
- Round transitions
- Recommendation decisions
- Persistence policy

---

## External Services

Potential external systems include:

- DotGolf
- Weather services
- OpenAI
- CloudKit
- SharePoint
- Future GolfClubPro cloud services

External services are accessed through providers and adapters.

---

# Container Relationships

```text
GolfClubPro iPhone App
    ├── GolfCore
    └── GolfPlatformApple
            └── GolfCore

GolfClubPro Watch App
    ├── GolfCore
    └── GolfPlatformApple

External Services
    ↕
Providers and adapters
