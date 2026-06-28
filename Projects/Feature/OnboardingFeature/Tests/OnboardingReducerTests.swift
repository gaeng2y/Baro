import ComposableArchitecture
import XCTest
@testable import OnboardingFeature
import TennisDomain

final class OnboardingReducerTests: XCTestCase {
    func testUpdatesHandedness() async {
        let store = TestStore(initialState: OnboardingState()) {
            OnboardingReducer()
        }

        await store.send(.handednessChanged(.left)) {
            $0.handedness = .left
        }
    }

    func testUpdatesStrokePreference() async {
        let store = TestStore(initialState: OnboardingState()) {
            OnboardingReducer()
        }

        await store.send(.strokePreferenceChanged(.twoHandBackhand)) {
            $0.strokePreference = .twoHandBackhand
        }
    }

    func testCompletedDoesNotMutateDraftState() async {
        var state = OnboardingState()
        state.handedness = .left
        state.strokePreference = .twoHandBackhand

        let store = TestStore(initialState: state) {
            OnboardingReducer()
        }

        await store.send(.completed)
    }
}
