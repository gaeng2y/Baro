import Foundation
import TennisDomain

public struct PersistedAppState: Equatable, Codable, Sendable {
    public var userProfile: UserProfile?
    public var sessions: [TrainingSession]
    public var saveVideoClips: Bool

    public init(
        userProfile: UserProfile? = nil,
        sessions: [TrainingSession] = [],
        saveVideoClips: Bool = false
    ) {
        self.userProfile = userProfile
        self.sessions = sessions
        self.saveVideoClips = saveVideoClips
    }
}

public struct LocalAppStorageClient: Sendable {
    public var load: @Sendable () async throws -> PersistedAppState
    public var save: @Sendable (PersistedAppState) async throws -> Void
    public var deleteAll: @Sendable () async throws -> Void

    public init(
        load: @escaping @Sendable () async throws -> PersistedAppState,
        save: @escaping @Sendable (PersistedAppState) async throws -> Void,
        deleteAll: @escaping @Sendable () async throws -> Void
    ) {
        self.load = load
        self.save = save
        self.deleteAll = deleteAll
    }
}

public extension LocalAppStorageClient {
    static func live(fileName: String = "tenniscoach-app-state.json") -> LocalAppStorageClient {
        let store = JSONAppStateStore(fileName: fileName)
        return LocalAppStorageClient(
            load: { try await store.load() },
            save: { try await store.save($0) },
            deleteAll: { try await store.deleteAll() }
        )
    }

    static let preview = LocalAppStorageClient(
        load: { PersistedAppState() },
        save: { _ in },
        deleteAll: {}
    )
}

actor JSONAppStateStore {
    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func load() throws -> PersistedAppState {
        let url = try fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return PersistedAppState()
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(PersistedAppState.self, from: data)
    }

    func save(_ state: PersistedAppState) throws {
        let url = try fileURL()
        let data = try JSONEncoder().encode(state)
        try data.write(to: url, options: [.atomic])
    }

    func deleteAll() throws {
        let url = try fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.removeItem(at: url)
    }

    private func fileURL() throws -> URL {
        let directory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return directory.appendingPathComponent(fileName)
    }
}
