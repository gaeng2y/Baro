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
        let analyticsRecorder = AnalyticsEventRecorder()
        let analyticsTracked = expectation(description: "analytics tracked")
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
                ),
                analytics: analyticsRecorder.client(fulfill: analyticsTracked)
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
        await fulfillment(of: [analyticsTracked], timeout: 1)
        XCTAssertEqual(analyticsRecorder.events, [.appOpened])
    }

    func testSessionFinishedStoresNewestSessionAndShowsSummary() async {
        let analyticsRecorder = AnalyticsEventRecorder()
        let analyticsTracked = expectation(description: "analytics tracked")
        analyticsTracked.expectedFulfillmentCount = 2
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(
                appStorage: .noOp,
                analytics: analyticsRecorder.client(fulfill: analyticsTracked)
            )
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
        await fulfillment(of: [analyticsTracked], timeout: 1)
        XCTAssertEqual(
            analyticsRecorder.events,
            [
                .sessionFinished(first),
                .sessionFinished(second)
            ]
        )
    }

    func testTrainingStartFlowTracksAnalytics() async {
        let analyticsRecorder = AnalyticsEventRecorder()
        let analyticsTracked = expectation(description: "analytics tracked")
        analyticsTracked.expectedFulfillmentCount = 3
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(
                appStorage: .noOp,
                analytics: analyticsRecorder.client(fulfill: analyticsTracked)
            )
        }

        await store.send(.startTraining) {
            $0.route = .setup(nil)
        }

        await store.send(.quickStart(.twoHandBackhand)) {
            $0.route = .setup(.twoHandBackhand)
        }

        await store.send(.startRecord(.forehand, .side)) {
            $0.route = .record(.forehand, .side)
        }

        await fulfillment(of: [analyticsTracked], timeout: 1)
        XCTAssertEqual(
            analyticsRecorder.events,
            [
                .trainingSetupOpened(initialStroke: nil),
                .trainingSetupOpened(initialStroke: .twoHandBackhand),
                .sessionStarted(strokeType: .forehand, cameraMode: .side)
            ]
        )
    }

    func testSettingsChangesUpdateProfileAndClipPreference() async {
        let now = Date(timeIntervalSinceReferenceDate: 200)
        let analyticsRecorder = AnalyticsEventRecorder()
        let analyticsTracked = expectation(description: "analytics tracked")
        analyticsTracked.expectedFulfillmentCount = 3
        let store = TestStore(initialState: AppFeatureState()) {
            AppFeatureReducer(
                appStorage: .noOp,
                analytics: analyticsRecorder.client(fulfill: analyticsTracked),
                now: { now }
            )
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
        await fulfillment(of: [analyticsTracked], timeout: 1)
        XCTAssertEqual(
            analyticsRecorder.events,
            [
                .onboardingCompleted(profile: profile),
                .settingsChanged(key: "feedback_frequency", value: .string("low")),
                .settingsChanged(key: "save_video_clips", value: .bool(true))
            ]
        )
    }

    func testDeleteLocalDataResetsOnboardingAndSessions() async {
        let profile = UserProfile()
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let analyticsRecorder = AnalyticsEventRecorder()
        let analyticsTracked = expectation(description: "analytics tracked")
        let store = TestStore(
            initialState: AppFeatureState(
                hasCompletedOnboarding: true,
                userProfile: profile,
                sessions: [session],
                saveVideoClips: true
            )
        ) {
            AppFeatureReducer(
                appStorage: .noOp,
                analytics: analyticsRecorder.client(fulfill: analyticsTracked)
            )
        }

        await store.send(.deleteLocalData) {
            $0.hasCompletedOnboarding = false
            $0.userProfile = nil
            $0.sessions = []
            $0.saveVideoClips = false
            $0.storageErrorMessage = nil
            $0.route = .main
        }
        await fulfillment(of: [analyticsTracked], timeout: 1)
        XCTAssertEqual(analyticsRecorder.events, [.localDataDeleted])
    }
}

private final class AnalyticsEventRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recordedEvents: [AnalyticsEvent] = []

    var events: [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return recordedEvents
    }

    func client(fulfill expectation: XCTestExpectation) -> AnalyticsClient {
        AnalyticsClient { [self] event in
            lock.lock()
            recordedEvents.append(event)
            lock.unlock()
            expectation.fulfill()
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
