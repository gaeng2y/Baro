import XCTest
@testable import TennisCore
import TennisDomain

final class LocalAppStorageClientTests: XCTestCase {
    func testLiveStoreRoundTripsPersistedAppState() async throws {
        let store = LocalAppStorageClient.live(fileName: "test-app-state-\(UUID().uuidString).json")
        let profile = UserProfile(handedness: .left, feedbackFrequency: .high)
        let session = TrainingSession(strokeType: .forehand, cameraMode: .side)
        let persistedState = PersistedAppState(
            userProfile: profile,
            sessions: [session],
            saveVideoClips: true
        )

        try await store.deleteAll()
        try await store.save(persistedState)
        let loaded = try await store.load()
        try await store.deleteAll()

        XCTAssertEqual(loaded, persistedState)
    }

    func testLiveStoreReturnsDefaultAfterDelete() async throws {
        let store = LocalAppStorageClient.live(fileName: "test-app-state-\(UUID().uuidString).json")
        try await store.save(PersistedAppState(userProfile: UserProfile(), saveVideoClips: true))
        try await store.deleteAll()

        let loaded = try await store.load()

        XCTAssertEqual(loaded, PersistedAppState())
    }
}
