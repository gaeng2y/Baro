import Foundation
import TennisDomain

public struct LocalSessionStoreClient: Sendable {
    public var load: @Sendable () async throws -> [TrainingSession]
    public var save: @Sendable ([TrainingSession]) async throws -> Void
    public var deleteAll: @Sendable () async throws -> Void

    public init(
        load: @escaping @Sendable () async throws -> [TrainingSession],
        save: @escaping @Sendable ([TrainingSession]) async throws -> Void,
        deleteAll: @escaping @Sendable () async throws -> Void
    ) {
        self.load = load
        self.save = save
        self.deleteAll = deleteAll
    }
}

public extension LocalSessionStoreClient {
    static func live(fileName: String = "tenniscoach-sessions.json") -> LocalSessionStoreClient {
        let store = JSONSessionStore(fileName: fileName)
        return LocalSessionStoreClient(
            load: { try await store.load() },
            save: { try await store.save($0) },
            deleteAll: { try await store.deleteAll() }
        )
    }

    static let preview = LocalSessionStoreClient(
        load: { [] },
        save: { _ in },
        deleteAll: {}
    )
}

actor JSONSessionStore {
    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func load() throws -> [TrainingSession] {
        let url = try fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([TrainingSession].self, from: data)
    }

    func save(_ sessions: [TrainingSession]) throws {
        let url = try fileURL()
        let data = try JSONEncoder().encode(sessions)
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
