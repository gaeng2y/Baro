# TennisCoach

AirPods 기반 테니스 자세 교정 iOS 앱.

## Documents

- [PRD.md](PRD.md): AirPods Tennis Form Coach PRD v0.1

## Stack

- iOS
- SwiftUI
- Tuist modular architecture
- Clean Architecture boundaries
- TCA-ready Feature state/action/reducer structure
- On-device camera, pose estimation, coaching engine, audio feedback clients

## Development

```bash
tuist generate
open TennisCoach.xcworkspace
```

검증:

```bash
tuist generate
xcodebuild test -workspace TennisCoach.xcworkspace -scheme TennisDomain -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
