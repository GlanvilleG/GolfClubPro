
# ADR-014: Intelligent Round Orchestrator

**Document ID:** GCP-ADR-014  
**Status:** Accepted  
**Date:** 2026-07-10
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Watch-First Architecture, Round Engine State Machine, Offline-First Architecture, AI Caddy Architecture  
**Related ADRs:** ADR-006 Watch-First Architecture, ADR-007 Round Engine State Machine, ADR-008 GPS and Golf Club Detection, ADR-011 AI Caddy Architecture, ADR-013 Offline-First Architecture

---

# Context

GolfClubPro is designed to support a golfer during a live round using Apple Watch, iPhone, voice, GPS, motion sensing, course geometry, weather, and recommendation services.

The deterministic `RoundEngine` currently manages valid golf-state transitions such as:

- Starting a round
- Confirming a hole
- Selecting a club
- Marking a shot as played
- Recording shot feedback
- Completing a shot
- Recording putts
- Completing a hole
- Completing a round

However, the user interface and platform services should not call these transitions independently without context.

A golfer’s real behaviour is event-driven.

Examples include:

- Walking onto a tee
- Confirming a hole
- Announcing a club
- Taking one or more practice swings
- Addressing the ball
- Making a committed swing
- Hitting the ball
- Giving verbal feedback
- Walking to the next ball position
- Changing club
- Entering the green
- Leaving a hole before completing scoring

These events may be detected by different services and may arrive asynchronously or with uncertainty.

A dedicated orchestration layer is required to interpret these signals and decide when to invoke deterministic domain transitions.

---

# Decision

GolfClubPro will introduce an **Intelligent Round Orchestrator** above the `RoundEngine`.

The orchestrator will:

- Receive platform and user events.
- Maintain interaction and sensor state.
- Correlate GPS, motion, voice, timing, and round context.
- Distinguish practice swings from played shots.
- Request golfer confirmation where confidence is insufficient.
- Invoke `RoundEngine` only when a golf event has been sufficiently validated.
- Persist resulting transitions through the offline coordinator.
- Recover orchestration state after interruption.

The `RoundEngine` remains the authoritative owner of valid golf-domain state transitions.

---

# Architecture

```text
Apple Watch UI
Voice Recognition
Motion Sensors
GPS and Location
Weather
Watch Connectivity
Haptics
        │
        ▼
Round Orchestrator
        │
        ├── Event interpretation
        ├── Confidence assessment
        ├── Practice-swing handling
        ├── User confirmation
        ├── Timing
        └── Prompt selection
        │
        ▼
Persistent Offline Round Coordinator
        │
        ▼
Round Engine
        │
        ▼
Active Round Snapshot
Offline Event Queue
```

---

# Separation of Responsibilities

## Round Engine

The `RoundEngine` owns golf rules and valid domain transitions.

It determines whether operations such as these are valid:

- Confirm hole
- Select club
- Change club
- Mark shot hit
- Record feedback
- Record putts
- Complete hole
- Complete round

It does not interpret raw sensors or decide whether a swing was a practice swing.

---

## Round Orchestrator

The orchestrator owns interaction flow and interpretation.

It determines:

- What likely happened
- Whether more evidence is required
- Whether golfer confirmation is needed
- Which domain command should occur next
- Which prompt or haptic should be presented
- Whether an event should be ignored, deferred, or escalated

---

## Platform Services

Platform services produce neutral observations.

Examples:

- Location observation
- Motion observation
- Speech transcript
- Watch connectivity event
- Weather update
- Haptic request

Platform services must not directly mutate the round.

---

# Orchestrator State

The orchestrator will maintain a separate state from `RoundState`.

