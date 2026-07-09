
# ADR-007: Round Engine State Machine

**Document ID:** GCP-ADR-007  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Data Model, Watch-First Architecture  
**Related ADRs:** ADR-006 Watch-First Architecture

---

# Context

GolfClubPro round play follows a clear sequence of user and location-driven events.

The user:

1. Arrives at a known golf club.
2. Starts a round.
3. Confirms the starting hole.
4. Confirms tee colour.
5. Announces a club.
6. Hits a shot.
7. Records voice feedback.
8. Walks to the ball.
9. Announces the next club, completing the prior shot.
10. Records putts.
11. Completes or leaves the hole pending.

This workflow is stateful and must be predictable.

---

# Decision

The Round Engine will be implemented as a finite state machine.

Each round action must be valid only in appropriate states.

Invalid transitions should return explicit errors.

---

# Core States

- idle
- golfClubDetected
- roundReadyToStart
- roundActive
- awaitingHoleConfirmation
- holeActive
- awaitingClub
- clubSelected
- shotInProgress
- awaitingShotFeedback
- awaitingBallPosition
- putting
- holePendingCompletion
- holeCompleted
- roundCompleted

---

# Design Principles

- The state machine belongs in GolfCore.
- The Watch and iPhone apps consume the state machine but do not own it.
- State transitions must be testable.
- Invalid transitions must fail clearly.
- Voice, GPS and UI events are inputs into the same state machine.

---

# Examples

## Club Announcement

Valid from:

- awaitingClub
- awaitingBallPosition

Result:

- If awaitingClub: create new shot intent.
- If awaitingBallPosition: complete previous shot, then create next shot intent.

## Putter Announcement

Valid from:

- awaitingClub
- awaitingBallPosition

Result:

- Enter putting mode.

## Walk to Next Tee

Valid from:

- putting
- holePendingCompletion

Result:

- Leave current hole pending if scoring is incomplete.

---

# Consequences

## Positive

- Predictable round workflow
- Easier Apple Watch UX
- Better test coverage
- Better AI context
- Safer future GPS and voice integration

## Negative

- Slightly more structure required
- More explicit transition tests needed

---

# Implementation Guidance

The Round Engine should expose clear commands such as:

- startRound
- confirmHole
- confirmTeeSet
- announceClub
- changeClub
- markShotHit
- recordShotFeedback
- recordPutts
- completeCurrentHole
- leaveHolePending
- finishRound

Each command should validate current state before changing the round.

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | YYYY-MM-DD | Initial version |
