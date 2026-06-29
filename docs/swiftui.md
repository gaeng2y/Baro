# SwiftUI Guide

This app uses SwiftUI with TCA feature stores. The current code intentionally avoids TCA macros so Xcode package macro approval does not block local builds.

## Feature Shape

Feature modules should keep this shape:

```swift
import ComposableArchitecture

public struct FeatureState: Equatable {
    public init() {}
}

public enum FeatureAction: Equatable {
}

public struct FeatureReducer: Reducer {
    public typealias State = FeatureState
    public typealias Action = FeatureAction

    public init() {}

    public var body: some Reducer<FeatureState, FeatureAction> {
        Reduce { state, action in
            .none
        }
    }
}

public struct FeatureView: View {
    public let store: StoreOf<FeatureReducer>
}
```

Keep state mutations explicit and small. Prefer explicit `Reducer` conformance and `WithViewStore` until the project deliberately switches to `@Reducer` and `@ObservableState`.

## View Responsibilities

SwiftUI views should:

- Render state.
- Send high-level user actions.
- Let reducers own feature state mutation and side-effect triggers.
- Own local UI-only state when it does not belong in domain or persistence.
- Keep platform details behind Core clients or UI boundary modules.

SwiftUI views should not:

- Analyze camera frames.
- Run pose estimation directly.
- Select coaching cues from raw model output.
- Persist session data directly.
- Import Firebase directly.

## Design System

Reuse `DesignSystem` primitives before adding feature-local styling:

- `LiquidGlassBackground`
- `CoachCard`
- `PrimaryCoachButton`
- `GlassIconButton`
- `MetricPill`
- `StatusCapsule`
- `CameraGlassPlaceholder`

When creating new shared UI, add it to `Projects/UserInterface/DesignSystem/Sources/CoachTheme.swift` only if at least two screens need it or it encodes a product-wide visual rule.

## Screen Patterns

### Main

The home screen should prioritize fast entry into training:

- visible product identity
- primary start action
- quick shortcuts for supported strokes
- recent session access
- settings access

### Training Setup

Training setup should block accidental poor-quality sessions:

- stroke picker
- camera mode picker
- camera readiness checklist
- start button disabled until required checks pass

When live preflight camera analysis is added, replace manual checks gradually instead of removing the readiness concept.

### Record

Record UI should preserve stable layout:

- camera preview height should not jump as events arrive
- body detection, camera quality, swing status, swing count, analysis count, and latest cue must remain visible
- status changes should be compact overlays or metric pills

Do not place critical controls where camera overlays can hide them.

### Session Summary

The summary should answer:

- How many swings were captured?
- How many were analyzed?
- What repeated error matters most?
- What single cue should the player focus on next?

Keep the next-session goal actionable and short.

## Accessibility

- Use 44 pt or larger tap targets.
- Use SF Symbols with text labels for unfamiliar actions.
- Prefer `.lineLimit` and `.minimumScaleFactor` only for compact labels; let coaching text wrap.
- Do not rely only on color for readiness or warning state.
- Add accessibility labels or hints to icon-only and card-like buttons.

## Navigation

`AppFeature` owns root routing. Feature screens receive closures for navigation side effects.

Avoid deep feature-to-feature imports. If a screen needs to navigate, emit a closure callback to `AppFeature`.

## Verification

For UI changes:

- Run `make build` when feasible.
- Check compact iPhone widths when text or new controls are added.
- If camera UI changes, verify the no-camera fallback and live preview path both still compile.
