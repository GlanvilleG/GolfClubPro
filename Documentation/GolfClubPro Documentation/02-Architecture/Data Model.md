# Data Model

**Document ID:** GCP-ARC-003  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Solution Architecture  
**Related Documents:** Domain Model, Domain Glossary, Database Design  
**Related ADRs:** ADR-003 Domain Driven Design, ADR-004 Strongly Typed Identifiers

---

# Purpose

The Data Model defines how the GolfClubPro domain concepts are represented in code within the `GolfCore` package.

The Domain Model defines the business concepts.  
The Data Model defines their Swift representation.

This document acts as the bridge between architecture and implementation.

---

# Data Model Principles

The GolfCore data model follows these principles:

- Prefer explicit domain types over primitive values.
- Use strongly typed identifiers.
- Keep models independent of UI frameworks.
- Keep models independent of persistence frameworks where practical.
- Use `Codable` for portability.
- Use `Equatable` for testing.
- Use `Sendable` where appropriate for modern Swift concurrency.
- Keep business rules out of plain data models.

---

# Identifier Types

GolfCore uses dedicated identifier types.

## PlayerID

Represents the internal identity of a player.

```swift
public struct PlayerID: Codable, Hashable, Sendable {
    public let value: UUID
}
```

## DotGolfMemberID

Represents an external DotGolf member identifier.

```swift
public struct DotGolfMemberID: Codable, Hashable, Sendable {
    public let value: String
}
```

## CourseID

Represents a course identity.

## HoleID

Represents a hole identity.

## ClubID

Represents a club identity.

## RoundID

Represents a round identity.

## ShotID

Represents a shot identity.

---

# Core Swift Models

## Player

```swift
public struct Player: Codable, Equatable, Sendable {
    public let id: PlayerID
    public var dotGolfMemberID: DotGolfMemberID?
    public var name: String
    public var handicapIndex: Double?
}
```

## Club

```swift
public struct Club: Codable, Equatable, Sendable {
    public let id: ClubID
    public var name: String
    public var type: ClubType
    public var loftDegrees: Double?
    public var averageCarryMeters: Double?
}
```

## ClubType

```swift
public enum ClubType: String, Codable, CaseIterable, Sendable {
    case driver
    case fairwayWood
    case hybrid
    case iron
    case wedge
    case putter
}
```

## Course

```swift
public struct Course: Codable, Equatable, Sendable {
    public let id: CourseID
    public var name: String
    public var holes: [Hole]
}
```

## Hole

```swift
public struct Hole: Codable, Equatable, Sendable {
    public let id: HoleID
    public var number: Int
    public var par: Int
    public var strokeIndex: Int?
    public var lengthMeters: Double
}
```

## Round

```swift
public struct Round: Codable, Equatable, Sendable {
    public let id: RoundID
    public var playerID: PlayerID
    public var courseID: CourseID
    public var status: RoundStatus
    public var startedAt: Date
    public var completedAt: Date?
    public var shots: [Shot]
}
```

## RoundStatus

```swift
public enum RoundStatus: String, Codable, Sendable {
    case planned
    case active
    case paused
    case completed
    case abandoned
}
```

## Shot

```swift
public struct Shot: Codable, Equatable, Sendable {
    public let id: ShotID
    public var roundID: RoundID
    public var holeID: HoleID
    public var clubID: ClubID
    public var timestamp: Date
    public var distanceMeters: Double?
    public var lie: Lie?
    public var weatherContext: WeatherContext?
}
```

## Shot Feedback
```swift
public struct ShotFeedback: Codable, Equatable, Sendable {
    public var rawTranscript: String
    public var classifiedErrors: [ShotError]
    public var sentiment: ShotSentiment?
    public var capturedAt: Date

    public init(
        rawTranscript: String,
        classifiedErrors: [ShotError] = [],
        sentiment: ShotSentiment? = nil,
        capturedAt: Date = Date()
    ) {
        self.rawTranscript = rawTranscript
        self.classifiedErrors = classifiedErrors
        self.sentiment = sentiment
        self.capturedAt = capturedAt
    }
}
```

