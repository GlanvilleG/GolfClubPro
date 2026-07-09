
# ADR-002: Documentation Strategy

## Status

Accepted

## Context

GolfClubPro is intended to become a commercial-quality Apple platform with GPS, weather, shot analytics, DotGolf integration, and AI Caddy functionality.

The project requires documentation that supports development, testing, onboarding, and future commercialisation.

## Decision

Adopt a structured living documentation set under the Documentation directory.

The documentation will include:

- Project Administration

- Product Management

- Architecture

- User Experience

- Engineering

- AI

- Operations

- Decisions / ADRs

- Diagrams

Significant architectural decisions will be recorded as ADRs.

## Alternatives Considered

### Minimal README only

Rejected because the project scope is larger than a simple app.

### External documentation system

Rejected for now because Markdown in Git keeps documentation versioned with code.

## Consequences

### Benefits

- Documentation stays close to the code

- Easier onboarding

- Better architectural traceability

- Stronger commercial and investor readiness

### Risks

- Documentation may become outdated

### Mitigation

Documentation updates are included in the definition of done.

