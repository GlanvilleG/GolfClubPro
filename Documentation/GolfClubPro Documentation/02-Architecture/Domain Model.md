
# Domain Model

**Document ID:** GCP-ARC-002  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Solution Architecture  
**Related ADRs:** ADR-003 (Domain Driven Design), ADR-004 (Strongly Typed Identifiers)

---

# Purpose

The Domain Model defines the business concepts that make up GolfClubPro.

It is independent of implementation technologies such as SwiftUI, SwiftData, CloudKit, Core Location, WeatherKit, or any external API.

The purpose of this document is to establish a common language that is shared by software engineers, product owners, designers, testers, and future AI systems.

All software within **GolfCore** should model the concepts described in this document.

---

# Domain Design Principles

The GolfClubPro domain model is based on the following principles:

- Business concepts are defined before implementation.
- Business rules belong in the domain, not in the user interface.
- Internal identifiers are independent of external systems.
- Models describe *what exists*, not *how it is stored*.
- AI consumes domain information but does not define it.
- The domain remains stable even when technology changes.

---

# Domain Overview

GolfClubPro models the complete journey of a golfer during a playing session.

The primary domain is centred around a **Round**.

```text
Player
   │
   ├── Equipment Profile
   │
   ▼
Round
   │
   ├── Course
   │      └── Holes
   │
   ├── Weather Context
   │
   ├── GPS Position
   │
   ├── Shots
   │
   └── Recommendations
```

A Round represents a player's interaction with a golf course over time.

---

# Core Entities

## Player

A Player represents a golfer using GolfClubPro.

### Responsibilities

- Owns playing history
- Owns equipment profile
- Owns playing preferences
- May be linked to DotGolf

### Attributes

- PlayerID
- DotGolfMemberID (optional)
- Name
- Handicap Index
- Dominant Hand
- Preferred Units
- Equipment Profile

### Relationships

Player owns:

- Equipment Profile
- Rounds
- Statistics
- Coaching History

---

## Equipment Profile

An Equipment Profile represents the collection of clubs used by a player.

Each club maintains historical performance rather than relying on manufacturer specifications.

Future versions may also include:

- Ball type
- GPS device
- Range finder
- Wear history
- Loft adjustments

---

## Club

A Club represents one physical golf club.

### Attributes

- ClubID
- Name
- Club Type
- Loft
- Manufacturer
- Model
- Average Carry
- Average Total Distance
- Dispersion Pattern
- Confidence Rating

Historical performance is unique to each player.

---

## Course

A Course represents a playable golf course.

### Attributes

- CourseID
- Name
- Country
- Region
- GPS Boundary
- Local Rules
- Tee Sets
- Holes

Future versions may support multiple layouts for the same course.

---

## Tee Set

A Tee Set defines one playable course configuration.

Examples:

- Championship
- Black
- Blue
- White
- Yellow
- Red

Each Tee Set defines the start location and measured distance for every hole.

---

## Hole

A Hole represents one playable golf hole.

### Attributes

- HoleID
- Hole Number
- Par
- Stroke Index
- Tee Locations
- Green Location
- Hazards
- Ideal Landing Areas
- GPS Geometry

---

## Hazard

A Hazard represents an area that influences play.

Examples include:

- Bunkers
- Water
- Trees
- Out of Bounds
- Native Grass
- Penalty Areas

---
# Round Flow Model

## Purpose

The Round Flow Model defines the expected user journey during a live round of golf.

GolfClubPro should minimise manual input by using GPS location, known course geometry, Apple Watch interaction, and short voice commands.

---

# Primary Flow

## 1. Golf Club Detection

When the user opens GolfClubPro at a golf club, the system should use geolocation to match the user's current position against a known list of golf clubs.

If the user is clearly located at a known golf club, the system should automatically select that golf club and remove the need for manual course selection.

The user should be asked to confirm:

> Start round at Whanganui Golf Club?

---

## 2. Round Start

Once confirmed, the system creates an active round.

The round status becomes:

```text
Active
```

The system then waits for the golfer to move to a known starting hole.

