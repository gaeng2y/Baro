import DesignSystem
import SwiftUI
import TennisDomain

public struct MainFeatureState: Equatable {
    public var recentSummary: SessionSummary?

    public init(recentSummary: SessionSummary? = nil) {
        self.recentSummary = recentSummary
    }
}

public enum MainFeatureAction: Equatable {
    case startTraining
    case openHistory
    case openSettings
}

public struct MainView: View {
    public var onStartTraining: () -> Void
    public var onHistory: () -> Void
    public var onSettings: () -> Void

    public init(
        onStartTraining: @escaping () -> Void,
        onHistory: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.onStartTraining = onStartTraining
        self.onHistory = onHistory
        self.onSettings = onSettings
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TennisCoach")
                            .font(.largeTitle.weight(.heavy))
                        Text("오늘은 하나의 cue에 집중해요.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: onSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                }

                PrimaryCoachButton("훈련 시작", action: onStartTraining)

                CoachCard {
                    Text("빠른 시작")
                        .font(.headline.weight(.heavy))
                    HStack {
                        MetricPill(title: "포핸드", value: "시작")
                        MetricPill(title: "백핸드", value: "시작")
                    }
                }

                CoachCard {
                    Text("최근 세션")
                        .font(.headline.weight(.heavy))
                    Text("아직 세션 기록이 없어요.")
                        .foregroundStyle(.secondary)
                    Button("히스토리 보기", action: onHistory)
                }
            }
            .padding(20)
        }
        .background(CoachTheme.canvas)
    }
}
