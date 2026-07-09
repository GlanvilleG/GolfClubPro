//
//  Domain..swift
//  GolfClubPro
//
//  Created by Dragon Development on 08/07/2026.
//
# GolfClubPro Domain Model

## Purpose

This document defines the core business concepts used by GolfClubPro and the GolfCore package.

The purpose of the domain model is to create a stable foundation for GPS tracking, shot analytics, DotGolf integration, weather-aware recommendations, AI caddy behaviour, and post-round coaching.

## Design Principles

- GolfCore owns the core golf concepts.
- Product-specific UI belongs in GolfClubPro.
- Identifiers are strongly typed to avoid mixing players, courses, rounds, holes, clubs, and shots.
- External identifiers, such as DotGolf membership numbers, are separated from internal system identifiers.
- Models should remain independent of SwiftUI, CoreLocation, WeatherKit, CloudKit, and SwiftData where practical.
- Business rules belong in the Domain layer, not in the data models.

## Identifier Strategy

GolfClubPro uses separate identifier types instead of raw strings or UUIDs.

Examples:

- PlayerID
- DotGolfMemberID
- CourseID
- HoleID
- ClubID
- RoundID
- ShotID

This prevents accidental misuse, such as passing a RoundID where a PlayerID is expected.

## Core Entities

### Player

A Player represents a golfer using the application.

A Player may have:

- Internal PlayerID
- DotGolfMemberID
- Name
- Handicap index
- Equipment profile
- Historical shot data

The DotGolf identifier is optional because the app must support users who are not linked to DotGolf.

### Club

A Club represents one item of playing equipment.

A Club may have:

- ClubID
- Name
- Club type
- Average carry distance
- Dispersion history
- Confidence rating

### Course

A Course represents a golf facility or playable course layout.

A Course may have:

- CourseID
- Name
- Location
- Number of holes
- Tee sets
- Local rules
- Hole definitions

### Hole

A Hole represents one playable hole on a course.

A Hole may have:

- HoleID
- Hole number
- Par
- Stroke index
- Tee locations
- Green location
- Hazards
- Ideal landing zones

### Round

A Round represents one playing session by a player on a course.

A Round may have:

- RoundID
- PlayerID
- CourseID
- Start time
- Finish time
- Selected tee set
- Holes played
- Shots recorded

### Shot

A Shot represents one stroke or recorded ball movement event.

A Shot may have:

- ShotID
- RoundID
- HoleID
- ClubID
- Start position
- End position
- Distance
- Direction
- Lie
- Weather context
- Penalty context

## Future Integration Notes

### DotGolf

DotGolf should be isolated behind a service interface. The core Player model should not depend directly on DotGolf API structures.

### GPS

GPS coordinates should be introduced through a neutral domain type first, rather than exposing CoreLocation throughout GolfCore.

### Weather

Weather data should be captured as a shot context, so historical recommendations can be explained later.

### AI Caddy

The AI caddy should consume domain objects and historical shot data. It should not own the source of truth for player, round, or shot data.
