
# ADR-013: Offline-First Architecture

**Document ID:** GCP-ADR-013  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** System Architecture, Database Design, Watch-First Architecture, Recommendation Engine, Weather Integration  
**Related ADRs:** ADR-005 SwiftData Persistence Strategy, ADR-006 Watch-First Architecture, ADR-008 GPS and Golf Club Detection, ADR-011 AI Caddy Architecture, ADR-012 Weather Integration

---

# Context

GolfClubPro must remain usable throughout a round even when mobile data, Wi-Fi, WeatherKit, CloudKit, or external services are unavailable.

Golf courses may have:

- Weak mobile coverage
- No Wi-Fi
- Intermittent connectivity
- Device handoff failures
- Temporary Apple service outages
- Delayed Watch-to-iPhone communication

Core round functions must not depend on continuous network access.

These functions include:

- Starting a round
- Confirming the course and hole
- Selecting a tee set
- Recording clubs
- Recording shots
- Capturing voice feedback
- Recording ball positions
- Inferring lie from cached course geometry
- Recording putts
- Completing holes
- Producing deterministic recommendations
- Completing the round

---

# Decision

GolfClubPro will use an **offline-first architecture**.

The local device state will be treated as the immediate source of truth during an active round.

Network services will enhance the experience but must not control or block the core round workflow.

Local changes will be queued and synchronised when connectivity becomes available.

---

# Offline-First Principles

## Local operation is primary

The application must write round activity locally before attempting any network operation.

## Network access is optional during play

Network services may provide:

- Updated weather
- Cloud backup
- Course data updates
- DotGolf integration
- Shared-round updates
- AI explanation services

Failure of these services must not prevent continued play.

## Synchronisation is deferred

Changes should be synchronised after local persistence succeeds.

## User data must not be lost

The active round should survive:

- Application termination
- Device restart
- Temporary Watch disconnection
- Network loss
- Background suspension

## Conflict resolution must be explicit

Conflicts must be handled by deterministic rules rather than silent data loss.

---

# Architectural Model

```text
Apple Watch
    │
    ├── Active round cache
    ├── Current hole
    ├── Recent shots
    └── Pending commands
            │
            ▼
Watch Connectivity
            │
            ▼
iPhone Local Store
    │
    ├── SwiftData
    ├── Sync queue
    ├── Course cache
    ├── Weather cache
    └── Recommendation audit
            │
            ▼
Cloud Services
    │
    ├── CloudKit
    ├── DotGolf
    ├── Course update service
    └── Optional AI services
```

---

# Device Responsibilities

## Apple Watch

The Watch should retain enough information to continue the active round independently for short periods.

Minimum Watch-local state should include:

- Active RoundID
- PlayerID
- GolfClubID
- CourseID
- TeeSetID
- Current hole
- Current hole session
- Recent shot records
- Current club selection
- Pending shot feedback
- Cached course geometry required for active holes
- Most recent weather snapshot
- Pending synchronisation events

The Watch should not be the primary long-term historical store.

---

## iPhone

The iPhone should act as the primary local data store.

It should maintain:

- Player profile
- Equipment
- Course data
- Course geometry
- Round history
- Shot history
- Recommendation audit records
- Weather cache
- Pending sync operations
- Conflict records
- Export and backup data

---

# Local Source of Truth

During an active round:

1. A user action is recorded locally.
2. The local round state is updated.
3. The action is added to a pending synchronisation queue.
4. The UI confirms success.
5. Synchronisation occurs separately.

The UI must not wait for network acknowledgement before confirming a locally valid action.

---

# Active Round Persistence

The active round must be persisted after every material transition.

Examples include:

- Round started
- Tee set confirmed
- Hole confirmed
- Club selected
- Club changed
- Shot marked as hit
- Shot feedback recorded
- Ball position recorded
- Lie inferred
- Lie confirmed or corrected
- Putts recorded
- Hole completed
- Hole left pending
- Round completed

This ensures that the round can be reconstructed after interruption.

---

# Event Queue

