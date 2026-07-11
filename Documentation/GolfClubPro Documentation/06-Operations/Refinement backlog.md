
- Review public setters on Round, HoleSession and Shot.
- Move toward engine-controlled aggregate mutation.
- Preserve Codable and offline reconstruction requirements.
- Restrict direct mutation of Round aggregate state.
- Route all live-round transitions through RoundEngine.
- Preserve Codable support for persistence and recovery.
- Introduce an injectable clock for deterministic timestamp creation.
