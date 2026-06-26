import XCTest
@testable import HistoryFeature
import TennisDomain

final class HistoryReducerTests: XCTestCase {
    func testDeleteRemovesMatchingSession() {
        let first = TrainingSession(id: UUID(), strokeType: .forehand, cameraMode: .side)
        let second = TrainingSession(id: UUID(), strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)
        var state = HistoryState(sessions: [first, second])

        HistoryReducer().reduce(state: &state, action: .delete(first.id))

        XCTAssertEqual(state.sessions, [second])
    }

    func testDeleteUnknownSessionDoesNothing() {
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        var state = HistoryState(sessions: [session])

        HistoryReducer().reduce(state: &state, action: .delete(UUID()))

        XCTAssertEqual(state.sessions, [session])
    }
}
