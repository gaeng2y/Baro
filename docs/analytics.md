# Analytics

Analytics uses a Core client boundary so product events can be tested without Firebase.

## Boundary

- Features and reducers use `AnalyticsClient`.
- `TennisCore` owns event names, parameter names, and the client interface.
- `TennisCoachApp` owns the Firebase implementation.
- `TennisDomain` never imports analytics or Firebase.

## Event Rules

- Event names and parameter names use snake case.
- Do not send raw camera frames, pose landmarks, video paths, or personally identifying values.
- Prefer coarse product metrics such as stroke type, camera mode, counts, and settings state.
- Add a reducer test when an action should emit an analytics event.

## Current Events

- `app_opened`
- `onboarding_completed`
- `training_setup_opened`
- `session_started`
- `session_finished`
- `settings_changed`
- `local_data_deleted`

## Storage

The app does not store analytics events locally. Events are sent through `AnalyticsClient` to Firebase Analytics at the app boundary. Product state that must survive app launches belongs in `LocalAppStorageClient`, not analytics.

## Verification

- Core event mapping: `TennisCoreTests`
- Reducer event emission: feature reducer tests
- Firebase import/build integration: `make build`
