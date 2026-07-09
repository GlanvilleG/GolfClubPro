# ADR-004: Strongly Typed Identifiers

## Status

Accepted

## Context

GolfClubPro will manage many related entities including players, clubs, courses, holes, rounds, shots, recommendations, and external integrations such as DotGolf.

Using raw UUIDs or strings for all identifiers increases the risk of accidentally passing the wrong identifier type between services.

For example, a RoundID should never be accepted where a PlayerID is expected.

## Decision

GolfCore will use strongly typed identifiers for core domain entities.

Examples:

- PlayerID
- DotGolfMemberID
- CourseID
- HoleID
- ClubID
- RoundID
- ShotID

Each identifier wraps the underlying value but provides type safety at compile time.

External identifiers, such as DotGolf membership numbers, will be kept separate from internal system identifiers.

## Alternatives Considered

### Raw UUID values

Rejected because they provide no compile-time protection against identifier misuse.

### Raw String values

Rejected because they are too weakly typed and unsuitable for internal identity.

### Database-generated identifiers only

Rejected because GolfClubPro must operate offline and create local entities before cloud sync.

## Consequences

### Benefits

- Stronger compile-time safety
- Clearer domain model
- Safer future integrations
- Better separation between internal and external identity
- Easier testing

### Risks

- Slightly more code required
- More model types to maintain

### Mitigation

Keep identifier types small, Codable, Hashable, Equatable, and Sendable.

## Implementation Guidance

Identifier types should be defined in GolfCore.

Example:

```swift
public struct PlayerID: Codable, Hashable, Sendable {
    public let value: UUID

    public init(_ value: UUID = UUID()) {
        self.value = value
    }
} EOF
