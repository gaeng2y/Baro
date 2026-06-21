import Foundation
import TennisDomain

public struct CameraFrame: Equatable, Sendable {
    public var timestamp: TimeInterval

    public init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }
}

public struct CameraClient: Sendable {
    public var requestAccess: @Sendable () async -> Bool
    public var frames: @Sendable () -> AsyncStream<CameraFrame>
    public var stop: @Sendable () async -> Void

    public init(
        requestAccess: @escaping @Sendable () async -> Bool,
        frames: @escaping @Sendable () -> AsyncStream<CameraFrame>,
        stop: @escaping @Sendable () async -> Void
    ) {
        self.requestAccess = requestAccess
        self.frames = frames
        self.stop = stop
    }
}

public extension CameraClient {
    static let preview = CameraClient(
        requestAccess: { true },
        frames: {
            AsyncStream { continuation in
                continuation.finish()
            }
        },
        stop: {}
    )
}
