## Sprint 10.7 — Explainability Snapshot Boundary

- Introduced RecommendationEvidenceSnapshot as a deterministic input boundary for Explainability and Audit (compile-only, no wiring yet).
- Added mappers from snapshot → structured evidence and snapshot → public evidence with deterministic ordering.
- Feature-flagged minimal snapshot attachment to RecommendationAuditRecord in RecommendationEngine.
- Next: approve and wire snapshot production at the pipeline/engine boundary (EnvironmentalAssessment, Risk/Strategic summaries) and integrate with ExplainabilityEngine mapping without altering public APIs.
