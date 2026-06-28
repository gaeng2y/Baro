import ComposableArchitecture
import XCTest
@testable import SettingsFeature
import TennisDomain

final class SettingsReducerTests: XCTestCase {
    func testFeedbackFrequencyChangedUpdatesState() async {
        let store = TestStore(initialState: SettingsState()) {
            SettingsReducer()
        }

        await store.send(.feedbackFrequencyChanged(.high)) {
            $0.feedbackFrequency = .high
        }
    }

    func testSaveVideoClipsChangedUpdatesState() async {
        let store = TestStore(initialState: SettingsState()) {
            SettingsReducer()
        }

        await store.send(.saveVideoClipsChanged(true)) {
            $0.saveVideoClips = true
        }
    }

    func testDeleteLocalDataResetsSettingsState() async {
        let store = TestStore(initialState: SettingsState(feedbackFrequency: .high, saveVideoClips: true)) {
            SettingsReducer()
        }

        await store.send(.deleteLocalData) {
            $0 = SettingsState()
        }
    }
}
