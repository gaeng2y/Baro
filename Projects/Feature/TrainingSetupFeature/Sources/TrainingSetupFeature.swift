import DesignSystem
import SwiftUI
import TennisDomain

public struct TrainingSetupState: Equatable {
    public var strokeType: StrokeType = .forehand
    public var cameraMode: CameraMode = .side
    public var isBodyInFrame: Bool = false
    public var hasEnoughLight: Bool = false
    public var isPhoneStable: Bool = false

    public init() {}

    public var isReadyToStart: Bool {
        isBodyInFrame && hasEnoughLight && isPhoneStable
    }

    public var cameraQuality: CameraQuality {
        if !isBodyInFrame {
            return .bodyOutOfFrame
        }
        if !hasEnoughLight {
            return .lowLight
        }
        if !isPhoneStable {
            return .unstable
        }
        return .ready
    }
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
                    HStack {
                        Text("카메라 체크")
                            .font(.headline.weight(.heavy))
                        Spacer()
                        StatusCapsule(readinessTitle, tone: state.isReadyToStart ? .active : .warning)
                    }

                    VStack(spacing: 10) {
                        SetupCheckRow(
                            title: "전신 프레임",
                            detail: "라켓과 발까지 화면 안에 들어와요.",
                            systemImage: "figure.tennis",
                            isComplete: state.isBodyInFrame
                        ) {
                            state.isBodyInFrame.toggle()
                        }
                        SetupCheckRow(
                            title: "충분한 조명",
                            detail: "얼굴과 관절이 그림자 없이 보여요.",
                            systemImage: "lightbulb.max.fill",
                            isComplete: state.hasEnoughLight
                        ) {
                            state.hasEnoughLight.toggle()
                        }
                        SetupCheckRow(
                            title: "고정된 iPhone",
                            detail: "삼각대나 거치대로 흔들림을 줄였어요.",
                            systemImage: "iphone.gen3.radiowaves.left.and.right",
                            isComplete: state.isPhoneStable
                        ) {
                            state.isPhoneStable.toggle()
                        }
                    }

                    Label(readinessGuide, systemImage: readinessIconName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(state.isReadyToStart ? CoachTheme.tennisTint : .secondary)
                }

                PrimaryCoachButton("세션 시작") {
                    guard state.isReadyToStart else { return }
                    onStart(state.strokeType, state.cameraMode)
                }
                .disabled(!state.isReadyToStart)
                .opacity(state.isReadyToStart ? 1 : 0.42)
                .accessibilityHint(state.isReadyToStart ? "훈련 세션을 시작합니다." : "카메라 체크 항목을 모두 완료해야 시작할 수 있습니다.")

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

    private var readinessTitle: String {
        state.isReadyToStart ? "시작 가능" : "체크 필요"
    }

    private var readinessGuide: String {
        switch state.cameraQuality {
        case .ready:
            "촬영 조건이 준비됐어요. 이제 세션을 시작할 수 있습니다."
        case .bodyOutOfFrame:
            "전신이 화면 안에 들어오는지 먼저 확인하세요."
        case .lowLight:
            "조명을 더 밝게 맞춘 뒤 체크하세요."
        case .unstable:
            "iPhone을 고정한 뒤 흔들림을 줄이세요."
        case .lowConfidence:
            "인식 신뢰도를 높일 수 있게 위치를 다시 맞추세요."
        }
    }

    private var readinessIconName: String {
        state.isReadyToStart ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
    }
}

private struct SetupCheckRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let isComplete: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isComplete ? CoachTheme.tennisTint : CoachTheme.secondaryText)
                    .frame(width: 30, height: 30)
                    .background(.thinMaterial, in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(borderColor, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(CoachTheme.primaryText)
                    Text(detail)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoachTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isComplete ? CoachTheme.tennisTint : CoachTheme.secondaryText)
                    .frame(width: 28, height: 28)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(isComplete ? "완료" : "미완료")")
        .accessibilityHint("탭해서 체크 상태를 바꿉니다.")
    }

    private var borderColor: Color {
        isComplete ? CoachTheme.tennisTint.opacity(0.42) : CoachTheme.glassStroke
    }
}
