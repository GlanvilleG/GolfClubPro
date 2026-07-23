import Foundation

public extension ShotContext {
    /// Applies an EnvironmentalAssessment derived from the current environment and shot plan bearing.
    /// If no shot plan is present, uses 0 degrees as a safe default.
    /// - Parameter now: Reference time for weather age calculation. Defaults to `Date()`.
    mutating func applyEnvironmentalAssessment(now: Date = Date()) {
        let bearing = currentShotPlan?.targetBearingDegrees ?? 0
        self.environmentalAssessment = EnvironmentalAssessmentBuilder.buildAssessment(
            from: self.environment,
            shotBearingDegrees: bearing,
            now: now
        )
    }

    /// Returns a copy of this ShotContext with an EnvironmentalAssessment applied.
    /// - Parameter now: Reference time for weather age calculation. Defaults to `Date()`.
    func withEnvironmentalAssessment(now: Date = Date()) -> ShotContext {
        var copy = self
        copy.applyEnvironmentalAssessment(now: now)
        return copy
    }
}