## Shot Error
```swift
public enum ShotError: String, Codable, CaseIterable, Sendable {
    case mishit
    case miss
    case badLie
    case trouble

    case push
    case pull
    case slice
    case hook
    case fade
    case draw

    case chunk
    case fat
    case thin
    case blade
    case top
    case shank
    case duff
    case whiff

    case short
    case long
    case overHit

    case rough
    case trees
    case bunker
    case water
    case outOfBounds

    case duckHook
    case bananaBall
    case wormBurner
    case reload
    case luckyOutcome
}
```
## Shot Sentiment
```swift
public enum ShotSentiment: String, Codable, Sendable {
    case positive
    case neutral
    case negative
    case warning
}
```
## Lie

```swift
public enum Lie: String, Codable, CaseIterable, Sendable {
    case tee
    case fairway
    case rough
    case sand
    case fringe
    case green
    case recovery
    case penalty
}
```

## WeatherContext

```swift
public struct WeatherContext: Codable, Equatable, Sendable {
    public var windSpeedMetersPerSecond: Double?
    public var windDirectionDegrees: Double?
    public var temperatureCelsius: Double?
    public var humidityPercent: Double?
    public var pressureHPa: Double?
}
```

## Recommendation

```swift
public struct Recommendation: Codable, Equatable, Sendable {
    public let id: RecommendationID
    public var roundID: RoundID
    public var holeID: HoleID
    public var suggestedClubID: ClubID?
    public var confidenceScore: Double?
    public var explanation: String
}
```

---

# Relationship Rules

- `Player` owns many `Round` records.
- `Player` owns many `Club` records.
- `Course` owns many `Hole` records.
- `Round` references one `PlayerID`.
- `Round` references one `CourseID`.
- `Shot` references one `RoundID`.
- `Shot` references one `HoleID`.
- `Shot` references one `ClubID`.
- `Recommendation` references the round, hole, and suggested club.

---

# Persistence Considerations

The data model is intentionally not tied directly to SwiftData.

This allows GolfCore to remain portable and testable.

SwiftData-specific persistence models may either:

- Wrap GolfCore models, or
- Mirror GolfCore models and map between persistence and domain layers.

The preferred approach for early development is to keep GolfCore independent and introduce persistence adapters later.

---

# Serialization

All core models should support `Codable` where practical.

This supports:

- Local file export
- Cloud synchronisation
- Test fixtures
- Future API integration
- Debugging and diagnostics

---

# Validation Rules

Validation should not be hidden inside UI code.

Examples:

- Hole number must be positive.
- Par should normally be between 3 and 6.
- Handicap index may be nil.
- DotGolf member ID may be nil.
- Shot distance may be nil until GPS finish is known.
- Wind data may be nil when unavailable.

Validation belongs in domain services or factory methods where appropriate.

---

# Future Data Model Expansion

Future versions may introduce:

- TeeSet
- TeeBox
- GPSCoordinate
- GeoBoundary
- Hazard
- PinPosition
- AimPoint
- DispersionPattern
- ClubPerformanceProfile
- StrokesGainedMetric
- CoachingInsight
- PracticeRecommendation
- SharedRound
- CoachAccess

---

# Implementation Guidance

Initial Swift model files should be placed under:

```text
GolfCore/Sources/GolfCore/Models/
```

Identifier files should be placed under:

```text
GolfCore/Sources/GolfCore/Identifiers/
```

Business logic should be placed under:

```text
GolfCore/Sources/GolfCore/Domain/
```

Platform services should not be placed directly into GolfCore until their dependency boundary is clearly defined.

---

# Traceability

Every model in this document must map back to a concept in the Domain Model.

Every implemented Swift type should be traceable to this Data Model.

Major changes to this document should trigger review of:

- Domain Model
- Domain Glossary
- Database Design
- API Specification
- AI Caddy Design
- Relevant ADRs
