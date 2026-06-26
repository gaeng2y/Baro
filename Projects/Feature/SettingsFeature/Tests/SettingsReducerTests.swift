import XCTest
@testable import SettingsFeature
import TennisDomain

final class SettingsReducerTests: XCTestCase {
    func testFeedbackFrequencyChangedUpdatesState() {
        var state = SettingsState()

        SettingsReducer().reduce(state: &state, action: .feedbackFrequencyChanged(.high))

        XCTAssertEqual(state.feedbackFrequency, .high)
    }

    func testSaveVideoClipsChangedUpdatesState() {
        var state = SettingsState()

        SettingsReducer().reduce(state: &state, action: .saveVideoClipsChanged(true))

        XCTAssertTrue(state.saveVideoClips)
    }

    func testDeleteLocalDataResetsSettingsState() {
        var state = SettingsState(feedbackFrequency: .high, saveVideoClips: true)

        SettingsReducer().reduce(state: &state, action: .deleteLocalData)

        XCTAssertEqual(state, SettingsState())
    }
}
