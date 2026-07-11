
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

## Pass 3 – Vocabulary & Naming Audit

The objective is that every class name immediately communicates its responsibility.
- Our vocabulary - updated in 02-Architecture/Ubiquitous Language.md


