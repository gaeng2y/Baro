import ComposableArchitecture
import XCTest
@testable import HistoryFeature
import TennisDomain

final class HistoryReducerTests: XCTestCase {
    func testDeleteRemovesMatchingSession() async {
        let first = TrainingSession(id: UUID(), strokeType: .forehand, cameraMode: .side)
        let second = TrainingSession(id: UUID(), strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)
        let store = TestStore(initialState: HistoryState(sessions: [first, second])) {
            HistoryReducer()
        }

        await store.send(.delete(first.id)) {
            $0.sessions = [second]
        }
    }

    func testDeleteUnknownSessionDoesNothing() async {
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let store = TestStore(initialState: HistoryState(sessions: [session])) {
            HistoryReducer()
        }

        await store.send(.delete(UUID()))
    }
}