GolfClubPro should maintain a local queue of pending operations.

Examples:

- Upload round
- Upload shot
- Update player profile
- Upload recommendation audit
- Synchronise course update
- Submit DotGolf score
- Upload shared-round changes

Each queued event should contain:

- Event identifier
- Event type
- Entity identifier
- Creation time
- Attempt count
- Last attempt time
- Status
- Error information
- Payload version

---

# Queue Status

A queued event may be:

- Pending
- Processing
- Completed
- Failed
- Deferred
- Cancelled

Failed events should not be deleted automatically.

---

# Idempotency

Synchronisation operations should be idempotent where practical.

Repeating the same upload should not create duplicate:

- Rounds
- Shots
- Recommendations
- Audit records
- Player records

Strongly typed entity identifiers should be used as stable idempotency keys.

---

# Watch-to-iPhone Synchronisation

Watch Connectivity should be used for Watch-to-iPhone data transfer.

The synchronisation process must support:

- Immediate messaging when both devices are reachable
- Background transfer
- Queued transfer when disconnected
- Duplicate-event detection
- Ordered round-state updates
- Recovery after application restart

The Watch should retain unacknowledged events until the iPhone confirms receipt.

---

# Event Ordering

Some events must be processed in sequence.

Example:

```text
Round Started
    ↓
Hole Confirmed
    ↓
Club Selected
    ↓
Shot Recorded
    ↓
Shot Completed
    ↓
Hole Completed
```

Each event should include:

- RoundID
- Sequence number
- Timestamp

Sequence numbers should be preferred over timestamps alone for ordering active-round events.

---

# Conflict Resolution

Conflicts may occur when Watch and iPhone both modify related data.

## Active-round rule

For active-round events, preserve all valid events and reconstruct the round by sequence.

## Shot rule

Shot records should be append-only where practical.

A corrected shot should retain:

- Original values
- Corrected values
- Correction time
- Correction source

## Player profile rule

Use the latest valid update while preserving sync metadata.

## Course data rule

Use explicit course-data versions.

## Recommendation audit rule

Audit records should be append-only and should not be silently overwritten.

---

# Duplicate Detection

Duplicate events should be detected using:

- Stable event identifier
- Entity identifier
- Event type
- Sequence number

Duplicate events may be acknowledged and ignored safely.

---

# Recovery Behaviour

When the application restarts during a round:

1. Load the active round from local persistence.
2. Restore the current RoundState.
3. Restore the current HoleSession.
4. Restore any incomplete shot.
5. Restore pending feedback.
6. Restore queued sync events.
7. Resume from the last valid transition.

The user should not need to restart the round.

---

# Course Data Cache

Course geometry required for a round must be available before play begins.

The cached course package may include:

- Golf club details
- Course layout
- Hole details
- Tee sets
- Tee locations
- Green locations
- Course areas
- Hazards
- Landing zones
- Strategy geometry
- Course-data version

The round should not start automatically if essential course data is incomplete without warning the golfer.

---

# Weather Cache

The most recent usable weather snapshot should be cached locally.

When live weather becomes unavailable:

- Use the cached snapshot.
- Mark it as cached or stale.
- Reduce recommendation confidence.
- Continue play.

Weather retrieval failure must not create a failed round state.

---

# Recommendation Behaviour Offline

The deterministic recommendation engine should remain fully available offline using:

- Cached course geometry
- Player clubs
- Historical summaries
- Dispersion summaries
- Current lie
- Current round state
- Cached weather if available

Network-based explanation or learning services must be optional.

---

# DotGolf Integration

DotGolf synchronisation should occur outside the live round state machine.

If score submission fails:

- Preserve the completed round locally.
- Queue the submission.
- Show sync status on iPhone.
- Allow manual retry.
- Do not mark the local round as failed.

---

# Data Integrity

Local writes should be transactional where practical.

A material round transition should not partially update related state.

For example, completing a shot should update together:

- End position
- Completion time
- Distance
- Inferred course area
- Inferred playable lie
- Lie confidence
- Confirmation requirement
- Hole session
- Round state

