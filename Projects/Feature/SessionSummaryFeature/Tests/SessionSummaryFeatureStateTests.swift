import XCTest
@testable import SessionSummaryFeature
import TennisDomain

final class SessionSummaryFeatureStateTests: XCTestCase {
    func testStateKeepsSession() {
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let state = SessionSummaryFeatureState(session: session)

        XCTAssertEqual(state.session, session)
    }
}
