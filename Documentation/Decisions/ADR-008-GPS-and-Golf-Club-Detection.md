
# ADR-008: GPS and Golf Club Detection

**Document ID:** GCP-ADR-008  
**Status:** Accepted  
**Date:** 2026-07-110
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Data Model, System Architecture, Watch-First Architecture  
**Related ADRs:** ADR-006 Watch-First Architecture, ADR-010 Offline First Strategy

---

# Context

GolfClubPro should minimise user input during a round.

When a golfer arrives at a known golf club, the system should use geolocation to identify the club automatically instead of requiring manual course selection.

After the round starts, the system should use known GPS locations for tee boxes, greens, and holes to assist with:

- Golf club detection
- Starting hole detection
- Hole confirmation
- Ball position recording
- Shot distance calculation
- Round flow progression

---

# Decision

GolfClubPro will use GPS-assisted detection for golf club, course, hole, tee, and ball position context.

The system will propose detected context but should allow the golfer to confirm or correct it.

GPS will assist the user experience, but golfer confirmation remains available where uncertainty exists.

---

# Scope

ADR-008 covers:

- Golf club detection
- Course context
- Hole detection
- Tee location confirmation
- Ball position recording
- Shot distance support

It does not yet define advanced shot prediction, AI recommendations, or course mapping algorithms.

---

# Design Principles

## Location-led, not menu-led

The app should first infer where the golfer is.

Manual selection should be required only when:

- GPS is unavailable
- Multiple clubs are nearby
- Course data is missing
- Detection confidence is too low

---

## GPS proposes, golfer confirms

The system may suggest:

> Start round at Whanganui Golf Club?

or:

> Are you starting on Hole 10 from the White tees?

The golfer should be able to confirm or correct the suggestion.

---

## Offline capable

Previously downloaded or bundled course data should support club and hole detection without network access.

---

## Apple ecosystem first

Core Location and MapKit should be preferred before third-party mapping or GPS libraries.

---

# Golf Club Detection

A GolfClub should have a known reference location and optional boundary.

The detection process should consider:

- Current user location
- Distance to known golf club reference point
- Golf club boundary
- Confidence threshold
- Course data availability

If only one known golf club is within range, the system may propose it.

If multiple clubs are nearby, the system should ask the golfer to choose.

---

# Hole Detection

Hole detection should use known tee and green locations.

Detection may consider:

- Current GPS location
- Proximity to tee boxes
- Previously played hole
- Direction of movement
- Round state
- Course layout

The system should support starting from any hole.

Common starting holes are Hole 1 and Hole 10, but this must not be assumed.

---

# Tee Confirmation

After detecting the hole, the golfer should confirm the tee colour or tee set.

Examples:

- Black
- Blue
- White
- Yellow
- Red
- Other

The selected tee set becomes part of the active round context.

---

# Ball Position Recording

GolfClubPro should record ball position when the golfer reaches the ball.

In the watch-first workflow, the next club announcement may trigger the end location of the previous shot.

Example:

1. Golfer announces Driver.
2. Golfer hits shot.
3. Golfer gives voice feedback.
4. Golfer walks to ball.
5. Golfer announces 7 iron.
6. System records current GPS location as previous ball position.
7. System starts next shot with 7 iron.

---

# Shot Distance

Shot distance should be calculated using:

- Start GPS coordinate
- End GPS coordinate

Initial implementation may use straight-line distance.

Future implementations may include:

- Elevation adjustment
- Carry vs roll estimation
- Shot curve estimation
- Wind-adjusted effective distance

---

# Domain Implications

The following domain concepts are required or strengthened:

- GolfClub
- Course
- Hole
- TeeSet
- TeeColour
- GeoCoordinate
- BallPosition
- Shot start location
- Shot end location
- Detection confidence

---

# Service Boundary

GolfCore should not directly depend on Core Location.

Instead:

- Core Location collects platform GPS data.
- The application layer converts GPS data into `GeoCoordinate`.
- GolfCore consumes `GeoCoordinate`.

This preserves the independence and testability of GolfCore.

---

# Error and Ambiguity Handling

The system must handle:

- No GPS signal
- Weak GPS signal
- Multiple nearby golf clubs
- Unknown golf club
- Unknown starting hole
- User correction
- Incomplete course data

In all cases, the system should degrade gracefully rather than blocking play.

---

# Consequences

## Positive

- Reduced user input
- Faster round start
- Better Apple Watch experience
- Richer shot data
- Stronger AI recommendation context

## Negative

- GPS accuracy may vary
- Course data quality becomes important
- Additional confirmation flows are required
- Battery usage must be managed carefully

---

# Implementation Guidance

Initial implementation should focus on:

1. `GolfClubDetector`
2. `HoleDetector`
3. Distance calculation using `GeoCoordinate`
4. User confirmation flow
5. Graceful fallback to manual selection

GolfCore should contain the detection logic where possible, but platform-specific GPS acquisition belongs outside GolfCore.

---

# Future Considerations

Future versions may include:

- Geofenced course boundaries
- Tee box polygons
- Green polygons
- Fairway geometry
- Hazard geometry
- Elevation data
- GPS smoothing
- Automatic shot detection
- Confidence scoring
- Course data update service

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
