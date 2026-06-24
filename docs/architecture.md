# Architecture

TennisCoach follows a modular iOS architecture with domain rules isolated from UI and platform frameworks.

## Dependency Direction

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

## Modules

### TennisCoachApp

Location: `Projects/App/TennisCoachApp`

- App entry point.
- Assembles `AppFeatureView`.
- Owns app resources and asset catalogs.
- Uses `SessionPipeline.live()` for app runtime.

### AppFeature

Location: `Projects/Feature/AppFeature`

- Root navigation and route state.
- Onboarding completion, session list, summary/history/settings routes.
- Composition layer for feature screens.

### Feature Modules

Location: `Projects/Feature`

Feature modules own user-facing state, actions, reducer logic, and SwiftUI views:

- `OnboardingFeature`
- `MainFeature`
- `TrainingSetupFeature`
- `RecordFeature`
- `SessionSummaryFeature`
- `HistoryFeature`
- `SettingsFeature`

Feature modules may depend on `TennisDomain`, `TennisCore`, and `DesignSystem`. They must not import AVFoundation, Vision, MediaPipe, or future model runtime implementation details directly.

### TennisDomain

Location: `Projects/Domain/TennisDomain`

Pure models and rules:

- `UserProfile`
- `TrainingSession`
- `SwingEvent`
- `SwingAnalysisResult`
- `PoseFrame`
- `PoseSequence`
- `SwingMetrics`
- rule sets
- cue selection
- session summary building

Rules:

- Do not import SwiftUI.
- Do not import AVFoundation.
- Do not import Vision.
- Do not add storage, network, camera, audio, or ML runtime dependencies.

### TennisCore

Location: `Projects/Core/TennisCore`

External system boundaries and runtime orchestration:

- `CameraClient`
- `PermissionClient`
- `PoseEstimationClient`
- `CoachingEngineClient`
- `AudioFeedbackClient`
- `LocalSessionStoreClient`
- `SessionPipeline`
- `SwingPhaseDetector`

`TennisCore` can import platform frameworks where needed, but should expose domain-level values to features. The preferred output from the runtime pipeline is `CoachingEvent`, not raw camera frames.

### UserInterface

Location: `Projects/UserInterface`

- `DesignSystem`: reusable SwiftUI primitives and theme tokens.
- `CameraPreviewUI`: AVFoundation-backed preview UI boundary.

Keep reusable UI primitives here when they are shared across feature modules.

## Runtime Pipeline

Current live pipeline:

```text
CameraClient.live()
-> PoseEstimationClient.vision
-> SwingPhaseDetector
-> CoachingEngineClient.ruleBased
-> CoachingEvent
-> RecordFeature
-> AudioFeedbackClient.live()
```

Feature modules should receive events such as:

- `bodyDetected`
- `cameraQualityChanged`
- `strokeStarted`
- `strokeFinished`
- `cueSelected`
- `sessionMetricUpdated`

Reducers should not process frame-by-frame camera or pose data.

## Adding New Code

- New domain concept: start in `TennisDomain`, add tests under `Projects/Domain/TennisDomain/Tests`.
- New platform integration: add or extend a client in `TennisCore`.
- New screen: create or extend a feature module under `Projects/Feature`.
- Shared visual primitive: add to `DesignSystem`.
- Camera preview-specific UI wrapper: add to `CameraPreviewUI`.

## Testing

- Put pure domain behavior under XCTest in `TennisDomainTests`.
- Prefer deterministic tests for cue selection, summary building, phase detection, and metric extraction.
- Use `make test` for domain test verification.
- Use `make build` for app, feature, UI, Core, and manifest changes.

