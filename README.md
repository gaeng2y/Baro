# TennisCoach

AirPods 기반 테니스 자세 교정 iOS 앱입니다. iPhone 카메라로 포핸드·양손 백핸드 스윙을 온디바이스 분석하고, 스윙 직후 현재 오디오 출력 장치로 짧은 교정 cue를 전달하는 MVP를 목표로 합니다.

## Documents

- [PRD.md](PRD.md): AirPods Tennis Form Coach PRD v0.1
- [docs/README.md](docs/README.md): engineering docs index

## Stack

- iOS 17+
- Swift 6
- SwiftUI
- Tuist 4.x
- Clean Architecture 기반 모듈화
- TCA 도입을 전제로 한 Feature `State` / `Action` / `Reducer` 구조
- 온디바이스 카메라, 포즈 추정, 룰 기반 코칭 엔진, 오디오 피드백 client 경계

## Project Structure

```text
TennisCoach
├── Project.swift
├── Workspace.swift
├── PRD.md
├── Projects
│   ├── App
│   │   └── TennisCoachApp
│   ├── Feature
│   │   ├── AppFeature
│   │   ├── OnboardingFeature
│   │   ├── MainFeature
│   │   ├── TrainingSetupFeature
│   │   ├── RecordFeature
│   │   ├── SessionSummaryFeature
│   │   ├── HistoryFeature
│   │   └── SettingsFeature
│   ├── Domain
│   │   └── TennisDomain
│   ├── Core
│   │   └── TennisCore
│   └── UserInterface
│       └── DesignSystem
└── README.md
```

## Module Responsibilities

`TennisCoachApp`

- iOS app entry point
- `AppFeatureView` 조립
- app resources와 asset catalog 보유

`AppFeature`

- root navigation
- onboarding 완료 여부, session list, 현재 route 관리
- 각 Feature 화면을 연결하는 composition layer

`OnboardingFeature`

- 오른손/왼손, 주 연습 동작, 피드백 빈도 등 초기 설정 입력
- AirPods/Bluetooth 오디오와 카메라 설치 안내

`MainFeature`

- 훈련 시작, 최근 세션, 히스토리, 설정으로 진입하는 홈 화면

`TrainingSetupFeature`

- 포핸드/양손 백핸드 선택
- 측면/후방 대각선 촬영 모드 선택
- 전신 인식과 촬영 품질 체크 안내

`RecordFeature`

- 실시간 촬영 화면의 shell
- 스윙 수, 카메라 품질, 최신 cue, 세션 종료 흐름
- 현재는 preview pipeline 기반이며, 이후 AVFoundation/Vision live 구현을 연결할 예정

`SessionSummaryFeature`

- 총 스윙 수, 분석 성공 수, 반복 오류, 다음 집중 목표 표시

`HistoryFeature`

- 로컬 세션 기록 목록 표시

`SettingsFeature`

- 피드백 빈도
- 선택적 클립 저장 설정
- 로컬 데이터 삭제

`TennisDomain`

- 순수 도메인 모델과 룰
- `UserProfile`, `TrainingSession`, `SwingEvent`, `SwingAnalysisResult`
- `PoseFrame`, `PoseSequence`, `SwingMetrics`
- `ForehandRuleSet`, `BackhandRuleSet`
- `CueSelectionPolicy`, `SessionSummaryBuilder`
- XCTest 기반 domain tests

`TennisCore`

- 외부 시스템 client 경계
- `CameraClient`
- `PermissionClient`
- `PoseEstimationClient`
- `CoachingEngineClient`
- `AudioFeedbackClient`
- `LocalSessionStoreClient`
- `SessionPipeline`

`DesignSystem`

- 공통 색상, 카드, 주요 버튼, metric pill 등 SwiftUI UI primitive

## Dependency Direction

```text
TennisCoachApp
↓
AppFeature
↓
Feature modules
↓
TennisDomain

Feature modules
↓
TennisCore client interfaces

TennisCore
↓
TennisDomain
```

규칙:

- `TennisDomain`은 SwiftUI, AVFoundation, Vision을 import하지 않습니다.
- Feature는 AVFoundation, Vision, MediaPipe 구현체를 직접 알지 않습니다.
- 카메라 프레임은 Core 계층에서 처리하고, Feature에는 `CoachingEvent` 같은 고수준 이벤트만 전달합니다.
- Reducer는 프레임 단위 처리를 하지 않습니다.

## Runtime Direction

PRD 기준 목표 파이프라인:

```text
CameraLive
→ PoseEstimationLive
→ CoachingEngineLive
→ CoachingEvent
→ RecordFeature
→ AudioFeedbackClient
```

현재 구현 상태:

- Tuist workspace/project 생성 가능
- SwiftUI 화면 shell 구성
- Domain 모델과 1차 룰 기반 분석 골격 구현
- cue 선택 정책과 세션 요약 테스트 구현
- Core client protocol-style boundary 구현
- AVFoundation camera preview와 Vision pose estimation live 구현은 다음 단계

## Development

### Prerequisites

- Xcode 26.x
- Tuist 4.x

### Generate Workspace

```bash
tuist generate
open TennisCoach.xcworkspace
```

Tuist가 생성하는 다음 산출물은 커밋하지 않습니다.

```text
TennisCoach.xcworkspace
TennisCoach.xcodeproj
Derived/
```

### Configure Code Signing

Apple Developer Team ID는 로컬 파일로만 저장합니다. 저장 파일은 `.gitignore`에 포함되어 커밋되지 않습니다.

Mulimi와 같은 Makefile 흐름으로 설정할 수 있습니다.

```bash
make setup TEAM_ID=8UV3Y69NB7
```

Team ID만 저장하려면:

```bash
make signing TEAM_ID=8UV3Y69NB7
```

직접 Swift 스크립트를 실행할 수도 있습니다.

```bash
swift Scripts/CodeSigning.swift YOURTEAMID
tuist generate
```

인자 없이 실행하면 대화형으로 입력할 수 있습니다.

```bash
swift Scripts/CodeSigning.swift
```

스크립트는 `Tuist/Local/TeamID.txt`를 만들고, `Project.swift`가 이 값을 읽어 `DEVELOPMENT_TEAM`에 넣습니다.

### Make Commands

```bash
make help
make generate
make build
make test
make clean
```

### Build

```bash
xcodebuild build \
  -workspace TennisCoach.xcworkspace \
  -scheme TennisCoachApp \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/TennisCoachBuild
```

### Test

```bash
xcodebuild test \
  -workspace TennisCoach.xcworkspace \
  -scheme TennisDomain \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /tmp/TennisCoachBuild
```

## Current Verification

마지막 확인된 검증:

```text
tuist generate --no-open
xcodebuild build -workspace TennisCoach.xcworkspace -scheme TennisCoachApp -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/TennisCoachBuild -quiet
xcodebuild test -workspace TennisCoach.xcworkspace -scheme TennisDomain -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/TennisCoachBuild -quiet
```

## Next Implementation Targets

1. `CameraLive`: AVFoundation preview/session 구현
2. `PoseEstimationLive`: Apple Vision 기반 body pose 추정
3. `RecordFeature`: 실제 `CoachingEvent` stream 연결
4. `SwingPhaseDetection`: wrist velocity와 shoulder turn 기반 스윙 시작/종료 감지
5. `ForehandRuleSetTests`, `BackhandRuleSetTests` 확장
6. 사전 녹음 cue asset 또는 TTS fallback 정책 결정
