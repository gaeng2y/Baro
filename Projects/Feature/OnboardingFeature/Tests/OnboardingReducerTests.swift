import XCTest
@testable import OnboardingFeature
import TennisDomain

final class OnboardingReducerTests: XCTestCase {
    func testUpdatesHandedness() {
        var state = OnboardingState()
        let reducer = OnboardingReducer()

        reducer.reduce(state: &state, action: .handednessChanged(.left))

        XCTAssertEqual(state.handedness, .left)
    }

    func testUpdatesStrokePreference() {
        var state = OnboardingState()
        let reducer = OnboardingReducer()

        reducer.reduce(state: &state, action: .strokePreferenceChanged(.twoHandBackhand))

        XCTAssertEqual(state.strokePreference, .twoHandBackhand)
    }

    func testCompletedDoesNotMutateDraftState() {
        var state = OnboardingState()
        state.handedness = .left
        state.strokePreference = .twoHandBackhand
        let before = state

        OnboardingReducer().reduce(state: &state, action: .completed)

        XCTAssertEqual(state, before)
    }
}
