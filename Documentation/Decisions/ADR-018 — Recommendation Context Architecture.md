

**Document ID:** GCP-ADR-0178
**Status:** Accepted  
**Version:** 1.0.0  
**Date:** 2026-07-14  
**Decision Makers:** Solution Architecture  
**Related Documents:** ADR-017. ADR-016 Context-Centric Architecture, GCP-ARCH-003 Spatial Engine Architecture

---

# Context

- Recommendation engines consume immutable context;
* The existing ShotContext remains the shot-specific input;
* RecommendationContext composes shot and spatial context;
* providers and platform APIs remain outside the recommendation layer.
