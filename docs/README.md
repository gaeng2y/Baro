# Docs

This directory holds long-lived engineering documentation for TennisCoach. Keep `README.md` and `PRD.md` useful for product-level orientation, and put implementation guidance here.

## Current Documents

- [Agent Guide](agents.md): rules for Codex, Claude, and other coding agents working in this repository.
- [Architecture](architecture.md): module boundaries, dependency direction, runtime pipeline, and where new code should live.
- [SwiftUI Guide](swiftui.md): feature view structure, design system usage, navigation, accessibility, and UI verification.
- [Core ML and On-Device ML](coreml.md): current non-ML MVP stance, future classifier strategy, dataset shape, evaluation, and integration boundaries.
- [Documentation Plan](documentation-plan.md): the next docs that should be added as the app grows.

## Documentation Rules

- Prefer small topic-specific docs over one large catch-all file.
- Link back to source files when a document describes implemented behavior.
- Keep PRD-level product decisions in `PRD.md`; keep implementation constraints in `docs/`.
- When an architectural rule changes, update [Architecture](architecture.md) and [Agent Guide](agents.md) in the same change.
- When a UI primitive or screen pattern changes, update [SwiftUI Guide](swiftui.md).
- When camera, pose estimation, model, or coaching pipeline behavior changes, update [Core ML and On-Device ML](coreml.md) if the change affects future model integration.

## Generated Files

Do not document generated Tuist or Xcode files as source of truth. These are local/generated artifacts:

- `TennisCoach.xcworkspace`
- `TennisCoach.xcodeproj`
- `Derived/`