---

# Sync Metadata

Persisted entities should eventually support:

- CreatedAt
- UpdatedAt
- DeviceID
- SyncStatus
- LastSyncedAt
- LocalRevision
- RemoteRevision
- IsDeleted
- PayloadVersion

These fields belong in persistence infrastructure rather than pure GolfCore domain models unless required for domain behaviour.

---

# Deletion Strategy

Deletes should use a tombstone strategy when synchronisation is involved.

A deleted record should retain enough metadata to communicate the deletion to other devices.

Permanent deletion may occur after successful synchronisation and retention rules are satisfied.

---

# Recommendation Audit

When recommendation auditing is enabled:

- Create the audit record locally.
- Link it to the active round.
- Queue it for synchronisation.
- Preserve it if cloud upload fails.
- Link the actual shot when available.

Audit capture must not delay the recommendation.

---

# User Experience

The application should show clear but unobtrusive sync status.

Possible statuses include:

- Saved locally
- Sync pending
- Synced
- Sync failed
- Action required

During play, the Watch should not repeatedly interrupt the golfer because of sync failures.

Detailed recovery actions should remain on iPhone.

---

# Privacy and Security

Queued data must receive the same protection as synchronised data.

The application should use:

- Apple data protection
- Secure local persistence
- Minimum required retention
- Encrypted network transport
- User-controlled sharing
- Clear deletion and export controls

---

# Failure Scenarios

The architecture must handle:

- No mobile service
- iPhone unavailable
- Watch unavailable
- Watch and iPhone disconnected
- Application crash
- Device restart
- CloudKit unavailable
- WeatherKit unavailable
- DotGolf unavailable
- Duplicate events
- Out-of-order events
- Partially completed sync
- Low storage
- Course-data version mismatch

---

# Testing Requirements

Tests should cover:

- Starting and completing a round offline
- Application restart during a round
- Incomplete shot recovery
- Watch disconnection
- Queued event persistence
- Duplicate event handling
- Out-of-order event handling
- Sync retry
- Sync failure retention
- Course-data cache availability
- Stale weather fallback
- Recommendation generation offline
- DotGolf submission retry
- Conflict resolution
- Audit-record preservation

---

# Alternatives Considered

## Network-First Architecture

Rejected because golf-course connectivity cannot be assumed.

## iPhone-Only Source of Truth

Rejected because the Watch must continue to support the golfer when temporarily disconnected.

The iPhone remains the primary long-term store, but the Watch retains sufficient active-round state.

## Immediate Cloud Writes

Rejected because waiting for cloud acknowledgement would increase latency and create avoidable failure points.

---

# Consequences

## Positive

- Reliable on-course operation
- Reduced risk of lost round data
- Fast Watch interactions
- Resilience to network and service outages
- Clear synchronisation boundary
- Supports future multi-device use

## Negative

- Requires sync queues
- Requires conflict handling
- Requires duplicate detection
- Requires local recovery logic
- Increases persistence and testing complexity

---

# Implementation Sequence

1. Define offline event models.
2. Add active-round snapshot persistence.
3. Add local sync queue.
4. Add event sequence numbers.
5. Add Watch transfer queue.
6. Add acknowledgement handling.
7. Add duplicate detection.
8. Add retry policy.
9. Add conflict-resolution services.
10. Add sync-status UI.
11. Add CloudKit synchronisation.
12. Add DotGolf submission queue.

---

# Documentation Impact

This decision requires updates to:

- System Architecture
- Database Design
- Data Model
- Watch-First Architecture
- Build and Deployment Guide
- Testing Strategy
- Incident Management
- Backup Strategy
- Privacy and Security documentation

---

# Future Considerations

Future versions may include:

- Multi-device active-round handoff
- Shared group rounds
- Coach live-view mode
- Background CloudKit synchronisation
- Peer-to-peer round sharing
- Conflict visualisation
- Server-side event processing
- Cross-platform sync services
- Analytics export pipelines

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
