# FORGE-OS Update History

## Version 0.2.5-test.1 / FORGE 2.5.0-beta
**Status:** Candidate / Living Intelligence Runtime

### Core Changes & New Features

#### 1. Visual & UX (High Fidelity)
- **Aurora Fields:** Integrated Three.js aurora effects.
- **Animated Glass:** New glass surfaces and brand-aligned visuals.
- **Performance:** Animation suspension for background windows.

#### 2. Intelligence & Telemetry
- **Visualized Context:** Real-time surfaces for Semantic/Process memory and tool telemetry.
- **Indexing Transparency:** Visible tracking of workspace discovery status.
- **Resource Guardrails:** Direct file reads capped at 32MB to prevent memory exhaustion.

#### 3. Application Discovery (Flatpak/XDG)
- **XDG Merging:** Now merges `XDG_DATA_DIRS` instead of overwriting, fixing missing Flatpak apps.
- **Structured Launching:** Replaced shell concatenation with structured executable/argument arrays.
- **Visibility Logic:** Improved duplicate resolution and `@@` launch marker handling.

#### 4. Hardening & Boundaries
- **Root Context:** Defaults to `$HOME` as the active workspace.
- **Fault-Tolerant Scanning:** Skips `EPERM/EACCES` errors (e.g., container overlays) without aborting the indexer.

#### 5. Infrastructure
- **Nix Normalization:** Transitioning to JSON/SQLite state emissions for runtime facts.
- **AI Gateway:** Normalized API endpoints for local AI (Ollama) within the runtime architecture.
