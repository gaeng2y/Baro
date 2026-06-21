import AVFoundation
import Foundation

public struct PermissionClient: Sendable {
    public var cameraAuthorizationStatus: @Sendable () -> AVAuthorizationStatus
    public var requestCameraAccess: @Sendable () async -> Bool

    public init(
        cameraAuthorizationStatus: @escaping @Sendable () -> AVAuthorizationStatus,
        requestCameraAccess: @escaping @Sendable () async -> Bool
    ) {
        self.cameraAuthorizationStatus = cameraAuthorizationStatus
        self.requestCameraAccess = requestCameraAccess
    }
}

public extension PermissionClient {
    static let live = PermissionClient(
        cameraAuthorizationStatus: {
            AVCaptureDevice.authorizationStatus(for: .video)
        },
        requestCameraAccess: {
            await AVCaptureDevice.requestAccess(for: .video)
        }
    )
}
