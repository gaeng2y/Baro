import DesignSystem
import SwiftUI
import TennisCore
import TennisDomain

public struct RecordState: Equatable {
    public var strokeType: StrokeType
    public var cameraMode: CameraMode
    public var swingCount: Int = 0
    public var latestCue: CoachingCue?
    public var cameraQuality: CameraQuality = .ready
    public var isRecording: Bool = true

    public init(strokeType: StrokeType, cameraMode: CameraMode) {
        self.strokeType = strokeType
        self.cameraMode = cameraMode
    }
}

public enum RecordAction: Equatable {
    case coachingEvent(CoachingEvent)
    case stopSession
}

public struct RecordReducer {
    public init() {}

    public func reduce(state: inout RecordState, action: RecordAction) {
        switch action {
        case let .coachingEvent(.cameraQualityChanged(quality)):
            state.cameraQuality = quality
        case let .coachingEvent(.cueSelected(cue)):
            state.latestCue = cue
        case .coachingEvent(.strokeFinished):
            state.swingCount += 1
        case .stopSession:
            state.isRecording = false
        default:
            break
        }
    }
}

public struct RecordView: View {
    @State private var state: RecordState
    private let pipeline: SessionPipeline
    public var onStop: (TrainingSession) -> Void

    public init(
        strokeType: StrokeType,
        cameraMode: CameraMode,
        pipeline: SessionPipeline = .preview,
        onStop: @escaping (TrainingSession) -> Void
    ) {
        self._state = State(initialValue: RecordState(strokeType: strokeType, cameraMode: cameraMode))
        self.pipeline = pipeline
        self.onStop = onStop
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        StatusCapsule(state.cameraMode.title, tone: .neutral)
                        Text(state.strokeType.title)
                            .font(.largeTitle.weight(.heavy))
                        Text("스윙 직후 하나의 cue만 전달합니다.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StatusCapsule(
                        state.isRecording ? "REC" : "STOP",
                        tone: state.isRecording ? .destructive : .neutral
                    )
                }

                CameraGlassPlaceholder(
                    title: "Camera Preview",
                    subtitle: "Phase 0에서 AVFoundation preview layer를 연결합니다."
                )
                .frame(height: 300)

                HStack {
                    MetricPill(title: "스윙", value: "\(state.swingCount)")
                    MetricPill(title: "상태", value: qualityText)
                }

                CoachCard {
                    Text("최신 cue")
                        .font(.headline.weight(.heavy))
                    Text(state.latestCue?.text ?? "스윙 종료 직후 한 가지 cue만 들려줘요.")
                        .font(.title3.weight(.heavy))
                }

                Button(role: .destructive) {
                    state.isRecording = false
                    onStop(
                        TrainingSession(
                            strokeType: state.strokeType,
                            cameraMode: state.cameraMode,
                            endedAt: Date(),
                            summary: SessionSummary(
                                totalSwingCount: state.swingCount,
                                analyzedSwingCount: state.swingCount,
                                failedSwingCount: 0,
                                repeatedErrors: [],
                                recommendedFocus: state.latestCue
                            )
                        )
                    )
                } label: {
                    Text("세션 종료")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.red)

                Spacer()
            }
            .padding(20)
        }
        .task {
            _ = await pipeline.camera.requestAccess()
        }
    }

    private var qualityText: String {
        switch state.cameraQuality {
        case .ready:
            "분석 가능"
        case .bodyOutOfFrame:
            "화면 안으로"
        case .lowLight:
            "조명 부족"
        case .unstable:
            "흔들림"
        case .lowConfidence:
            "인식 낮음"
        }
    }
}
