# Core ML and On-Device ML

Core ML is not required for the current MVP. The MVP pipeline uses camera frames, Apple Vision body pose estimation, deterministic swing phase detection, rule-based metric extraction, and cue selection.

## Current MVP Pipeline

```text
AVFoundation Camera
-> Vision body pose
-> PoseFrame
-> SwingPhaseDetector
-> PoseSequence
-> rule-based SwingMetrics
-> SwingAnalysisResult
-> CoachingCue
```

Implemented boundaries:

- Camera input: `Projects/Core/TennisCore/Sources/CameraClient.swift`
- Vision pose estimation: `Projects/Core/TennisCore/Sources/PoseEstimationClient.swift`
- Pipeline orchestration: `Projects/Core/TennisCore/Sources/SessionPipeline.swift`
- Rule-based coaching: `Projects/Core/TennisCore/Sources/CoachingEngineClient.swift`
- Domain pose models: `Projects/Domain/TennisDomain/Sources/PoseModels.swift`
- Domain swing models: `Projects/Domain/TennisDomain/Sources/SwingModels.swift`

## Why Core ML Is Deferred

The app can produce useful coaching feedback without a trained model by using:

- body pose landmarks
- swing phase heuristics
- rule-based metrics
- domain-specific cue prioritization

Deferring Core ML keeps the MVP testable and avoids premature model/data commitments.

## Future Core ML Use Cases

### Stroke Classification

Input:

- `PoseSequence`
- normalized landmark trajectories
- camera mode
- handedness

Output:

- stroke class
- confidence
- optional phase boundaries

Candidate classes:

- forehand
- two-handed backhand
- unknown or non-swing

### Error Classification

Input:

- `SwingMetrics`
- derived pose features
- optional temporal feature sequence

Output:

- one or more coaching error types
- severity score
- confidence score

The model output should map into domain values such as `DetectedError`, not UI-specific text.

## Integration Boundary

Future model inference should live behind a `TennisCore` client, for example:

```text
PoseSequence
-> SwingClassifierClient
-> SwingClassification
```

or:

```text
PoseSequence / SwingMetrics
-> ErrorClassifierClient
-> [DetectedError]
```

Rules:

- Do not import CoreML in `TennisDomain`.
- Do not import CoreML in feature modules.
- Keep model loading, revision handling, and inference scheduling in `TennisCore`.
- Convert model outputs into domain structs before sending events to features.
- Preserve the existing `CoachingEvent` style boundary.

## Dataset Shape

A future training dataset should avoid raw video whenever possible.

Preferred record shape:

- app version
- model/data schema version
- stroke type label
- handedness
- camera mode
- normalized pose sequence
- swing metrics
- optional coaching error labels
- label source
- confidence or review status

Privacy rules:

- Raw camera video should remain off by default.
- Clip persistence must be explicit and user-controlled.
- Prefer pose/metric data for debugging and model iteration.
- Strip device/user identifiers from exportable training data.

## Evaluation

Before shipping a model-backed path, define:

- target accuracy per stroke class
- false-positive tolerance for each error type
- unknown/non-swing rejection behavior
- latency budget on target devices
- battery and thermal budget during a session
- fallback behavior when confidence is low

## Runtime Requirements

- Inference must run on-device.
- The live camera loop must stay responsive.
- Model confidence must be surfaced as camera/coaching quality, not raw model internals.
- Low-confidence results should avoid audio feedback or fall back to setup guidance.

## Migration Plan

1. Keep rule-based coaching as the baseline.
2. Add feature extraction tests around `PoseSequence` and `SwingMetrics`.
3. Capture anonymized pose/metric samples only after explicit product decision.
4. Train offline classifiers.
5. Add `TennisCore` model clients.
6. Run model output next to rule-based output in debug builds.
7. Switch selected coaching decisions only after evaluation targets are met.