```swift
public enum OrchestratorState:
    String,
    Codable,
    Sendable {

    case idle
    case detectingGolfClub
    case awaitingRoundConfirmation
    case awaitingHoleDetection
    case awaitingHoleConfirmation
    case awaitingTeeConfirmation
    case awaitingClubSelection
    case clubSelected
    case preparingForShot
    case addressDetected
    case practiceSwingDetected
    case awaitingCommittedSwing
    case validatingCandidateSwing
    case awaitingShotConfirmation
    case shotConfirmed
    case awaitingShotFeedback
    case walkingToBall
    case awaitingLieConfirmation
    case putting
    case holePendingCompletion
    case recovering
}
```

These states describe the user and sensor interaction workflow.

They do not replace the golf-domain states inside `Round`.

---

# Orchestrator Events

The orchestrator will consume neutral events such as:

```swift
public enum RoundOrchestratorEvent:
    Codable,
    Equatable,
    Sendable {

    case locationUpdated(LocationObservation)
    case golfClubDetected(GolfClubID, confidence: Double)
    case holeDetected(HoleID, confidence: Double)
    case teeSetSelected(TeeSetID)

    case clubSelected(ClubID)
    case clubChanged(ClubID)

    case addressDetected
    case swingDetected(SwingObservation)
    case impactDetected(ImpactObservation)
    case golferDepartedShotOrigin
    case candidateSwingTimeout

    case shotConfirmedByGolfer
    case practiceSwingConfirmedByGolfer
    case candidateSwingRejected

    case voiceFeedbackReceived(String)
    case lieConfirmed(PlayableLie)
    case lieCorrected(PlayableLie)

    case puttsRecorded(Int)
    case holeCompletionRequested
    case roundCompletionRequested

    case connectivityChanged(Bool)
    case applicationRestored
}
```

The precise event models may evolve, but platform-specific framework types must not enter GolfCore.

---

# Practice Swing Decision

A detected swing is not automatically a played shot.

Every swing begins as a **candidate swing**.

The orchestrator must classify it as one of:

```swift
public enum SwingClassification:
    String,
    Codable,
    Sendable {

    case practice
    case playedShot
    case uncertain
    case golferCorrected
}
```

Practice swings must not call:

```swift
roundEngine.markShotHit(for:)
```

A played shot transition occurs only after the candidate is confirmed by sufficient evidence or by the golfer.

---

# Candidate Swing Evidence

The orchestrator may consider:

- Club already selected
- Golfer near expected ball position
- Address posture detected
- Motion profile consistent with a golf swing
- Peak rotational velocity
- Peak acceleration
- Impact-like vibration
- No immediate return to address
- Movement away from the shot origin
- Voice feedback shortly after the swing
- New club selection at a different location
- Golfer confirmation

No individual signal is considered perfectly reliable.

---

# Practice Swing Indicators

A swing is more likely to be a practice swing when:

- The golfer returns immediately to the same address position.
- No impact-like signal is detected.
- The golfer remains at the same location.
- Another swing follows shortly afterwards.
- No verbal shot feedback is recorded.
- No movement toward a ball destination occurs.
- The golfer says “practice swing,” “not that one,” or similar.
- The golfer explicitly rejects the candidate.

---

# Played Shot Indicators

A swing is more likely to be a played shot when:

- A committed swing profile is detected.
- An impact-like event occurs.
- The golfer leaves the shot origin.
- The golfer gives immediate shot feedback.
- A new club is selected at a new location.
- The previous ball position is confirmed by GPS.
- The golfer explicitly confirms the shot.

---

# Confidence Model

Candidate-swing confidence should be built from weighted evidence.

An initial configurable model may use:

```text
Committed swing profile          +0.30
Impact-like event                +0.25
Golfer leaves shot origin        +0.20
Voice feedback received          +0.15
Next club selected elsewhere     +0.10
```

Suggested initial outcomes:

```text
0.70 or above    Automatically confirm played shot
0.40 to 0.69     Ask golfer for confirmation
Below 0.40       Treat as practice swing
```

These thresholds are initial assumptions and must be calibrated through field testing.

---

# Confirmation Behaviour

The Watch should not prompt after every detected swing.

## High confidence

For a high-confidence played shot:

- Provide a short haptic.
- Transition to shot feedback capture.
- Allow immediate cancellation or correction.

