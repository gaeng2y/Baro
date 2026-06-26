import XCTest
@testable import TennisCore
import TennisDomain

final class LocalSessionStoreClientTests: XCTestCase {
    func testLiveStoreRoundTripsSessions() async throws {
        let store = LocalSessionStoreClient.live(fileName: "test-sessions-\(UUID().uuidString).json")
        let sessions = [
            TrainingSession(strokeType: .forehand, cameraMode: .side),
            TrainingSession(strokeType: .twoHandBackhand, cameraMode: .rearDiagonal)
        ]

        try await store.deleteAll()
        try await store.save(sessions)
        let loaded = try await store.load()
        try await store.deleteAll()

        XCTAssertEqual(loaded, sessions)
    }

    func testLiveStoreReturnsEmptyArrayWhenMissing() async throws {
        let store = LocalSessionStoreClient.live(fileName: "test-sessions-\(UUID().uuidString).json")
        try await store.deleteAll()

        let loaded = try await store.load()

        XCTAssertEqual(loaded, [])
    }
}
