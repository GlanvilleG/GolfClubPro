
# ADR-001: Repository Structure

## Status

Accepted

## Context

GolfClubPro will include an iPhone app, Apple Watch app, shared GolfCore package, documentation, test assets, course data, and future integrations.

A clear repository structure is needed before implementation grows.

## Decision

Use a single repository containing:

- Root-level Xcode app project/workspace

- Packages/GolfCore

- Documentation

- Assets

- CourseData

- Scripts

- Samples

- .github

The application project will remain at the root for now. An Apps directory may be introduced later if multiple applications justify it.

## Alternatives Considered

### Move apps into Apps directory immediately

Rejected for now because it adds Xcode path complexity without current benefit.

### Separate repositories

Rejected because the product is early stage and benefits from a single source of truth.

## Consequences

### Benefits

- Simple structure

- Easy Xcode management

- Clear documentation location

- Future package growth supported

### Risks

- Root may become crowded over time

### Mitigation

Review structure once additional apps or packages are introduced.

