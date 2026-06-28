import ComposableArchitecture
import DesignSystem
import SwiftUI
import TennisDomain

@ObservableState
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

@Reducer
public struct SettingsReducer {
    public init() {}

    public var body: some Reducer<SettingsState, SettingsAction> {
        Reduce { state, action in
            switch action {
            case let .feedbackFrequencyChanged(frequency):
                state.feedbackFrequency = frequency
                return .none
            case let .saveVideoClipsChanged(isEnabled):
                state.saveVideoClips = isEnabled
                return .none
            case .deleteLocalData:
                state = SettingsState()
                return .none
            }
        }
    }
}

public struct SettingsView: View {
    public let store: StoreOf<SettingsReducer>
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
        self.init(
            store: Store(
                initialState: SettingsState(
                    feedbackFrequency: feedbackFrequency,
                    saveVideoClips: saveVideoClips
                )
            ) {
                SettingsReducer()
            },
            onFeedbackFrequencyChange: onFeedbackFrequencyChange,
            onSaveVideoClipsChange: onSaveVideoClipsChange,
            onDeleteLocalData: onDeleteLocalData
        )
    }

    public init(
        store: StoreOf<SettingsReducer>,
        onFeedbackFrequencyChange: @escaping (FeedbackFrequency) -> Void = { _ in },
        onSaveVideoClipsChange: @escaping (Bool) -> Void = { _ in },
        onDeleteLocalData: @escaping () -> Void
    ) {
        self.store = store
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
                    Button(role: .destructive) {
                        store.send(.deleteLocalData)
                        onDeleteLocalData()
                    } label: {
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
            get: { store.feedbackFrequency },
            set: { newValue in
                store.send(.feedbackFrequencyChanged(newValue))
                onFeedbackFrequencyChange(newValue)
            }
        )
    }

    private var saveVideoClipsBinding: Binding<Bool> {
        Binding(
            get: { store.saveVideoClips },
            set: { newValue in
                store.send(.saveVideoClipsChanged(newValue))
                onSaveVideoClipsChange(newValue)
            }
        )
    }
}
