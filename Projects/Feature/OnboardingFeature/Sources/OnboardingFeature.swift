import ComposableArchitecture
import DesignSystem
import SwiftUI
import TennisDomain

public struct OnboardingState: Equatable {
    public var handedness: Handedness = .right
    public var strokePreference: StrokeType = .forehand
    public var backhandType: BackhandType = .twoHanded
    public var feedbackFrequency: FeedbackFrequency = .normal

    public init() {}
}

public enum OnboardingAction: Equatable {
    case handednessChanged(Handedness)
    case strokePreferenceChanged(StrokeType)
    case completed
}

public struct OnboardingReducer: Reducer {
    public typealias State = OnboardingState
    public typealias Action = OnboardingAction

    public init() {}

    public var body: some Reducer<OnboardingState, OnboardingAction> {
        Reduce { state, action in
            switch action {
            case let .handednessChanged(handedness):
                state.handedness = handedness
                return .none
            case let .strokePreferenceChanged(stroke):
                state.strokePreference = stroke
                return .none
            case .completed:
                return .none
            }
        }
    }
}

public struct OnboardingView: View {
    public let store: StoreOf<OnboardingReducer>
    public var onComplete: (UserProfile) -> Void

    public init(onComplete: @escaping (UserProfile) -> Void) {
        self.init(
            store: Store(initialState: OnboardingState()) {
                OnboardingReducer()
            },
            onComplete: onComplete
        )
    }

    public init(
        store: StoreOf<OnboardingReducer>,
        onComplete: @escaping (UserProfile) -> Void
    ) {
        self.store = store
        self.onComplete = onComplete
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            StatusCapsule("ON-DEVICE COACH", tone: .active)
                            Text("TennisCoach")
                                .font(.largeTitle.weight(.heavy))
                            Text("스윙 직후 AirPods로 하나의 교정 큐를 들려줘요.")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }

                        CoachCard {
                            Text("기본 설정")
                                .font(.headline.weight(.heavy))
                            Picker("주 사용 손", selection: handednessBinding(viewStore)) {
                                Text("오른손").tag(Handedness.right)
                                Text("왼손").tag(Handedness.left)
                            }
                            .pickerStyle(.segmented)

                            Picker("주 연습", selection: strokePreferenceBinding(viewStore)) {
                                ForEach(StrokeType.allCases) { stroke in
                                    Text(stroke.title).tag(stroke)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        CoachCard {
                            Label("카메라 영상은 기본 저장하지 않고 온디바이스에서 처리합니다.", systemImage: "lock.shield")
                            Label("AirPods가 없어도 현재 오디오 출력 장치로 cue를 재생합니다.", systemImage: "airpodspro")
                            Label("iPhone을 삼각대에 고정하고 전신이 보이게 배치하세요.", systemImage: "camera")
                        }
                        .font(.subheadline.weight(.semibold))

                        PrimaryCoachButton("시작하기") {
                            viewStore.send(.completed)
                            onComplete(
                                UserProfile(
                                    handedness: viewStore.handedness,
                                    backhandType: viewStore.backhandType,
                                    feedbackFrequency: viewStore.feedbackFrequency
                                )
                            )
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private func handednessBinding(
        _ viewStore: ViewStore<OnboardingState, OnboardingAction>
    ) -> Binding<Handedness> {
        viewStore.binding(
            get: \.handedness,
            send: OnboardingAction.handednessChanged
        )
    }

    private func strokePreferenceBinding(
        _ viewStore: ViewStore<OnboardingState, OnboardingAction>
    ) -> Binding<StrokeType> {
        viewStore.binding(
            get: \.strokePreference,
            send: OnboardingAction.strokePreferenceChanged
        )
    }
}
