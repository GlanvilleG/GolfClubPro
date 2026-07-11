# Architecture Principles

Version: 1.0

---

## Purpose

This document defines the architectural principles that guide the design and evolution of GolfClubPro.
Architectural Decision Records (ADRs) explain why decisions were made.
This document defines the rules that future changes should follow.

## **Documentation is treated as production code**
Every significant architectural decision, boundary, interface and domain concept should be documented with the same care as the implementation itself. Documentation is maintained alongside code, reviewed with changes, and evolves as the system evolves.

---

# Principle 1

Business rules belong in GolfCore.

GolfCore shall remain platform independent.

No Apple framework imports are permitted.

---

# Principle 2

Platform integrations belong in GolfPlatformApple.

This package contains adapters that translate Apple framework data into GolfCore domain objects.

No golf decisions are made in this package.

---

# Principle 3

The User Interface is passive.

SwiftUI Views display information.

Business logic resides outside Views.

---

# Principle 4

Engines are deterministic.

Given identical inputs an Engine must always produce identical outputs.

Examples

• RoundEngine
• RecommendationEngine
• StrategyEngine

---

# Principle 5

Coordinators orchestrate.

Coordinators call Engines, Services and Providers.

They do not contain business rules.

---

# Principle 6

Providers communicate externally.

Examples

AppleLocationProvider

AppleMotionProvider

WeatherProvider

DotGolfProvider

---

# Principle 7

Services encapsulate domain behaviour.

Services perform business operations.

---

# Principle 8

Repositories persist Aggregate Roots.

Repositories do not contain business rules.

---

# Principle 9

Aggregates protect consistency.

Only Aggregate Roots modify Aggregate state.

---

# Principle 10

Domain Models remain platform independent.

---

# Principle 11

Strongly Typed Identifiers are mandatory.

---

# Principle 12

Every significant architectural decision receives an ADR.

---

# Principle 13

Documentation evolves with the software.

Documentation is part of the product.

## Module Ownership

| Module | Owns | Must Not Own |
|---|---|---|
| GolfCore | Domain models, engines, services, coordinators, contracts | Apple APIs, SwiftUI, SwiftData |
| GolfPlatformApple | Apple framework adapters and model mapping | Golf rules, recommendation decisions, persistence policy |
| GolfClubPro | iPhone UI, dependency composition, SwiftData persistence | Duplicate domain or platform implementations |
| GolfClubPro Watch App | Watch UI and Watch-specific interaction | iPhone persistence and unrelated platform adapters |
