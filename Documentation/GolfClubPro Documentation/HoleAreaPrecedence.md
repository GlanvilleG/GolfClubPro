# Hole Area Precedence

**Document ID:** GCP-DOM-001  
**Status:** Accepted  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Owner:** GolfCore Domain Model  
**Related Documents:** ADR-016 Context-Centric Architecture, ADR-017 Course Spatial Index Architecture, GCP-ARCH-003 Spatial Engine Architecture

---

# Purpose

Golf course features frequently overlap within a digital course model.

Examples include:

- A bunker located inside the fairway.
- A green surrounded by fringe.
- A penalty area adjacent to rough.
- Cart paths passing through rough.
- Temporary local-rule areas overlapping existing course features.

The purpose of this document is to define the canonical precedence rules used whenever multiple mapped areas simultaneously contain the golfer's location.

These rules provide deterministic behaviour across the entire GolfClubPro platform.

---

# Design Principles

Hole Area precedence shall:

- Be deterministic.
- Be independent of polygon order.
- Represent golfing meaning rather than drawing order.
- Produce identical results on iPhone and Apple Watch.
- Be used consistently throughout all spatial services.
- Be independent of rendering or user interface concerns.

---

# Evaluation Process

When the golfer's location is evaluated:

1. Every mapped polygon containing the golfer is identified.
2. Each polygon is assigned its defined precedence.
3. The polygon with the highest precedence becomes the primary Hole Area.
4. The remaining polygons are retained as secondary matches for context and future analysis.

The order in which polygons are stored or loaded shall never affect the result.

---

# Canonical Hole Area Precedence

| Priority | Hole Area | Rationale |
|----------:|-----------|-----------|
| 100 | Out of Bounds | Play has left the defined course boundary. |
| 90 | Penalty Area | Rules of Golf require special relief procedures. |
| 80 | Water | Specialised penalty area when modelled separately. |
| 70 | Bunker | Bunkers always override surrounding fairway or rough. |
| 60 | Green | The putting surface has unique Rules of Golf. |
| 50 | Fringe | Transitional putting area surrounding the green. |
| 40 | Fairway | Intended landing and playing area. |
| 30 | Rough | General area outside the fairway. |
| 20 | Trees | Obstructed general area. |
| 15 | Native Area | Environmentally protected or locally defined areas. |
| 10 | Cart Path | Artificial obstruction subject to relief rules. |
| 0 | Unknown | Classification could not be determined. |

---

# Overlapping Area Examples

## Fairway and Bunker

```text
█████████████████████████
█                     █
█      Fairway        █
█                     █
█      ████████       █
█      █ Bunker █     █
█      ████████       █
█                     █
█████████████████████████
```

**Result**

Primary Hole Area:

- Bunker

Secondary Matches:

- Fairway

Reason:

A bunker has a higher golfing significance than the surrounding fairway.

---

## Green and Fringe

```text
FFFFFFFFFFFFFFFFFFFFFFFFF
FFF                 FFFFF
FFF   GGGGGGGGGG    FFFFF
FFF   G Green G     FFFFF
FFF   GGGGGGGGGG    FFFFF
FFF                 FFFFF
FFFFFFFFFFFFFFFFFFFFFFFFF
```

**Result**

Primary Hole Area:

- Green

Secondary Matches:

- Fringe

Reason:

The golfer is considered to be on the putting green.

---

## Rough and Cart Path

```text
RRRRRRRRRRRRRRRRRRRRR
RRRRRRRRRRRRRRRRRRRRR
==== Cart Path ======
RRRRRRRRRRRRRRRRRRRRR
```

**Result**

Primary Hole Area:

- Rough

Secondary Matches:

- Cart Path

Reason:

The cart path remains important for Rules of Golf relief, but it does not redefine the underlying playing area.

Future rules engines may use both areas when determining relief options.

---

## Penalty Area and Water

When both exist:

Primary Hole Area:

- Penalty Area

Secondary Match:

- Water

Reason:

Water is treated as a specialised representation of a penalty area and does not supersede the governing Rules of Golf.

---

# Unknown Area

The `Unknown` Hole Area is returned only when:

- The golfer is outside every mapped polygon.
- Course geometry is incomplete.
- GPS uncertainty prevents reliable classification.
- The mapped area cannot be determined.

`Unknown` represents a valid domain state.

It does **not** represent missing data.

---

# Relationship to Playable Lie

Hole Area precedence determines the golfer's spatial classification.

Playable Lie is derived independently.

Example:

| Hole Area | Playable Lie |
|-----------|--------------|
| Fairway | Fairway |
| Green | Green |
| Bunker | Greenside Bunker or Fairway Bunker |
| Penalty Area | Penalty Area |
| Out of Bounds | Out of Bounds |
| Unknown | Unknown |

This separation allows future refinement of lie classification without altering spatial precedence.

---

# Future Expansion

Future course models may introduce additional area types including:

- Ground Under Repair (GUR)
- No Play Zone
- Dropping Zone
- Waste Area
- Temporary Green
- Temporary Tee
- Practice Area
- Spectator Area
- Construction Area

Any new Hole Area shall be assigned a precedence before implementation.

---

# Testing Requirements

The following behaviours shall be protected by automated unit tests:

- Polygon ordering does not affect precedence.
- Higher priority areas override lower priority areas.
- Overlapping polygons always produce deterministic results.
- Unknown is returned only when no valid classification exists.
- Identical inputs always produce identical outputs.

---

# Engineering Principles

The precedence system follows the GolfClubPro engineering principles:

- Prefer explicit domain states over optionals.
- Compute once, reuse many times.
- Engines own algorithms.
- Domain rules are deterministic.
- Behaviour is platform independent.

---

# Revision History

| Version | Date | Description |
|----------|------------|-----------------------------------------------|
| 1.0.0 | 2026-07-14 | Initial definition of canonical Hole Area precedence. |
