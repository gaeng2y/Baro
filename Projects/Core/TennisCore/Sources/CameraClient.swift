@preconcurrency import AVFoundation
@preconcurrency import CoreMedia
import Foundation
import TennisDomain

public struct CameraFrame: Equatable, @unchecked Sendable {
    public var timestamp: TimeInterval
    public var sampleBuffer: CMSampleBuffer?

    public init(timestamp: TimeInterval, sampleBuffer: CMSampleBuffer? = nil) {
        self.timestamp = timestamp
        self.sampleBuffer = sampleBuffer
    }

    public static func == (lhs: CameraFrame, rhs: CameraFrame) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}

public struct CameraClient: Sendable {
    public var requestAccess: @Sendable () async -> Bool
    public var frames: @Sendable () -> AsyncStream<CameraFrame>
    public var stop: @Sendable () async -> Void
    public var captureSession: @MainActor @Sendable () -> AVCaptureSession?

    public init(
        requestAccess: @escaping @Sendable () async -> Bool,
        frames: @escaping @Sendable () -> AsyncStream<CameraFrame>,
        stop: @escaping @Sendable () async -> Void,
        captureSession: @escaping @MainActor @Sendable () -> AVCaptureSession? = { nil }
    ) {
        self.requestAccess = requestAccess
        self.frames = frames
        self.stop = stop
        self.captureSession = captureSession
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

    @MainActor
    static func live() -> CameraClient {
        let controller = LiveCameraController()
        return CameraClient(
            requestAccess: {
                await controller.requestAccess()
            },
            frames: {
                controller.frames()
            },
            stop: {
                await controller.stop()
            },
            captureSession: {
                controller.session
            }
        )
    }
}

final class LiveCameraController: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "co.gaeng2y.tenniscoach.camera.session")
    private let outputQueue = DispatchQueue(label: "co.gaeng2y.tenniscoach.camera.output")
    private let output = AVCaptureVideoDataOutput()
    private let continuationLock = NSLock()
    private var continuation: AsyncStream<CameraFrame>.Continuation?
    private var isConfigured = false

    func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func frames() -> AsyncStream<CameraFrame> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.setContinuation(continuation)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stop() }
            }
            self.configureAndStart()
        }
    }

    func stop() async {
        finishContinuation()
        sessionQueue.async { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.isConfigured {
                self.configureSession()
            }
            if self.isConfigured, !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        defer { session.commitConfiguration() }

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            isConfigured = false
            return
        }

        session.addInput(input)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: outputQueue)

        guard session.canAddOutput(output) else {
            isConfigured = false
            return
        }

        session.addOutput(output)
        let portraitAngle: CGFloat = 90
        if output.connection(with: .video)?.isVideoRotationAngleSupported(portraitAngle) == true {
            output.connection(with: .video)?.videoRotationAngle = portraitAngle
        }
        isConfigured = true
    }

    private func setContinuation(_ continuation: AsyncStream<CameraFrame>.Continuation) {
        continuationLock.lock()
        self.continuation = continuation
        continuationLock.unlock()
    }

    private func finishContinuation() {
        continuationLock.lock()
        let current = continuation
        continuation = nil
        continuationLock.unlock()
        current?.finish()
    }

    private func yield(_ frame: CameraFrame) {
        continuationLock.lock()
        let current = continuation
        continuationLock.unlock()
        current?.yield(frame)
    }
}

extension LiveCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        yield(CameraFrame(timestamp: timestamp, sampleBuffer: sampleBuffer))
    }
}
