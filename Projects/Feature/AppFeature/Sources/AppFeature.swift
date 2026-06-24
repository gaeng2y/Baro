import HistoryFeature
import MainFeature
import OnboardingFeature
import RecordFeature
import SessionSummaryFeature
import SettingsFeature
import SwiftUI
import TennisCore
import TennisDomain
import TrainingSetupFeature

public struct AppFeatureState: Equatable {
    public var hasCompletedOnboarding: Bool = false
    public var userProfile: UserProfile?
    public var sessions: [TrainingSession] = []
    public var route: Route = .main

    public init() {}

    public enum Route: Equatable {
        case main
        case setup(StrokeType?)
        case record(StrokeType, CameraMode)
        case summary(TrainingSession)
        case history
        case settings
    }
}

public enum AppFeatureAction: Equatable {
    case onboardingCompleted(UserProfile)
    case startTraining
    case quickStart(StrokeType)
    case startRecord(StrokeType, CameraMode)
    case sessionFinished(TrainingSession)
    case openHistory
    case openSettings
    case backToMain
    case deleteLocalData
}

public struct AppFeatureReducer {
    public init() {}

    public func reduce(state: inout AppFeatureState, action: AppFeatureAction) {
        switch action {
        case let .onboardingCompleted(profile):
            state.userProfile = profile
            state.hasCompletedOnboarding = true
            state.route = .main
        case .startTraining:
            state.route = .setup(nil)
        case let .quickStart(stroke):
            state.route = .setup(stroke)
        case let .startRecord(stroke, cameraMode):
            state.route = .record(stroke, cameraMode)
        case let .sessionFinished(session):
            state.sessions.insert(session, at: 0)
            state.route = .summary(session)
        case .openHistory:
            state.route = .history
        case .openSettings:
            state.route = .settings
        case .backToMain:
            state.route = .main
        case .deleteLocalData:
            state.sessions = []
        }
    }
}

public struct AppFeatureView: View {
    @State private var state = AppFeatureState()
    private let reducer = AppFeatureReducer()
    private let pipeline: SessionPipeline

    public init(pipeline: SessionPipeline = .preview) {
        self.pipeline = pipeline
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        if !state.hasCompletedOnboarding {
            OnboardingView { profile in
                send(.onboardingCompleted(profile))
            }
        } else {
            switch state.route {
            case .main:
                MainView(
                    onStartTraining: { send(.startTraining) },
                    onQuickStart: { send(.quickStart($0)) },
                    onHistory: { send(.openHistory) },
                    onSettings: { send(.openSettings) }
                )
            case let .setup(initialStroke):
                TrainingSetupView(initialStrokeType: initialStroke ?? .forehand) { stroke, cameraMode in
                    send(.startRecord(stroke, cameraMode))
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기") { send(.backToMain) }
                    }
                }
            case let .record(stroke, cameraMode):
                RecordView(strokeType: stroke, cameraMode: cameraMode, pipeline: pipeline) { session in
                    send(.sessionFinished(session))
                }
            case let .summary(session):
                SessionSummaryView(session: session) {
                    send(.backToMain)
                }
            case .history:
                HistoryView(sessions: state.sessions)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("닫기") { send(.backToMain) }
                        }
                    }
            case .settings:
                SettingsView {
                    send(.deleteLocalData)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기") { send(.backToMain) }
                    }
                }
            }
        }
    }

    private func send(_ action: AppFeatureAction) {
        reducer.reduce(state: &state, action: action)
    }
}
