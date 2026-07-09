
# ADR-005: SwiftData Persistence Strategy

**Document ID:** GCP-ADR-005  
**Status:** Accepted  
**Date:** YYYY-MM-DD  
**Decision Makers:** Solution Architecture

---

# Context

GolfClubPro requires persistent storage for:

- Player profiles
- Equipment
- Courses
- Hole definitions
- Rounds
- Shot history
- AI recommendations
- Performance analytics

The application must support complete offline operation during a round of golf while also allowing future synchronisation across Apple devices.

The persistence solution should integrate naturally with the Apple ecosystem while keeping the core business logic independent of any storage technology.

---

# Decision

GolfClubPro will adopt **SwiftData** as the primary local persistence framework.

SwiftData will be implemented within the application layer.

The `GolfCore` package will **not** directly depend on SwiftData.

Instead:

- GolfCore defines the domain model.
- The application layer owns persistence.
- Mapping layers convert between SwiftData models and GolfCore domain models.

---

# Rationale

This approach provides a clear separation of responsibilities.

GolfCore remains:

- Framework independent
- Easily testable
- Portable
- Reusable

SwiftData provides:

- Native Apple framework support
- Tight integration with SwiftUI
- Automatic object graph management
- Future CloudKit compatibility
- Reduced boilerplate compared with Core Data

---

# Architecture

```text
Apple Watch UI
        │
SwiftUI Views
        │
Persistence Layer (SwiftData)
        │
Mapping Layer
        │
GolfCore Domain Models
        │
Business Rules
```

SwiftData is considered an infrastructure concern rather than a business concern.

---

# Alternatives Considered

## Core Data

**Rejected**

Although mature and capable, SwiftData offers a more modern API and aligns with Apple's long-term direction.

---

## SQLite

**Rejected**

SQLite provides maximum flexibility but requires significant manual mapping and schema management.

---

## Realm

**Rejected**

Realm introduces a third-party dependency and duplicates functionality available through Apple's frameworks.

---

## JSON File Storage

**Rejected**

Suitable for prototypes but insufficient for long-term data integrity, querying and synchronisation.

---

# Consequences

## Positive

- Native Apple solution
- Better SwiftUI integration
- Easier future CloudKit synchronisation
- Less persistence boilerplate
- Improved maintainability

---

## Negative

- SwiftData is available only on newer Apple operating systems.
- Mapping between persistence and domain models introduces additional code.

These trade-offs are acceptable because they preserve the independence of GolfCore.

---

# Design Principles

The following principles shall be followed.

## GolfCore remains persistence independent.

GolfCore models must never import:

- SwiftData
- CoreData

---

## Persistence is replaceable.

A future version should be capable of replacing SwiftData without modifying the business logic.

---

## Domain models remain the source of truth.

SwiftData models exist solely to persist domain information.

Business rules belong within GolfCore.

---

## Offline First

All persistence decisions must support complete offline play.

Network access must never be required while a golfer is actively playing a round.

---

## Synchronisation

Cloud synchronisation will be introduced after local persistence is stable.

CloudKit is the preferred synchronisation technology.

The synchronisation layer will sit above SwiftData and below application services.

---

# Implementation Strategy

The recommended implementation consists of four layers.

```text
SwiftUI

↓

Application Services

↓

SwiftData Persistence Models

↓

Mapping Layer

↓

GolfCore Domain Models
```

The mapping layer converts:

- SwiftData entities → GolfCore models
- GolfCore models → SwiftData entities

This isolates storage concerns from business logic.

---

# Future Considerations

Future versions may support:

- CloudKit synchronisation
- Shared rounds
- Coach access
- Multi-device conflict resolution
- Secure export and import
- Historical database migration
- Analytics warehouse
- AI model training datasets

The current architecture should allow these capabilities to be introduced without significant redesign.

---

# Related Documents

- Domain Model
- Data Model
- Database Design
- API Specification

---

# Related ADRs

- ADR-003 Domain Driven Design
- ADR-004 Strongly Typed Identifiers
- ADR-010 Offline First Strategy (planned)

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-09 | Initial version |