## Medium confidence

Ask:

> Was that the shot?

Available responses:

- Yes
- No, practice swing
- Cancel

## Low confidence

Treat silently as a practice swing unless later evidence raises confidence.

---

# Deferred Confirmation

Some candidate swings may remain unresolved temporarily.

Example:

1. A swing is detected.
2. No impact signal is available.
3. The golfer remains nearby.
4. No prompt is shown immediately.
5. The golfer walks away and gives shot feedback.
6. Confidence increases.
7. The orchestrator confirms the shot retrospectively.

The orchestrator must support delayed evidence without duplicating shots.

---

# Candidate Swing Model

The initial model should include:

```swift
public struct SwingObservation:
    Codable,
    Equatable,
    Sendable {

    public var observedAt: Date
    public var durationSeconds: Double
    public var peakAcceleration: Double?
    public var peakRotationRate: Double?
    public var returnedToAddress: Bool
    public var confidence: Double
}
```

A candidate may aggregate multiple observations:

```swift
public struct CandidateSwing:
    Codable,
    Equatable,
    Sendable {

    public var observation: SwingObservation
    public var origin: GeoCoordinate?
    public var impactDetected: Bool
    public var golferDepartedOrigin: Bool
    public var feedbackReceived: Bool
    public var nextClubSelectedElsewhere: Bool
    public var computedConfidence: Double
    public var classification: SwingClassification
}
```

---

# Event Processing Rules

The orchestrator must process events deterministically.

Examples:

## Club selection

```text
awaitingClubSelection
    + clubSelected
    → clubSelected
```

## Practice swing

```text
clubSelected
    + swingDetected
    + low confidence
    → practiceSwingDetected
    → awaitingCommittedSwing
```

## Ambiguous swing

```text
clubSelected
    + swingDetected
    + medium confidence
    → awaitingShotConfirmation
```

## Confirmed played shot

```text
awaitingShotConfirmation
    + shotConfirmedByGolfer
    → invoke markShotHit
    → awaitingShotFeedback
```

## Rejected swing

```text
awaitingShotConfirmation
    + practiceSwingConfirmedByGolfer
    → discard candidate
    → awaitingCommittedSwing
```

---

# Shot Feedback Integration

After a played shot is confirmed, the orchestrator should prompt for brief feedback.

Examples:

- “How was that?”
- “What happened?”
- “Record shot result?”

The transcript is passed to:

```swift
ShotFeedbackNormalizer
```

and then persisted through the offline round coordinator.

---

# Walking-to-Ball Integration

After shot confirmation and feedback:

- The orchestrator enters `walkingToBall`.
- GPS updates are monitored.
- The next club announcement confirms the previous ball location.
- Course geometry infers the course area.
- Lie detection infers an initial playable lie.
- The golfer is prompted only when lie confirmation is required.

---

# Putting Integration

When the selected club is a putter:

- The orchestrator enters putting mode.
- Motion-based full-swing detection should be reduced or ignored.
- The golfer may verbally record putt count.
- The hole may remain pending if the golfer walks away without completing entry.

---

# Offline Operation

The orchestrator must function without network access.

It may depend on:

- Active round snapshot
- Cached course geometry
- Cached strategy geometry
- Cached weather
- Local motion observations
- Local voice transcription where available
- Offline event queue

Network failure must not prevent practice-swing detection or shot confirmation.

---

# Persistence and Recovery

The orchestrator state should be recoverable after:

- App termination
- Watch restart
- iPhone restart
- Connectivity loss
- Temporary suspension

A future `RoundOrchestratorSnapshot` should persist:

- Orchestrator state
- Active candidate swing
- Recent observations
- Pending confirmation
- Last prompt
- Last known location
- Active round identifier
- Sequence metadata

---

# Watch and iPhone Responsibilities

## Apple Watch

Primary responsibilities:

- Motion sensing
- Haptics
- Voice interaction
- Immediate prompts
- Active candidate handling
- Basic offline continuation

## iPhone

