import DesignSystem
import SwiftUI
import TennisDomain

public struct SettingsState: Equatable {
    public var feedbackFrequency: FeedbackFrequency = .normal
    public var saveVideoClips: Bool = false

    public init() {}
}

public enum SettingsAction: Equatable {
    case feedbackFrequencyChanged(FeedbackFrequency)
    case saveVideoClipsChanged(Bool)
    case deleteLocalData
}

public struct SettingsView: View {
    @State private var state = SettingsState()
    public var onDeleteLocalData: () -> Void

    public init(onDeleteLocalData: @escaping () -> Void) {
        self.onDeleteLocalData = onDeleteLocalData
    }

    public var body: some View {
        Form {
            Section("피드백") {
                Picker("빈도", selection: $state.feedbackFrequency) {
                    Text("적게").tag(FeedbackFrequency.low)
                    Text("보통").tag(FeedbackFrequency.normal)
                    Text("자주").tag(FeedbackFrequency.high)
                }
            }

            Section("개인정보") {
                Toggle("선택한 짧은 클립 저장", isOn: $state.saveVideoClips)
                Text("원본 영상은 기본 저장하지 않고, 세션 요약과 필요한 metric만 로컬에 저장합니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(role: .destructive, action: onDeleteLocalData) {
                    Text("로컬 데이터 삭제")
                }
            }
        }
        .navigationTitle("설정")
    }
}
