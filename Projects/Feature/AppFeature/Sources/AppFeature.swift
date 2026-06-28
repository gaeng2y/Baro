import ComposableArchitecture
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
    public var saveVideoClips: Bool = false
    public var storageErrorMessage: String?
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
    case task
    case appStorageLoaded(PersistedAppState)
    case appStorageFailed(String)
    case onboardingCompleted(UserProfile)
    case startTraining
    case quickStart(StrokeType)
    case startRecord(StrokeType, CameraMode)
    case sessionFinished(TrainingSession)
    case feedbackFrequencyChanged(FeedbackFrequency)
    case saveVideoClipsChanged(Bool)
    case openHistory
    case openSettings
    case backToMain
    case deleteLocalData
}

public struct AppFeatureReducer: Reducer {
    public typealias State = AppFeatureState
    public typealias Action = AppFeatureAction

    private let appStorage: LocalAppStorageClient
    private let now: @Sendable () -> Date

    public init(
        appStorage: LocalAppStorageClient = .preview,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.appStorage = appStorage
        self.now = now
    }

    public var body: some Reducer<AppFeatureState, AppFeatureAction> {
        Reduce { state, action in
            switch action {
            case .task:
                let appStorage = self.appStorage
                return .run { send in
                    do {
                        let persistedState = try await appStorage.load()
                        await send(.appStorageLoaded(persistedState))
                    } catch {
                        await send(.appStorageFailed(error.localizedDescription))
                    }
                }

            case let .appStorageLoaded(persistedState):
                state.userProfile = persistedState.userProfile
                state.hasCompletedOnboarding = persistedState.userProfile != nil
                state.sessions = persistedState.sessions
                state.saveVideoClips = persistedState.saveVideoClips
                state.storageErrorMessage = nil
                state.route = .main
                return .none

            case let .appStorageFailed(message):
                state.storageErrorMessage = message
                return .none

            case let .onboardingCompleted(profile):
                state.userProfile = profile
                state.hasCompletedOnboarding = true
                state.storageErrorMessage = nil
                state.route = .main
                return save(state.persistedAppState)

            case .startTraining:
                state.route = .setup(nil)
                return .none

            case let .quickStart(stroke):
                state.route = .setup(stroke)
                return .none

            case let .startRecord(stroke, cameraMode):
                state.route = .record(stroke, cameraMode)
                return .none

            case let .sessionFinished(session):
                state.sessions.insert(session, at: 0)
                state.route = .summary(session)
                return save(state.persistedAppState)

            case let .feedbackFrequencyChanged(frequency):
                guard var profile = state.userProfile else {
                    return .none
                }
                profile.feedbackFrequency = frequency
                profile.updatedAt = now()
                state.userProfile = profile
                return save(state.persistedAppState)

            case let .saveVideoClipsChanged(isEnabled):
                state.saveVideoClips = isEnabled
                return save(state.persistedAppState)

            case .openHistory:
                state.route = .history
                return .none

            case .openSettings:
                state.route = .settings
                return .none

            case .backToMain:
                state.route = .main
                return .none

            case .deleteLocalData:
                state.hasCompletedOnboarding = false
                state.userProfile = nil
                state.sessions = []
                state.saveVideoClips = false
                state.storageErrorMessage = nil
                state.route = .main
                return deleteLocalData()
            }
        }
    }

    private func save(_ persistedState: PersistedAppState) -> Effect<AppFeatureAction> {
        let appStorage = appStorage
        return .run { send in
            do {
                try await appStorage.save(persistedState)
            } catch {
                await send(.appStorageFailed(error.localizedDescription))
            }
        }
    }

    private func deleteLocalData() -> Effect<AppFeatureAction> {
        let appStorage = appStorage
        return .run { send in
            do {
                try await appStorage.deleteAll()
            } catch {
                await send(.appStorageFailed(error.localizedDescription))
            }
        }
    }
}

public struct AppFeatureView: View {
    public let store: StoreOf<AppFeatureReducer>
    private let pipeline: SessionPipeline

    public init(
        pipeline: SessionPipeline = .preview,
        appStorage: LocalAppStorageClient = .preview
    ) {
        self.init(
            store: Store(initialState: AppFeatureState()) {
                AppFeatureReducer(appStorage: appStorage)
            },
            pipeline: pipeline
        )
    }

    public init(
        store: StoreOf<AppFeatureReducer>,
        pipeline: SessionPipeline = .preview
    ) {
        self.store = store
        self.pipeline = pipeline
    }

    public var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                content(viewStore)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            store.send(.task)
        }
    }

    @ViewBuilder
    private func content(_ viewStore: ViewStore<AppFeatureState, AppFeatureAction>) -> some View {
        if !viewStore.hasCompletedOnboarding {
            OnboardingView { profile in
                viewStore.send(.onboardingCompleted(profile))
            }
        } else {
            switch viewStore.route {
            case .main:
                MainView(
                    onStartTraining: { viewStore.send(.startTraining) },
                    onQuickStart: { viewStore.send(.quickStart($0)) },
                    onHistory: { viewStore.send(.openHistory) },
                    onSettings: { viewStore.send(.openSettings) }
                )
            case let .setup(initialStroke):
                TrainingSetupView(initialStrokeType: initialStroke ?? .forehand) { stroke, cameraMode in
                    viewStore.send(.startRecord(stroke, cameraMode))
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기") { viewStore.send(.backToMain) }
                    }
                }
            case let .record(stroke, cameraMode):
                RecordView(strokeType: stroke, cameraMode: cameraMode, pipeline: pipeline) { session in
                    viewStore.send(.sessionFinished(session))
                }
            case let .summary(session):
                SessionSummaryView(session: session) {
                    viewStore.send(.backToMain)
                }
            case .history:
                HistoryView(sessions: viewStore.sessions)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("닫기") { viewStore.send(.backToMain) }
                        }
                    }
            case .settings:
                SettingsView(
                    feedbackFrequency: viewStore.userProfile?.feedbackFrequency ?? .normal,
                    saveVideoClips: viewStore.saveVideoClips,
                    onFeedbackFrequencyChange: { viewStore.send(.feedbackFrequencyChanged($0)) },
                    onSaveVideoClipsChange: { viewStore.send(.saveVideoClipsChanged($0)) }
                ) {
                    viewStore.send(.deleteLocalData)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기") { viewStore.send(.backToMain) }
                    }
                }
            }
        }
    }
}

private extension AppFeatureState {
    var persistedAppState: PersistedAppState {
        PersistedAppState(
            userProfile: userProfile,
            sessions: sessions,
            saveVideoClips: saveVideoClips
        )
    }
}
