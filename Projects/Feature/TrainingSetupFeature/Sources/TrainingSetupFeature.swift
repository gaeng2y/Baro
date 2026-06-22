import DesignSystem
import SwiftUI
import TennisDomain

public struct TrainingSetupState: Equatable {
    public var strokeType: StrokeType = .forehand
    public var cameraMode: CameraMode = .side
    public var cameraQuality: CameraQuality = .bodyOutOfFrame

    public init() {}
}

public enum TrainingSetupAction: Equatable {
    case strokeChanged(StrokeType)
    case cameraModeChanged(CameraMode)
    case cameraQualityChanged(CameraQuality)
    case start
}

public struct TrainingSetupView: View {
    @State private var state = TrainingSetupState()
    public var onStart: (StrokeType, CameraMode) -> Void

    public init(onStart: @escaping (StrokeType, CameraMode) -> Void) {
        self.onStart = onStart
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    StatusCapsule("SETUP", tone: .neutral)
                    Text("훈련 설정")
                        .font(.largeTitle.weight(.heavy))
                }

                CoachCard {
                    Text("동작")
                        .font(.headline.weight(.heavy))
                    Picker("동작", selection: $state.strokeType) {
                        ForEach(StrokeType.allCases) { stroke in
                            Text(stroke.title).tag(stroke)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                CoachCard {
                    Text("촬영 모드")
                        .font(.headline.weight(.heavy))
                    Picker("촬영 모드", selection: $state.cameraMode) {
                        ForEach(CameraMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(cameraGuide)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                CoachCard {
                    Label("전신이 화면에 들어오면 시작할 수 있어요.", systemImage: "figure.tennis")
                    Label("조명 부족, 신체 일부 누락, 카메라 흔들림은 분석에서 제외합니다.", systemImage: "exclamationmark.triangle")
                }
                .font(.subheadline.weight(.semibold))

                PrimaryCoachButton("세션 시작") {
                    onStart(state.strokeType, state.cameraMode)
                }

                Spacer()
            }
            .padding(20)
        }
    }

    private var cameraGuide: String {
        switch state.cameraMode {
        case .side:
            "측면에서 어깨 회전과 임팩트 위치를 보기 좋게 세팅하세요."
        case .rearDiagonal:
            "후방 대각선에서 몸통 회전과 팔로스루를 함께 확인하세요."
        }
    }
}