The starting hole is usually Hole 1 or Hole 10, but any hole must be supported.

---

## 3. Hole Detection and Confirmation

As the golfer approaches a tee area, the system compares the golfer's position against known tee locations.

The system proposes the detected hole.

Example:

> Are you starting on Hole 10?

The golfer confirms the hole.

The golfer also confirms the tee colour being played.

Examples:

- Blue
- White
- Yellow
- Red

Once confirmed, the hole session begins.

---

## 4. Club Announcement

Before each shot, the golfer announces the club they intend to use.

Example:

> Driver

The system records the intended club.

The golfer may change their mind before striking the ball.

Example:

> Change to 3 wood

The system updates the intended club before the shot is recorded.

---

## 5. Shot Execution

After the golfer hits the ball, the system should allow verbal shot feedback.

Examples:

- “I pushed it”
- “I chunked that”
- “That’s in the bunker”
- “Got away with that”
- “That’s wet”

The system records:

- Raw transcript
- Classified shot feedback
- Shot quality indicators
- Time of feedback

The shot remains incomplete until the golfer reaches the ball.

---

## 6. Ball Position Recording

When the golfer walks to the ball and announces the next club, that announcement triggers the end location of the previous shot.

Example:

1. Golfer announces “Driver”
2. Golfer hits ball
3. Golfer says “Pushed it right”
4. Golfer walks to ball
5. Golfer announces “7 iron”

At the moment “7 iron” is announced, the system records the current GPS location as the previous ball position and completes the previous shot.

It then starts the next shot with “7 iron” as the intended club.

---

## 7. Putting Flow

When the golfer selects or announces a putter, the system enters putting mode.

The golfer should be able to verbally record the number of putts required to hole out.

Examples:

- “Two putts”
- “One putt”
- “Three putts”

The system records the putt count against the current hole session.

---

## 8. Hole Completion

A hole may be completed when:

- The golfer records putts, and
- The golfer moves away from the green toward the next tee, or
- The golfer verbally confirms completion.

If the golfer walks off the green and proceeds to the next tee without formally completing the hole, the system should keep the hole record open and allow completion later.

This supports real-world play where golfers may forget to complete scoring immediately.

---

# Round Engine State Model

The Round Engine should support the following states:

```text
Idle
GolfClubDetected
RoundReadyToStart
RoundActive
AwaitingHoleConfirmation
HoleActive
AwaitingClub
ClubSelected
ShotInProgress
AwaitingShotFeedback
AwaitingBallPosition
Putting
HolePendingCompletion
HoleCompleted
RoundCompleted
```

---

# Key Rules

## Rule 1: Golf club choice should be location-led

Manual golf club selection should only be required if geolocation is ambiguous or unavailable.

## Rule 2: Starting hole must be flexible

The system must support starting from any hole.

## Rule 3: Club announcement starts shot intent

A shot begins when a club is announced.

## Rule 4: Next club announcement completes previous shot

The next club announcement captures the current location as the previous ball position.

## Rule 5: Raw voice feedback must be preserved

Shot feedback should always store the raw transcript before classification.

## Rule 6: Putter triggers putting mode

Selecting or announcing a putter changes the workflow to putting capture.

## Rule 7: Hole records may remain open

Walking away from a green should not automatically force completion if required score information is missing.

## Rule 8: GPS should assist, not dominate

GPS should propose context, but golfer confirmation remains available.

---

# Domain Implications

This flow introduces or strengthens the following domain concepts:

- GolfClub
- TeeSet
- TeeColour
- HoleSession
- ShotIntent
- ShotFeedback
- BallPosition
- PuttingSession
- HoleCompletionStatus
- RoundState

These concepts should be represented in GolfCore before advanced AI recommendations are implemented.

---

# AI Implications

The AI Caddy will benefit from this flow because it captures:

- Intended club
- Actual shot result
- Golfer-perceived shot quality
- GPS ball position
- Lie and course position
- Putting outcome
- Hole completion status

This gives the AI richer context than GPS alone and allows future recommendations to consider both measured outcome and golfer perception.

## Round

The Round is the central entity of GolfClubPro.

