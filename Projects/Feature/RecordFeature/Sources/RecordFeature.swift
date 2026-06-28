import CameraPreviewUI
import ComposableArchitecture
import DesignSystem
import SwiftUI
import TennisCore
import TennisDomain

@ObservableState
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
    public var finishedSession: TrainingSession?

    public init(
        strokeType: StrokeType,
        cameraMode: CameraMode,
        startedAt: Date = Date()
    ) {
        self.strokeType = strokeType
        self.cameraMode = cameraMode
        self.startedAt = startedAt
    }
}

public enum RecordAction: Equatable {
    case task
    case coachingEvent(CoachingEvent)
    case stopSession
}

@Reducer
public struct RecordReducer {
    private let pipeline: SessionPipeline
    private let now: @Sendable () -> Date
    private let makeID: @Sendable () -> UUID

    public init(
        pipeline: SessionPipeline = .preview,
        now: @escaping @Sendable () -> Date = Date.init,
        makeID: @escaping @Sendable () -> UUID = UUID.init
    ) {
        self.pipeline = pipeline
        self.now = now
        self.makeID = makeID
    }

    public var body: some Reducer<RecordState, RecordAction> {
        Reduce { state, action in
            switch action {
            case .task:
                let pipeline = self.pipeline
                let strokeType = state.strokeType
                return .run { send in
                    for await event in pipeline.coachingEvents(strokeType: strokeType) {
                        await send(.coachingEvent(event))
                    }
                }

            case let .coachingEvent(event):
                guard state.isRecording else {
                    return .none
                }
                switch event {
                case let .bodyDetected(isDetected):
                    state.isBodyDetected = isDetected
                case let .cameraQualityChanged(quality):
                    state.cameraQuality = quality
                case .strokeStarted:
                    state.isSwinging = true
                case let .cueSelected(cue):
                    state.latestCue = cue
                    if let lastIndex = state.swingEvents.indices.last {
                        state.swingEvents[lastIndex].selectedCue = cue
                    }
                case let .strokeFinished(result):
                    let endedAt = now().timeIntervalSinceReferenceDate
                    let startedAt = max(0, endedAt - result.metrics.swingDuration)
                    state.isSwinging = false
                    state.swingCount += 1
                    state.analyzedCount += 1
                    state.swingEvents.append(
                        SwingEvent(
                            id: makeID(),
                            strokeType: result.strokeType,
                            startedAt: startedAt,
                            endedAt: endedAt,
                            analysisResult: result,
                            selectedCue: result.primaryError?.cue,
                            quality: .success
                        )
                    )
                case let .sessionMetricUpdated(metric):
                    state.swingCount = max(state.swingCount, metric.swingCount)
                    state.analyzedCount = max(state.analyzedCount, metric.analyzedCount)
                }
                return .none

            case .stopSession:
                state.isRecording = false
                let summary = SessionSummaryBuilder.build(from: state.swingEvents)
                state.finishedSession = TrainingSession(
                    id: makeID(),
                    strokeType: state.strokeType,
                    cameraMode: state.cameraMode,
                    startedAt: state.startedAt,
                    endedAt: now(),
                    swingEvents: state.swingEvents,
                    summary: summary
                )
                return .none
            }
        }
    }
}

public struct RecordView: View {
    public let store: StoreOf<RecordReducer>
    private let camera: CameraClient
    public var onStop: (TrainingSession) -> Void

    public init(
        strokeType: StrokeType,
        cameraMode: CameraMode,
        pipeline: SessionPipeline = .preview,
        onStop: @escaping (TrainingSession) -> Void
    ) {
        self.init(
            store: Store(initialState: RecordState(strokeType: strokeType, cameraMode: cameraMode)) {
                RecordReducer(pipeline: pipeline)
            },
            camera: pipeline.camera,
            onStop: onStop
        )
    }

    public init(
        store: StoreOf<RecordReducer>,
        camera: CameraClient = .preview,
        onStop: @escaping (TrainingSession) -> Void
    ) {
        self.store = store
        self.camera = camera
        self.onStop = onStop
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        StatusCapsule(store.cameraMode.title, tone: .neutral)
                        Text(store.strokeType.title)
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

                CameraPreviewView(camera: camera)
                    .frame(height: 300)
                    .overlay {
                        CameraStatusOverlay(
                            cameraMode: store.cameraMode,
                            cameraQuality: store.cameraQuality,
                            isBodyDetected: store.isBodyDetected,
                            isSwinging: store.isSwinging
                        )
                    }
                    .allowsHitTesting(false)

                HStack {
                    MetricPill(title: "스윙", value: "\(store.swingCount)")
                    MetricPill(title: "분석", value: "\(store.analyzedCount)")
                    MetricPill(title: "상태", value: qualityText)
                }

                CoachCard {
                    Text("최신 cue")
                        .font(.headline.weight(.heavy))
                    Text(store.latestCue?.text ?? "스윙 종료 직후 한 가지 cue만 들려줘요.")
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
            store.send(.task)
        }
    }

