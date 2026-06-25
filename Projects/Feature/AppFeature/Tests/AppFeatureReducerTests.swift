import XCTest
@testable import AppFeature
import TennisCore
import TennisDomain

final class AppFeatureReducerTests: XCTestCase {
    func testLoadsPersistedAppState() {
        var state = AppFeatureState()
        let reducer = AppFeatureReducer()
        let profile = UserProfile(handedness: .left, feedbackFrequency: .high)
        let session = TrainingSession(strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)

        reducer.reduce(
            state: &state,
            action: .appStorageLoaded(
                PersistedAppState(
                    userProfile: profile,
                    sessions: [session],
                    saveVideoClips: true
                )
            )
        )

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertEqual(state.userProfile, profile)
        XCTAssertEqual(state.sessions, [session])
        XCTAssertTrue(state.saveVideoClips)
        XCTAssertEqual(state.route, .main)
        XCTAssertNil(state.storageErrorMessage)
    }

    func testSessionFinishedStoresNewestSessionAndShowsSummary() {
        var state = AppFeatureState()
        let reducer = AppFeatureReducer()
        let first = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let second = TrainingSession(strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)

        reducer.reduce(state: &state, action: .sessionFinished(first))
        reducer.reduce(state: &state, action: .sessionFinished(second))

        XCTAssertEqual(state.sessions, [second, first])
        XCTAssertEqual(state.route, .summary(second))
    }

    func testSettingsChangesUpdateProfileAndClipPreference() {
        var state = AppFeatureState()
        let reducer = AppFeatureReducer()
        let profile = UserProfile(feedbackFrequency: .normal)

        reducer.reduce(state: &state, action: .onboardingCompleted(profile))
        reducer.reduce(state: &state, action: .feedbackFrequencyChanged(.low))
        reducer.reduce(state: &state, action: .saveVideoClipsChanged(true))

        XCTAssertEqual(state.userProfile?.feedbackFrequency, .low)
        XCTAssertTrue(state.saveVideoClips)
    }

    func testDeleteLocalDataResetsOnboardingAndSessions() {
        var state = AppFeatureState()
        let reducer = AppFeatureReducer()
        let profile = UserProfile()
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)

        reducer.reduce(
            state: &state,
            action: .appStorageLoaded(
                PersistedAppState(
                    userProfile: profile,
                    sessions: [session],
                    saveVideoClips: true
                )
            )
        )
        reducer.reduce(state: &state, action: .deleteLocalData)

        XCTAssertFalse(state.hasCompletedOnboarding)
        XCTAssertNil(state.userProfile)
        XCTAssertTrue(state.sessions.isEmpty)
        XCTAssertFalse(state.saveVideoClips)
        XCTAssertEqual(state.route, .main)
    }
}
