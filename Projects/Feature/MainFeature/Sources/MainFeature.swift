import ComposableArchitecture
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
    case quickStart(StrokeType)
    case openHistory
    case openSettings
}

public struct MainFeatureReducer: Reducer {
    public typealias State = MainFeatureState
    public typealias Action = MainFeatureAction

    public init() {}

    public var body: some Reducer<MainFeatureState, MainFeatureAction> {
        Reduce { _, _ in
            .none
        }
    }
}

public struct MainView: View {
    public let store: StoreOf<MainFeatureReducer>
    public var onStartTraining: () -> Void
    public var onQuickStart: (StrokeType) -> Void
    public var onHistory: () -> Void
    public var onSettings: () -> Void

    public init(
        onStartTraining: @escaping () -> Void,
        onQuickStart: @escaping (StrokeType) -> Void,
        onHistory: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.init(
            store: Store(initialState: MainFeatureState()) {
                MainFeatureReducer()
            },
            onStartTraining: onStartTraining,
            onQuickStart: onQuickStart,
            onHistory: onHistory,
            onSettings: onSettings
        )
    }

    public init(
        store: StoreOf<MainFeatureReducer>,
        onStartTraining: @escaping () -> Void,
        onQuickStart: @escaping (StrokeType) -> Void,
        onHistory: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.store = store
        self.onStartTraining = onStartTraining
        self.onQuickStart = onQuickStart
        self.onHistory = onHistory
        self.onSettings = onSettings
    }

    public var body: some View {
        ZStack {
            LiquidGlassBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            StatusCapsule("AIRPODS FORM COACH", tone: .active)
                            Text("TennisCoach")
                                .font(.largeTitle.weight(.heavy))
                            Text("오늘은 하나의 cue에 집중해요.")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        GlassIconButton(systemName: "gearshape.fill") {
                            store.send(.openSettings)
                            onSettings()
                        }
                    }

                    PrimaryCoachButton("훈련 시작") {
                        store.send(.startTraining)
                        onStartTraining()
                    }

                    CoachCard {
                        HStack {
                            Text("빠른 시작")
                                .font(.headline.weight(.heavy))
                            Spacer()
                            StatusCapsule("체크 후 시작", tone: .neutral)
                        }

                        HStack(spacing: 10) {
                            QuickStartShortcut(
                                title: "포핸드",
                                detail: "측면 세팅",
                                systemImage: "figure.tennis",
                                tint: CoachTheme.tennisTint
                            ) {
                                store.send(.quickStart(.forehand))
                                onQuickStart(.forehand)
                            }
                            QuickStartShortcut(
                                title: "양손 백핸드",
                                detail: "회전 확인",
                                systemImage: "arrow.triangle.2.circlepath",
                                tint: CoachTheme.courtBlue
                            ) {
                                store.send(.quickStart(.twoHandBackhand))
                                onQuickStart(.twoHandBackhand)
                            }
                        }
                    }

                    CoachCard {
                        Text("최근 세션")
                            .font(.headline.weight(.heavy))
                        Text("아직 세션 기록이 없어요.")
                            .foregroundStyle(.secondary)
                        Button("히스토리 보기") {
                            store.send(.openHistory)
                            onHistory()
                        }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                    }
                }
                .padding(20)
            }
        }
    }
}

private struct QuickStartShortcut: View {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(tint)
                        .frame(width: 34, height: 34)
                        .background(.thinMaterial, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(tint.opacity(0.28), lineWidth: 1)
                        }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(CoachTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(CoachTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(detail)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoachTheme.secondaryText)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(tint.opacity(0.24), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) 빠른 시작")
        .accessibilityHint("선택한 동작으로 훈련 설정을 엽니다.")
    }
}