    private var statusBadgeText: String {
        if !store.isRecording {
            return "STOP"
        }
        if store.isSwinging {
            return "SWING"
        }
        return store.isBodyDetected ? "READY" : "FRAME"
    }

    private var statusBadgeTone: StatusCapsule.Tone {
        if !store.isRecording {
            return .neutral
        }
        if store.isSwinging {
            return .active
        }
        return store.isBodyDetected ? .active : .warning
    }

    private var qualityText: String {
        switch store.cameraQuality {
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

    private func finishSession() {
        store.send(.stopSession)
        if let session = store.finishedSession {
            onStop(session)
        }
    }
}

private struct CameraStatusOverlay: View {
    let cameraMode: CameraMode
    let cameraQuality: CameraQuality
    let isBodyDetected: Bool
    let isSwinging: Bool

    var body: some View {
        ZStack {
            bodyFrameGuide

            VStack {
                HStack {
                    CameraOverlayBadge(
                        iconName: "viewfinder.rectangular",
                        title: "전신 프레임",
                        tint: isBodyDetected ? CoachTheme.tennisTint : .white
                    )
                    Spacer()
                    CameraOverlayBadge(
                        iconName: "camera.metering.center.weighted",
                        title: cameraMode.title,
                        tint: .white
                    )
                }

                Spacer()

                HStack(spacing: 8) {
                    CameraOverlayMetric(
                        iconName: isBodyDetected ? "checkmark.circle.fill" : "figure.stand",
                        title: "몸 인식",
                        value: isBodyDetected ? "완료" : "대기",
                        tint: isBodyDetected ? CoachTheme.tennisTint : .orange
                    )
                    CameraOverlayMetric(
                        iconName: qualityIconName,
                        title: "화질",
                        value: qualityText,
                        tint: qualityTint
                    )
                    CameraOverlayMetric(
                        iconName: isSwinging ? "figure.tennis" : "pause.circle.fill",
                        title: "스윙",
                        value: isSwinging ? "감지" : "대기",
                        tint: isSwinging ? CoachTheme.tennisTint : .white
                    )
                }
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }

    private var bodyFrameGuide: some View {
        GeometryReader { proxy in
            let horizontalInset = max(46, proxy.size.width * 0.18)

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(
                    isBodyDetected ? CoachTheme.tennisTint.opacity(0.92) : Color.white.opacity(0.44),
                    style: StrokeStyle(lineWidth: 2, dash: isBodyDetected ? [] : [9, 8])
                )
                .padding(.horizontal, horizontalInset)
                .padding(.vertical, 26)
                .overlay {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 1)
                        Circle()
                            .strokeBorder(Color.white.opacity(0.36), lineWidth: 1)
                            .frame(width: 74, height: 74)
                        Rectangle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 1)
                    }
                    .padding(.vertical, 40)
                    .opacity(isBodyDetected ? 0.2 : 0.42)
                }
        }
    }

    private var qualityText: String {
        switch cameraQuality {
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

    private var qualityIconName: String {
        switch cameraQuality {
        case .ready:
            "checkmark.seal.fill"
        case .bodyOutOfFrame:
            "figure.stand.line.dotted.figure.stand"
        case .lowLight:
            "lightbulb.slash.fill"
        case .unstable:
            "waveform.path.ecg"
        case .lowConfidence:
            "eye.slash.fill"
        }
    }

    private var qualityTint: Color {
        switch cameraQuality {
        case .ready:
            CoachTheme.tennisTint
        case .bodyOutOfFrame, .lowLight, .unstable, .lowConfidence:
            .orange
        }
    }
}

private struct CameraOverlayBadge: View {
    let iconName: String
    let title: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: iconName)
            .font(.caption.weight(.heavy))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 12)
            .frame(minHeight: 32)
            .background(.ultraThinMaterial, in: Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.24), radius: 12, x: 0, y: 6)
    }
}

private struct CameraOverlayMetric: View {
    let iconName: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName)
                .font(.caption.weight(.heavy))
                .foregroundStyle(tint)
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.72))
                Text(value)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)
    }
}
