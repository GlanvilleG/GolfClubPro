
## Architecture Refinement Sprint

### Pass 1 — Repository Cleanup

- Removed obsolete CoreLocationService implementation
- Removed temporary package probe code
- Removed diagnostic and placeholder tests
- Removed dead references and outdated comments
- Verified GolfCore and GolfPlatformApple package structure
- Confirmed all package tests and app build succeed
### Pass 2 — Package Boundary Audit

- Confirmed GolfCore contains no Apple-framework dependencies
- Confirmed GolfPlatformApple contains only platform adapters
- Verified SwiftData remains in the iPhone application layer
- Removed duplicate or misplaced implementations
- Verified iPhone and Watch source ownership
- Confirmed all package tests and application targets build

### Pass 3 – Vocabulary & Naming Audit

The objective is that every class name immediately communicates its responsibility.
- Our vocabulary - updated in 02-Architecture/Ubiquitous Language.md

### Pass 4 — Public API Audit

- Reduced unnecessary public declarations
- Kept cross-module contracts explicit
- Changed read-only external state to public private(set)
- Kept app implementation types internal
- Identified aggregate mutation controls for later refinement
- Verified package tests and application builds

### Pass 5 — DDD Responsibility Audit

- Identified Round as the primary aggregate root
- Classified entities and value objects
- Confirmed engine, service, coordinator and provider responsibilities
- Verified persistence contracts contain no business logic
- Identified direct aggregate mutation for future restriction
- Identified injectable clock requirement for deterministic timestamps
- Recorded future separation of domain events and sync envelopes

### Pass 6 — Dependency and Import Audit

- Confirmed GolfCore contains no Apple or UI framework imports
- Confirmed GolfPlatformApple depends only on GolfCore
- Confirmed SwiftData remains in the iPhone app layer
- Verified package manifests and dependency direction
- Added automated architecture-boundary validation
- Confirmed all package tests and application targets build

### Pass 7 — Test Quality Audit

- Removed placeholder and compile-only tests
- Corrected async assertion patterns
- Replaced fragile floating-point comparisons
- Stabilised date-sensitive tests
- Added shared test fixtures where useful
- Improved behaviour-based test naming
- Added missing boundary cases
- Confirmed package and application test suites pass
