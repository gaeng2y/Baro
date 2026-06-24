# Documentation Plan

This is the backlog for docs that should be added as the app grows.

## Add Soon

### Camera and Vision Pipeline

Purpose:

- Explain AVFoundation session setup.
- Document sample buffer orientation.
- Document Vision coordinate conversion.
- Define camera quality rules.

Suggested file: `docs/camera-vision.md`

### Domain Rules

Purpose:

- Explain current rule sets.
- Document each `CoachingErrorType`.
- Document cue priority and cooldown policy.
- Give sample metric thresholds.

Suggested file: `docs/domain-rules.md`

### Testing Strategy

Purpose:

- Document what must be unit-tested.
- Define fixture strategy for pose sequences.
- Define smoke build expectations.

Suggested file: `docs/testing.md`

## Add Before Beta

### Privacy and Data Retention

Purpose:

- Explain on-device processing.
- Define optional clip saving behavior.
- Define local data deletion expectations.
- Document future pose metric export constraints.

Suggested file: `docs/privacy.md`

### Release Checklist

Purpose:

- App Store metadata checklist.
- Camera permission copy.
- Device testing checklist.
- Performance and battery checks.

Suggested file: `docs/release.md`

### Performance Budget

Purpose:

- Target frame rate.
- Pose estimation cadence.
- Inference latency budget.
- Thermal/battery expectations.

Suggested file: `docs/performance.md`

## Add When Core ML Starts

### Model Card

Purpose:

- Model purpose.
- Training data summary.
- Known limitations.
- Evaluation results.
- Version history.

Suggested file: `docs/model-card.md`

### Data Schema

Purpose:

- Pose sequence schema.
- Feature extraction schema.
- Label definitions.
- Backward compatibility rules.

Suggested file: `docs/data-schema.md`

## Maintenance Rule

When a topic becomes required to safely change code, promote it from this plan into a real document in the same PR or commit as the implementation.

