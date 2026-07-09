
# ADR-003: Domain-Driven Design

## Status

Accepted

## Context

GolfClubPro models a real-world golf domain involving players, clubs, courses, holes, rounds, shots, weather context, GPS location, and AI recommendations.

A shared business language is required across product, architecture, code, tests, and AI design.

## Decision

Adopt Domain-Driven Design principles.

GolfCore will contain the core domain language and business concepts.

Domain terms will be defined in:

- Domain Model

- Domain Glossary

- Data Model

Business concepts should be represented explicitly rather than as generic strings, dictionaries, or loosely typed objects.

## Alternatives Considered

### UI-first modelling

Rejected because it would likely produce models shaped by screens rather than golf concepts.

### Database-first modelling

Rejected because persistence design should follow the domain, not define it.

## Consequences

### Benefits

- Clear business language

- Better testability

- Better AI reasoning context

- Easier future integrations

### Risks

- Slightly more design work upfront

### Mitigation

Keep early models simple and evolve them through ADRs.

