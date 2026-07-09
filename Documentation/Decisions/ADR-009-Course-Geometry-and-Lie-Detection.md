
# ADR-009: Course Geometry and Lie Detection

**Document ID:** GCP-ADR-009  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Data Model, Database Design, GPS and Golf Club Detection  
**Related ADRs:** ADR-008 GPS and Golf Club Detection

---

# Context

GolfClubPro needs to understand where a golf ball has come to rest after each shot.

Knowing the ball's lie is essential for future club recommendations, AI Caddy advice, shot quality analysis, and post-round coaching.

A shot that finishes on the fairway should be treated differently from one that finishes in rough, sand, trees, water, out of bounds, or on the green.

GPS alone can provide position, but position must be interpreted against course geometry.

---

# Decision

GolfClubPro will use course geometry to infer the likely lie of the ball.

The system will support both:

1. **Implicit lie detection** using GPS ball position and course geometry.
2. **Explicit golfer confirmation or correction** using voice, tap, or iPhone review.

Golfer-confirmed lie values take priority over inferred values.

---

# Lie Confidence Priority

Lie source priority is:

```text
golferConfirmed
golferCorrected
inferredFromCourseGeometry
unknown
```

The AI Caddy should treat golfer-confirmed or golfer-corrected lie data as more reliable than automatically inferred lie data.

---

# Course Geometry

Course geometry may include:

- Tee boxes
- Fairways
- Rough zones
- Greens
- Bunkers
- Water hazards
- Tree zones
- Out-of-bounds areas
- Penalty areas
- Fringe areas

Initial implementations may use simple polygons or bounding areas.

Future implementations may use more detailed geospatial data.

---

# Workflow Impact

After a golfer reaches the ball, the system records the ball position.

The position is compared against course geometry.

The system may infer:

- Fairway
- Rough
- Sand
- Trees
- Water
- Out of Bounds
- Green
- Fringe
- Unknown

The system may then ask for confirmation where confidence is low.

Example:

> Looks like rough. Confirm?

The golfer may respond:

> Yes  
> No, fairway  
> Bunker  
> In the trees

---

# Watch-First Behaviour

On Apple Watch, confirmation should remain low-friction.

Preferred interactions:

- Voice confirmation
- One-tap confirmation
- Correction list only when required
- No long manual entry during play

---

# Domain Implications

This decision introduces or strengthens:

- CourseGeometry
- CourseArea
- CourseAreaType
- LieSource
- InferredLie
- ConfirmedLie
- DetectionConfidence

---

# Data Model Implications

Shot should support:

- Inferred lie
- Confirmed lie
- Final lie
- Lie source
- Detection confidence

The final lie should be derived from priority rules.

---

# GolfCore Boundary

GolfCore should not depend directly on MapKit or Core Location.

The app layer converts platform coordinates into GolfCore `GeoCoordinate`.

GolfCore may perform geometry-based classification using domain-level geometry types.

---

# Consequences

## Positive

- Better shot context
- Better AI recommendations
- Less manual input
- Improved post-round analysis
- More accurate club performance tracking

## Negative

- Requires course geometry data
- GPS accuracy may affect inferred lie
- Geometry quality varies by course
- Edge cases require golfer correction

---

# Implementation Guidance

Initial implementation should include:

- `CourseArea`
- `CourseAreaType`
- `CourseGeometry`
- `LieSource`
- `LieDetectionResult`
- `LieDetector`

The first implementation may use simple polygon containment.

Future versions may include confidence scoring, distance-to-boundary checks, and GPS uncertainty modelling.

---

# Related Future Work

- GPS smoothing
- Course geometry editor
- Green and fairway polygon import
- Hazard mapping
- Course data versioning
- Shot confidence scoring
- AI recommendation adjustment based on lie

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
