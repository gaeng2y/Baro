import ComposableArchitecture
import XCTest
@testable import AppFeature
import TennisCore
import TennisDomain

@MainActor
final class AppFeatureReducerTests: XCTestCase {
    func testLoadsPersistedAppState() async {
        let profile = UserProfile(handedness: .left, feedbackFrequency: .high)
        let session = TrainingSession(strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)
        let persistedState = PersistedAppState(
            userProfile: profile,
            sessions: [session],
            saveVideoClips: true
        )
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(
                appStorage: LocalAppStorageClient(
                    load: { persistedState },
                    save: { _ in },
                    deleteAll: {}
                )
            )
        }

        await store.send(.task)
        await store.receive(.appStorageLoaded(persistedState)) {
            $0.hasCompletedOnboarding = true
            $0.userProfile = profile
            $0.sessions = [session]
            $0.saveVideoClips = true
            $0.route = .main
            $0.storageErrorMessage = nil
        }
    }

    func testSessionFinishedStoresNewestSessionAndShowsSummary() async {
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(appStorage: .noOp)
        }
        let first = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let second = TrainingSession(strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)

        await store.send(.sessionFinished(first)) {
            $0.sessions = [first]
            $0.route = .summary(first)
        }

        await store.send(.sessionFinished(second)) {
            $0.sessions = [second, first]
            $0.route = .summary(second)
        }
    }

    func testSettingsChangesUpdateProfileAndClipPreference() async {
        let now = Date(timeIntervalSinceReferenceDate: 200)
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(appStorage: .noOp, now: { now })
        }
        let profile = UserProfile(feedbackFrequency: .normal)
        var updatedProfile = profile
        updatedProfile.feedbackFrequency = .low
        updatedProfile.updatedAt = now

        await store.send(.onboardingCompleted(profile)) {
            $0.userProfile = profile
            $0.hasCompletedOnboarding = true
            $0.storageErrorMessage = nil
            $0.route = .main
        }

        await store.send(.feedbackFrequencyChanged(.low)) {
            $0.userProfile = updatedProfile
        }

        await store.send(.saveVideoClipsChanged(true)) {
            $0.saveVideoClips = true
        }
    }

    func testDeleteLocalDataResetsOnboardingAndSessions() async {
        let profile = UserProfile()
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let store = TestStore(
            initialState: AppFeatureState(
                hasCompletedOnboarding: true,
                userProfile: profile,
                sessions: [session],
                saveVideoClips: true
            )
        ) {
            AppFeatureReducer(appStorage: .noOp)
        }

        await store.send(.deleteLocalData) {
            $0.hasCompletedOnboarding = false
            $0.userProfile = nil
            $0.sessions = []
            $0.saveVideoClips = false
            $0.storageErrorMessage = nil
            $0.route = .main
        }
    }
}

private extension AppFeatureState {
    init(
        hasCompletedOnboarding: Bool,
        userProfile: UserProfile?,
        sessions: [TrainingSession],
        saveVideoClips: Bool
    ) {
        self.init()
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.userProfile = userProfile
        self.sessions = sessions
        self.saveVideoClips = saveVideoClips
    }
}

private extension LocalAppStorageClient {
    static let noOp = LocalAppStorageClient(
        load: { PersistedAppState() },
        save: { _ in },
        deleteAll: {}
    )
}
