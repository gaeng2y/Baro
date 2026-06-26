import XCTest
@testable import MainFeature
import TennisDomain

final class MainFeatureStateTests: XCTestCase {
    func testDefaultStateHasNoRecentSummary() {
        XCTAssertNil(MainFeatureState().recentSummary)
    }

    func testStateKeepsRecentSummary() {
        let summary = SessionSummary(
            totalSwingCount: 4,
            analyzedSwingCount: 3,
            failedSwingCount: 1,
            repeatedErrors: [],
            recommendedFocus: nil
        )
        let state = MainFeatureState(recentSummary: summary)

        XCTAssertEqual(state.recentSummary, summary)
    }
}
