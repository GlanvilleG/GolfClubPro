
# ADR-012: Weather Integration

**Document ID:** GCP-ADR-012  
**Status:** Accepted  
**Date:** 2026-07-10  
**Decision Makers:** Solution Architecture  
**Related Documents:** Domain Model, Data Model, AI Caddy Design, Recommendation Engine, Database Design  
**Related ADRs:** ADR-006 Watch-First Architecture, ADR-008 GPS and Golf Club Detection, ADR-010 Strategic Route and Target Planning, ADR-011 AI Caddy Architecture

---

# Context

Golf conditions materially affect club selection, expected carry, shot direction and route risk.

GolfClubPro must account for environmental factors including:

- Wind speed
- Wind direction
- Temperature
- Air pressure
- Humidity
- Precipitation
- Elevation change
- Weather-data age
- Weather-data confidence

The system must provide useful recommendations when live weather is available while continuing to operate when network connectivity or current weather data is unavailable.

Apple WeatherKit provides native current and forecast weather information for Apple-platform applications. WeatherKit supports current, hourly and daily conditions and is suitable for native iPhone and Apple Watch integrations. Apple requires attribution when WeatherKit data is displayed or published. ([Apple Developer](https://developer.apple.com/weatherkit/?utm_source=chatgpt.com))

---

# Decision

GolfClubPro will use **WeatherKit** as the preferred weather-data provider for Apple-platform applications.

WeatherKit access will remain outside `GolfCore`.

The application layer will translate WeatherKit values into neutral GolfCore domain models before passing weather information to the recommendation engine.

GolfCore must not import:

- WeatherKit
- Core Location
- MapKit

---

# Architectural Boundary

```text
WeatherKit
    │
    ▼
WeatherKit Adapter
    │
    ▼
GolfCore WeatherSnapshot
    │
    ▼
ShotContext
    │
    ▼
RecommendationEngine
```

This preserves:

- GolfCore portability
- Unit-test independence
- Replaceable weather providers
- Offline operation
- Deterministic recommendation testing

---

# Core Weather Concepts

## WeatherSnapshot

A weather observation associated with a location and time.

It should contain only the values required by GolfClubPro.

Expected fields include:

- Observation time
- Location
- Wind
- Temperature
- Humidity
- Pressure
- Precipitation
- Data source
- Data age
- Availability status

---

## WindContext

Wind information relevant to a shot.

It includes:

- Wind speed
- Wind origin direction
- Optional gust speed
- Observation time

Wind direction must be interpreted consistently.

GolfClubPro will represent wind direction as the compass direction **from which the wind originates**, matching standard meteorological convention.

The recommendation engine must convert this into:

- Headwind component
- Tailwind component
- Left-to-right crosswind component
- Right-to-left crosswind component

---

## WeatherAvailability

Weather may be:

- Live
- Cached
- Stale
- Unavailable

Recommendations should identify which state applies.

---

# Domain Models

The initial GolfCore weather models should include:

```swift
public enum WeatherAvailability:
    String,
    Codable,
    Sendable {

    case live
    case cached
    case stale
    case unavailable
}
```

```swift
public enum WeatherDataSource:
    String,
    Codable,
    Sendable {

    case weatherKit
    case cachedWeatherKit
    case manual
    case unknown
}
```

```swift
public struct WeatherSnapshot:
    Codable,
    Equatable,
    Sendable {

    public var observedAt: Date
    public var location: GeoCoordinate

    public var wind: WindContext?
    public var windGustMetersPerSecond: Double?

    public var temperatureCelsius: Double?
    public var humidityPercent: Double?
    public var pressureHPa: Double?
    public var precipitationMillimetres: Double?

    public var availability: WeatherAvailability
    public var source: WeatherDataSource
}
```

---

# Weather Acquisition Strategy

The application layer should request weather:

1. When the golf club is detected.
2. When the round begins.
3. Periodically during the round.
4. When the golfer moves a meaningful distance.
5. Before producing a recommendation when current data is stale.

The application should avoid requesting weather for every GPS update or every screen refresh.

---

# Update Frequency

The initial implementation should use a conservative refresh strategy.

Recommended behaviour:

- Fetch when the round starts.
- Refresh approximately every 15 to 30 minutes.
- Refresh sooner when cached data is stale and connectivity is available.
- Reuse the most recent valid snapshot between refreshes.
- Avoid unnecessary requests from both Watch and iPhone.

The iPhone should normally act as the primary weather-acquisition device.

The Watch may consume synchronised weather snapshots from the iPhone.

---

# Offline Behaviour

Weather must enhance recommendations but must not be required to play.

When live weather is unavailable:

1. Use a recent cached snapshot if available.
2. Mark it as cached or stale.
3. Reduce recommendation confidence appropriately.
4. Explain that live weather was unavailable.
5. Continue with distance, lie, route and player-history analysis.

The deterministic recommendation engine must remain functional without weather data.

---

# Data Freshness

Weather data should carry an observation timestamp.

Suggested initial classifications:

```text
Live        0–15 minutes old
Cached      15–45 minutes old
Stale       More than 45 minutes old
Unavailable No usable snapshot
```

These thresholds should be configurable and calibrated through field testing.

---

# Recommendation Impact

Weather should influence:

- Adjusted carry distance
- Club suitability
- Aim offset
- Route risk
- Hazard carry confidence
- Recommendation confidence
- Recommendation explanation

---

# Wind Calculation

Wind must be decomposed relative to the planned shot bearing.

The recommendation engine should calculate:

```text
Wind direction
        │
        ▼
Relative angle to target bearing
        │
        ├── Headwind or tailwind component
        └── Crosswind component
```

The headwind component affects expected carry.

The crosswind component affects aim direction.

---

# Temperature, Pressure and Humidity

Initial implementation may apply only modest deterministic adjustments.

These adjustments should remain:

- Bounded
- Explainable
- Testable
- Separately configurable

The system should avoid presenting highly precise environmental corrections until sufficient validation has been completed.

---

# Elevation

Elevation change is part of environmental shot context but may come from course geometry or location services rather than WeatherKit.

Elevation should remain a separate input within `EnvironmentalContext`.

---

# Watch-First Behaviour

The Apple Watch should not display unnecessary weather detail during play.

The Watch may show:

- Wind speed
- Wind direction
- Headwind or tailwind indicator
- Crosswind indicator
- Weather-data freshness
- Weather-related recommendation adjustment

Detailed weather information should remain primarily on iPhone.

---

# Attribution

Software that displays Apple Weather information must meet Apple's WeatherKit attribution requirements. WeatherKit provides attribution data including legal attribution content and the Apple Weather mark. ([Apple Developer](https://developer.apple.com/documentation/weatherkit/weatherattribution?utm_source=chatgpt.com))

GolfClubPro must therefore provide an appropriate attribution surface in the iPhone application and any other interface that displays WeatherKit-derived weather information.

Attribution handling belongs in the application layer, not GolfCore.

---

# Privacy

Weather requests require a location, but GolfClubPro should minimise location disclosure.

The system should:

- Request weather only for the active golf location.
- Avoid retaining unnecessary raw location history.
- Store weather snapshots only where useful for shot analysis or recommendation auditing.
- Explain location use clearly to the golfer.
- Avoid sending player identity with weather requests where unnecessary.

---

# Persistence

Weather data may be stored at two levels.

## Active-round cache

Supports:

- Offline continuity
- Watch synchronisation
- Reduced WeatherKit requests

## Shot-context history

A compact environmental snapshot may be stored against a shot or recommendation audit record.

The stored snapshot should include only the values required to explain or reproduce the recommendation.

---

# Recommendation Auditing

When recommendation auditing is enabled, the audit record should capture:

- Weather snapshot timestamp
- Wind speed
- Wind direction
- Temperature
- Pressure
- Humidity
- Weather availability
- Weather source
- Whether cached or stale data was used

This allows a recommendation to be reconstructed later.

---

# Error Handling

The weather adapter must handle:

- Permission denial
- Network failure
- WeatherKit service error
- Missing values
- Stale cache
- Invalid location
- Watch-to-iPhone synchronisation failure

Weather errors must not block the round.

---

# Testing Requirements

Tests should cover:

- No-weather recommendation
- Headwind adjustment
- Tailwind adjustment
- Left crosswind
- Right crosswind
- Cached weather
- Stale weather
- Missing wind
- Extreme but valid wind values
- Direction wrapping around 0 and 360 degrees
- Recommendation-confidence reduction
- Recommendation-audit snapshot capture

GolfCore tests should use constructed `WeatherSnapshot` values and should not call WeatherKit.

---

# Alternatives Considered

## Third-Party Weather Provider

Not selected for the initial Apple application because WeatherKit offers native Apple-platform integration and reduces external dependencies.

A provider abstraction will still allow future alternatives.

## Direct WeatherKit Dependency in GolfCore

Rejected because it would couple business logic to an Apple framework and reduce testability.

## No Weather Integration

Rejected because wind and environmental conditions materially affect club choice, distance and direction.

---

# Consequences

## Positive

- Native Apple weather integration
- Better distance and aim recommendations
- Explainable environmental adjustments
- Offline fallback
- Replaceable provider boundary
- Consistent Watch and iPhone context

## Negative

- Requires entitlement and application configuration
- Requires attribution
- Adds data-freshness logic
- Introduces network and caching complexity
- Requires field calibration of adjustment rules

---

# Implementation Sequence

1. Add GolfCore weather domain models.
2. Extend `EnvironmentalContext`.
3. Create a weather-provider protocol outside GolfCore or at the integration boundary.
4. Implement the WeatherKit adapter in the app layer.
5. Add active-round weather caching.
6. Add weather freshness classification.
7. Update RecommendationEngine wind calculations.
8. Extend RecommendationAuditRecord.
9. Add attribution UI.
10. Field-test and calibrate environmental adjustments.

---

# Documentation Impact

This decision requires updates to:

- Domain Model
- Data Model
- System Architecture
- AI Caddy Design
- Database Design
- Recommendation Audit design
- Privacy documentation
- Apple Watch UX
- iPhone UX
- Testing Strategy

---

# Future Considerations

Future versions may include:

- Forecast weather for planned tee time
- Rain and course-condition modelling
- Gust-risk modelling
- Wind variation across exposed holes
- Hole-specific wind corridors
- Historical weather comparison
- Course firmness estimates
- Air-density calculations
- Weather-aware route planning

---

# Revision History

| Version | Date | Description |
|----------|------|-------------|
| 1.0.0 | 2026-07-10| Initial accepted version |
