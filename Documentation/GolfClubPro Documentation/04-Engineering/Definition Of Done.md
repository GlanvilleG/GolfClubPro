
# Definition of Done

**Version:** 1.0  
**Status:** Active  
**Effective:** Sprint 8.5  
**Owner:** GolfClubPro Engineering

---

# Purpose

The Definition of Done establishes the minimum engineering, architectural and documentation requirements that every completed Sprint, Feature or Subsystem must satisfy before it is considered complete.

The objective is to ensure GolfClubPro remains a commercial-grade software platform with consistent engineering quality.

---

# Scope

This standard applies to:

- Domain Models
- Engines
- Builders
- Services
- Coordinators
- User Interface
- Documentation
- Architecture
- Testing
- GitHub Releases

---

# Engineering Principles

Every completed feature shall satisfy the Engineering Principles documented in:

```

04-Engineering/Engineering Principles.md

```

including:

- Single Responsibility
- Deterministic Behaviour
- Immutable Domain Objects
- Presentation Separation
- Builder Pattern
- Engine Pattern
- Testability
- API Stability

---

# Completion Checklist

A Sprint is complete only when every section below has been satisfied.

---

# 1. Development

- All planned functionality implemented.
- No placeholder implementations.
- No TODO items unless explicitly accepted.
- No dead code.
- No commented-out production code.
- Public API reviewed.

---

# 2. Testing

- All unit tests pass.
- New functionality includes tests.
- Existing tests updated where required.
- Behaviour-based tests preferred over implementation tests.
- Edge cases covered.
- No flaky tests.
- Test directory hierarchy mirrors the production directory hierarchy.
- Every new production class includes a corresponding test class where appropriate.
- Test names follow the `<ClassName>Tests.swift` convention.

---

# 3. Documentation

The following documents are updated where applicable:

- CHANGELOG.md
- RELEASES.md
- README.md
- ADRs
- Domain Model
- Engineering Principles
- System Context
- Roadmap

---

# 4. Architecture

- New architecture documented by ADR where required.
- Responsibilities reviewed.
- Single Responsibility Principle maintained.
- Public API reviewed.
- No architectural regressions.
- Stable subsystem boundaries maintained.

---

# 5. Repository

Before completion:

- Git status reviewed.
- Clean build.
- Tests executed.
- Commit created.
- Commit message follows project conventions.
- Git tag created (milestone releases).
- GitHub push completed.
- Repository structure shall remain organised by bounded context rather than technical implementation, with production and test hierarchies remaining aligned.

---

# 6. Release Readiness

Subsystems intended for reuse shall include:

- README
- ADR references
- Stable public API
- Test coverage
- Changelog entry

---

# 7. Documentation Quality

Documentation shall:

- Use the Ubiquitous Language.
- Remain implementation independent where possible.
- Describe responsibilities rather than implementation.
- Be maintained alongside code changes.

---

# 8. API Stability

Public domain models are considered stable after subsystem stabilisation.

Breaking changes require:

- Architecture review.
- ADR update.
- Changelog update.

---

# 9. Exceptions

Exceptions shall be:

- documented,
- justified,
- time limited,
- tracked as technical debt.

---

# 10. Sprint Closure

Every Sprint shall conclude with:

✓ Build succeeds

✓ Tests pass

✓ Documentation updated

✓ GitHub push completed

✓ Version tag created

✓ Release notes updated

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0 | 2026-07-15 | Initial Definition of Done adopted during Sprint 8.5 Recommendation Architecture Stabilisation. |
