import CameraPreviewUI
import DesignSystem
import SwiftUI
import TennisCore
import TennisDomain

public struct RecordState: Equatable {
    public var strokeType: StrokeType
    public var cameraMode: CameraMode
    public var startedAt: Date = Date()
    public var swingCount: Int = 0
    public var analyzedCount: Int = 0
    public var latestCue: CoachingCue?
    public var cameraQuality: CameraQuality = .ready
    public var isBodyDetected: Bool = false
    public var isSwinging: Bool = false
    public var isRecording: Bool = true
    public var swingEvents: [SwingEvent] = []

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
        case let .coachingEvent(.bodyDetected(isDetected)):
            state.isBodyDetected = isDetected
        case let .coachingEvent(.cameraQualityChanged(quality)):
            state.cameraQuality = quality
        case .coachingEvent(.strokeStarted):
            state.isSwinging = true
        case let .coachingEvent(.cueSelected(cue)):
            state.latestCue = cue
            if let lastIndex = state.swingEvents.indices.last {
                state.swingEvents[lastIndex].selectedCue = cue
            }
        case let .coachingEvent(.strokeFinished(result)):
            let endedAt = Date().timeIntervalSinceReferenceDate
            let startedAt = max(0, endedAt - result.metrics.swingDuration)
            state.isSwinging = false
            state.swingCount += 1
            state.analyzedCount += 1
            state.swingEvents.append(
                SwingEvent(
                    strokeType: result.strokeType,
                    startedAt: startedAt,
                    endedAt: endedAt,
                    analysisResult: result,
                    selectedCue: result.primaryError?.cue,
                    quality: .success
                )
            )
        case let .coachingEvent(.sessionMetricUpdated(metric)):
            state.swingCount = max(state.swingCount, metric.swingCount)
            state.analyzedCount = max(state.analyzedCount, metric.analyzedCount)
        case .stopSession:
            state.isRecording = false
        }
    }
}

public struct RecordView: View {
    @State private var state: RecordState
    private let reducer = RecordReducer()
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
                        statusBadgeText,
                        tone: statusBadgeTone
                    )
                }

                CameraPreviewView(camera: pipeline.camera)
                .frame(height: 300)

                HStack {
                    MetricPill(title: "스윙", value: "\(state.swingCount)")
                    MetricPill(title: "분석", value: "\(state.analyzedCount)")
                    MetricPill(title: "상태", value: qualityText)
                }

                CoachCard {
                    Text("최신 cue")
                        .font(.headline.weight(.heavy))
                    Text(state.latestCue?.text ?? "스윙 종료 직후 한 가지 cue만 들려줘요.")
                        .font(.title3.weight(.heavy))
                }

                Button(role: .destructive) {
                    finishSession()
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
            for await event in pipeline.coachingEvents(strokeType: state.strokeType) {
                guard state.isRecording else { break }
                send(.coachingEvent(event))
            }
        }
    }

    private var statusBadgeText: String {
        if !state.isRecording {
            return "STOP"
        }
        if state.isSwinging {
            return "SWING"
        }
        return state.isBodyDetected ? "READY" : "FRAME"
    }

    private var statusBadgeTone: StatusCapsule.Tone {
        if !state.isRecording {
            return .neutral
        }
        if state.isSwinging {
            return .active
        }
        return state.isBodyDetected ? .active : .warning
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

    private func send(_ action: RecordAction) {
        reducer.reduce(state: &state, action: action)
    }

    private func finishSession() {
        send(.stopSession)
        let summary = SessionSummaryBuilder.build(from: state.swingEvents)
        onStop(
            TrainingSession(
                strokeType: state.strokeType,
                cameraMode: state.cameraMode,
                startedAt: state.startedAt,
                endedAt: Date(),
                swingEvents: state.swingEvents,
                summary: summary
            )
        )
    }
}
