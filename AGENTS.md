# AGENTS.md

## Project

TennisCoach is an iOS 26+ Swift 6 SwiftUI app for on-device tennis form coaching. The MVP records forehand and two-handed backhand practice, analyzes swing form locally, and delivers one short correction cue through the current audio output shortly after a swing.

## Repository Rules

- Use `rg` or `rg --files` first when searching.
- Check `git status --short` before editing. Preserve unrelated user changes.
- Do not edit or commit generated artifacts:
  - `TennisCoach.xcworkspace`
  - `TennisCoach.xcodeproj`
  - `Derived/`
- Keep local signing data out of git. `Tuist/Local/TeamID.txt` is local-only.
- Prefer small, scoped patches that follow existing module boundaries.
- Use `docs/` as the source of truth for long-lived engineering guidance.

## Docs

- [docs/README.md](docs/README.md): documentation index and maintenance rules
- [docs/agents.md](docs/agents.md): long-form agent operating guide
- [docs/architecture.md](docs/architecture.md): module boundaries and runtime pipeline
- [docs/swiftui.md](docs/swiftui.md): SwiftUI and design system guidance
- [docs/analytics.md](docs/analytics.md): analytics event taxonomy and Firebase boundary
- [docs/coreml.md](docs/coreml.md): Core ML and on-device ML strategy
- [docs/documentation-plan.md](docs/documentation-plan.md): future documentation backlog

## Commands

- Generate workspace: `make generate`
- Configure signing and generate: `make setup TEAM_ID=<TEAM_ID>`
- Build simulator app: `make build`
- Run all tests: `make test`
- Run domain tests only: `make test-domain`
- Clean generated Tuist/Xcode files: `make clean`

If `Project.swift` or target membership changes, regenerate the workspace with `make generate` before Xcode-based verification.

## Architecture

The dependency direction is:

```text
TennisCoachApp
-> AppFeature
-> Feature modules
-> TennisDomain

Feature modules
-> TennisCore client interfaces

TennisCore
-> TennisDomain
```

Rules:

- `TennisDomain` stays pure. Do not import SwiftUI, AVFoundation, Vision, or app-specific infrastructure there.
- Feature modules own user-facing state, actions, TCA reducers, and SwiftUI views.
- `TennisCore` owns external-system client boundaries such as camera, permission, pose estimation, coaching engine, audio feedback, local session storage, and session pipeline.
- Feature modules must not know concrete AVFoundation, Vision, Firebase, or future MediaPipe implementations.
- Reducers should receive high-level events such as `CoachingEvent`; do not push frame-by-frame camera or pose processing into reducers.
- Keep TCA reducers macro-free unless the project explicitly opts back into Xcode macro approval. Prefer explicit `Reducer` conformance and `WithViewStore` for now.
- Analytics events go through `AnalyticsClient`; do not import Firebase outside the app target.

## UI Guidelines

- Reuse `DesignSystem` primitives before adding view-local styling:
  - `LiquidGlassBackground`
  - `CoachCard`
  - `PrimaryCoachButton`
  - `GlassIconButton`
  - `MetricPill`
  - `StatusCapsule`
  - `CameraGlassPlaceholder`
- New screens should open directly into the usable coaching flow, not a marketing or explanation page.
- Keep coaching context visible: stroke type, camera mode, body-detection or camera-quality status, swing count, analysis count, and the latest cue.
- Prefer segmented pickers for mutually exclusive training options, metric pills for numeric status, status capsules for compact state, and SF Symbols for familiar icon actions.
- Avoid nesting cards inside cards. Use cards for repeated items, summaries, and focused controls only.
- Design mobile-first. Make text wrap or scale within controls, support Dynamic Type where practical, and avoid overlapping toolbar, camera, metric, and cue content.
- Camera and record screens should preserve stable preview and control dimensions so status updates do not shift the layout.
- Keep the visual language athletic and focused: subdued glass materials, tennis green/court blue accents, high contrast for live status, and no decorative elements that compete with camera feedback.

## Testing Expectations

- For pure domain changes, add or update tests under `Projects/Domain/TennisDomain/Tests` and run `make test-domain`.
- For app, feature, UI, or project-file changes, run `make build` when feasible.
- If verification cannot run because signing, simulator, Tuist, or Xcode state is unavailable, report the exact blocker.

## Product Constraints

- Camera video is intended to be processed on-device.
- The default coaching behavior is one concise cue after each analyzed swing.
- Optional clip persistence must stay explicit and user-controlled.
- Forehand and two-handed backhand are the current MVP strokes.