Primary responsibilities:

- Long-term persistence
- Course geometry
- Weather acquisition
- Detailed review
- Conflict handling
- Recommendation audit
- Sync coordination

The orchestrator may have device-specific adapters while retaining one shared domain model.

---

# Audit and Learning

Swing-detection auditing should be optional.

A future user preference may control whether candidate-swing observations are retained for model improvement.

Possible audit fields include:

- Motion confidence
- Impact confidence
- Movement evidence
- Voice evidence
- Initial classification
- Golfer correction
- Final classification
- Device type
- Detection thresholds
- Associated shot identifier

The system must not retain unnecessary raw motion data by default.

---

# Privacy

Motion and voice data should be minimised.

The system should:

- Store derived observations rather than continuous raw sensor streams where practical.
- Retain raw voice only when explicitly enabled.
- Keep swing-learning audit features opt-in.
- Avoid external transmission without informed consent.
- Support deletion and export.

---

# Error Handling

The orchestrator must handle:

- Duplicate swing observations
- Out-of-order sensor events
- Missing GPS
- Missing motion evidence
- Missing impact evidence
- Voice recognition failure
- User rejection
- App suspension during candidate validation
- Watch disconnection
- Recovery with unresolved candidate swing

An unresolved candidate should not silently create a shot.

---

# Testing Requirements

Tests should cover:

- One practice swing followed by a played shot
- Multiple practice swings
- High-confidence automatic confirmation
- Medium-confidence golfer confirmation
- Low-confidence silent rejection
- Golfer rejects a candidate swing
- Voice feedback increases confidence
- Movement away increases confidence
- Duplicate motion event does not create duplicate shot
- App recovery during candidate validation
- Putter mode suppresses full-swing handling
- Offline candidate classification
- Delayed shot confirmation
- Candidate timeout
- Correct Round Engine transition after confirmation

---

# Alternatives Considered

## UI Directly Calls Round Engine

Rejected because UI elements cannot reliably interpret sensor context and asynchronous evidence.

## Motion Event Equals Shot

Rejected because golfers commonly take practice swings.

## Fully Automatic Shot Detection Only

Rejected for the initial implementation because sensor confidence and golfer behaviour vary.

## Manual Shot Confirmation Only

Rejected because it creates unnecessary friction and underuses Apple Watch sensors.

---

# Consequences

## Positive

- Supports natural golfer behaviour
- Avoids recording practice swings as shots
- Centralises sensor interpretation
- Keeps RoundEngine deterministic
- Supports future sensor fusion
- Enables intelligent Watch prompts
- Provides a path to automatic shot detection
- Supports delayed evidence and correction

## Negative

- Introduces another state machine
- Requires careful event ordering
- Requires confidence calibration
- Requires recovery logic
- Motion and voice testing is more complex
- False positives and false negatives must be monitored

---

# Implementation Sequence

1. Add orchestrator event models.
2. Add `SwingObservation`.
3. Add `CandidateSwing`.
4. Add `SwingClassification`.
5. Add `OrchestratorState`.
6. Add confidence calculation.
7. Add practice-swing classification.
8. Add `RoundOrchestrator`.
9. Add orchestrator snapshot persistence.
10. Add Watch motion adapter.
11. Add voice adapter.
12. Add location adapter.
13. Add haptic output adapter.
14. Add Watch Connectivity integration.
15. Field-test thresholds.

---

# Documentation Impact

This decision requires updates to:

- Domain Model
- Data Model
- System Architecture
- Watch UX
- AI Caddy Design
- Offline Architecture
- Testing Strategy
- Privacy documentation
- Domain Glossary
- Roadmap

---

# Future Considerations

Future versions may include:

- Personalised swing-detection thresholds
- On-device swing classification
- Impact acoustics
- Club-specific motion profiles
- Left- and right-handed motion models
- Automatic putt detection
- Practice-session mode
- Training-swing analysis
- Swing-tempo coaching
- Sensor confidence learning
- Multi-device sensor fusion

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
