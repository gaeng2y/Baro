import DesignSystem
import SwiftUI
import TennisDomain

public struct SettingsState: Equatable {
    public var feedbackFrequency: FeedbackFrequency = .normal
    public var saveVideoClips: Bool = false

    public init(
        feedbackFrequency: FeedbackFrequency = .normal,
        saveVideoClips: Bool = false
    ) {
        self.feedbackFrequency = feedbackFrequency
        self.saveVideoClips = saveVideoClips
    }
}

public enum SettingsAction: Equatable {
    case feedbackFrequencyChanged(FeedbackFrequency)
    case saveVideoClipsChanged(Bool)
    case deleteLocalData
}

public struct SettingsReducer {
    public init() {}

    public func reduce(state: inout SettingsState, action: SettingsAction) {
        switch action {
        case let .feedbackFrequencyChanged(frequency):
            state.feedbackFrequency = frequency
        case let .saveVideoClipsChanged(isEnabled):
            state.saveVideoClips = isEnabled
        case .deleteLocalData:
            state = SettingsState()
        }
    }
}

public struct SettingsView: View {
    @State private var state: SettingsState
    public var onFeedbackFrequencyChange: (FeedbackFrequency) -> Void
    public var onSaveVideoClipsChange: (Bool) -> Void
    public var onDeleteLocalData: () -> Void

    public init(
        feedbackFrequency: FeedbackFrequency = .normal,
        saveVideoClips: Bool = false,
        onFeedbackFrequencyChange: @escaping (FeedbackFrequency) -> Void = { _ in },
        onSaveVideoClipsChange: @escaping (Bool) -> Void = { _ in },
        onDeleteLocalData: @escaping () -> Void
    ) {
        self._state = State(
            initialValue: SettingsState(
                feedbackFrequency: feedbackFrequency,
                saveVideoClips: saveVideoClips
            )
        )
        self.onFeedbackFrequencyChange = onFeedbackFrequencyChange
        self.onSaveVideoClipsChange = onSaveVideoClipsChange
        self.onDeleteLocalData = onDeleteLocalData
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            Form {
                Section("피드백") {
                    Picker("빈도", selection: feedbackFrequencyBinding) {
                        Text("적게").tag(FeedbackFrequency.low)
                        Text("보통").tag(FeedbackFrequency.normal)
                        Text("자주").tag(FeedbackFrequency.high)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }

                Section("개인정보") {
                    Toggle("선택한 짧은 클립 저장", isOn: saveVideoClipsBinding)
                    Text("원본 영상은 기본 저장하지 않고, 세션 요약과 필요한 metric만 로컬에 저장합니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(role: .destructive, action: onDeleteLocalData) {
                        Text("로컬 데이터 삭제")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("설정")
    }

    private var feedbackFrequencyBinding: Binding<FeedbackFrequency> {
        Binding(
            get: { state.feedbackFrequency },
            set: { newValue in
                state.feedbackFrequency = newValue
                onFeedbackFrequencyChange(newValue)
            }
        )
    }

    private var saveVideoClipsBinding: Binding<Bool> {
        Binding(
            get: { state.saveVideoClips },
            set: { newValue in
                state.saveVideoClips = newValue
                onSaveVideoClipsChange(newValue)
            }
        )
    }
}
