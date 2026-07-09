
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