Every shot, recommendation, statistic and coaching event belongs to a Round.

### Attributes

- RoundID
- PlayerID
- CourseID
- Tee Set
- Start Time
- Finish Time
- Score
- Status

### Status

A Round may be:

- Planned
- Active
- Paused
- Completed
- Abandoned

---

## Hole Session

A Hole Session represents a player's activity on one hole during a Round.

It contains:

- Current hole
- Pin position
- Shots
- Score
- Penalties
- Timing

---

## Shot

A Shot represents a single stroke.

It is one of the most important entities in the system.

### Attributes

- ShotID
- RoundID
- HoleID
- ClubID
- Timestamp
- GPS Start
- GPS Finish
- Carry Distance
- Total Distance
- Launch Direction
- Shot Shape
- Lie
- Weather Context

## Shot Feedback

Shot Feedback captures the golfer's spoken or typed description immediately after a shot.

It allows GolfClubPro to record the golfer's perception of the shot, including direction, contact quality, distance error, course position, and lucky or unlucky outcomes.

Examples include:

- “I pushed it”
- “I chunked that”
- “That’s wet”
- “Got away with that”
- “In the trees”
- “Bladed it”

Shot Feedback is captured as free text first, then classified into structured shot error categories for later recommendation and coaching use.
Future versions may include launch monitor data.

---

## Lie

Lie represents the condition of the golf ball before the shot.

Examples:

- Tee
- Fairway
- Rough
- Sand
- Fringe
- Green

---

## Weather Context

Weather Context captures environmental conditions when the shot occurred.

Attributes include:

- Wind Speed
- Wind Direction
- Temperature
- Humidity
- Pressure

Weather is captured so recommendations can be explained retrospectively.

---

## Recommendation

A Recommendation is advice generated before a shot.

It may include:

- Club
- Aim Point
- Target Distance
- Wind Adjustment
- Confidence Score
- Coaching Notes

Recommendations are advisory only.

The player always remains responsible for shot selection.

---

## Statistics

Statistics are derived information.

Examples include:

- Average Carry
- Fairways Hit
- Greens in Regulation
- Putting Statistics
- Shot Dispersion
- Club Confidence

Statistics are calculated rather than manually entered.

---

## Coaching Session

A Coaching Session represents AI-generated post-round analysis.

It explains:

- Strengths
- Weaknesses
- Trends
- Improvement Opportunities
- Practice Recommendations

---

# Identifier Strategy

Every major entity has a strongly typed identifier.

Examples:

- PlayerID
- DotGolfMemberID
- CourseID
- HoleID
- TeeSetID
- ClubID
- RoundID
- ShotID
- RecommendationID

External identifiers are never reused as internal identifiers.

---

# Domain Relationships

The following relationships define the core model.

- A Player owns many Rounds.
- A Player owns one Equipment Profile.
- A Round references one Course.
- A Course contains many Holes.
- A Hole belongs to one Course.
- A Round contains many Hole Sessions.
- A Hole Session contains many Shots.
- Every Shot uses one Club.
- Every Shot records one Weather Context.
- A Recommendation is generated before a Shot.
- Statistics are calculated from completed Rounds.

---

# Domain Boundaries

The domain layer should never directly depend on:

- SwiftUI
- UIKit
- Core Location
- WeatherKit
- CloudKit
- SwiftData
- Network APIs

Platform-specific services translate external data into domain objects.

---

# Future Domain Expansion

The following capabilities are anticipated but not required for Version 1.

- DotGolf score synchronisation
- Tournament management
- Team competitions
- Club fitting
- Strokes Gained analytics
- Machine learning shot prediction
- Personalised coaching plans
- Course strategy simulation
- Indoor simulator integration
- Launch monitor integration
- Vision Pro round review
- macOS coaching dashboard

---

# Traceability

This document is the authoritative source for GolfCore business entities.

Every Swift model should be traceable back to a corresponding entity defined here.

Any addition, removal, or significant modification to a domain entity must be accompanied by:

- An update to this document.
- A review of the Domain Glossary.
- Consideration of a new or updated Architecture Decision Record (ADR).
