
# Development Principles

## Purpose

These principles guide all GolfClubPro development decisions.

## Principles

### 1. Apple Ecosystem First

Prefer Apple-native frameworks before third-party dependencies.

### 2. Offline First

A golfer must be able to complete a round without network connectivity.

### 3. Watch First

The Apple Watch is the primary on-course interface. The iPhone is the analysis and coaching interface.

### 4. GolfCore Is Pure

GolfCore should contain golf business concepts and logic. It should avoid direct dependency on SwiftUI, WeatherKit, CloudKit, Core Location, or SwiftData where practical.

### 5. Strong Typing Over Primitive Types

Use explicit identifiers such as PlayerID, RoundID, ShotID, CourseID, and DotGolfMemberID rather than raw UUIDs or strings.

### 6. Explainable AI

Every AI Caddy recommendation should be explainable in plain language.

### 7. Documentation Before Complexity

Major architectural changes require documentation and an ADR.

### 8. Testable Core

Core logic must be unit-testable independent of the UI.

### 9. No Broken Main Branch

The main branch should always build.

### 10. Build Incrementally

Every milestone should produce a working, testable application.

