import Foundation
import TennisDomain

public struct SessionPipeline: Sendable {
    public var camera: CameraClient
    public var poseEstimator: PoseEstimationClient
    public var coachingEngine: CoachingEngineClient
    public var audioFeedback: AudioFeedbackClient

    public init(
        camera: CameraClient,
        poseEstimator: PoseEstimationClient,
        coachingEngine: CoachingEngineClient,
        audioFeedback: AudioFeedbackClient
    ) {
        self.camera = camera
        self.poseEstimator = poseEstimator
        self.coachingEngine = coachingEngine
        self.audioFeedback = audioFeedback
    }

    public static let preview = SessionPipeline(
        camera: .preview,
        poseEstimator: .preview,
        coachingEngine: .ruleBased,
        audioFeedback: .preview
    )

    @MainActor
    public static func live() -> SessionPipeline {
        SessionPipeline(
            camera: .live(),
            poseEstimator: .vision,
            coachingEngine: .ruleBased,
            audioFeedback: .live()
        )
    }

    public func coachingEvents(strokeType: StrokeType) -> AsyncStream<CoachingEvent> {
        AsyncStream(bufferingPolicy: .bufferingNewest(12)) { continuation in
            let task = Task {
                let hasAccess = await camera.requestAccess()
                guard hasAccess else {
                    continuation.yield(.bodyDetected(false))
                    continuation.yield(.cameraQualityChanged(.bodyOutOfFrame))
                    continuation.finish()
                    return
                }

                var detector = SwingPhaseDetector()
                var cueHistory: [CueHistoryEntry] = []
                var metrics = SessionMetric(swingCount: 0, analyzedCount: 0)

                for await cameraFrame in camera.frames() {
                    guard !Task.isCancelled else { break }

                    guard let poseFrame = try? await poseEstimator.estimate(cameraFrame) else {
                        continuation.yield(.bodyDetected(false))
                        continuation.yield(.cameraQualityChanged(.lowConfidence))
                        continue
                    }

                    continuation.yield(.bodyDetected(true))
                    continuation.yield(.cameraQualityChanged(cameraQuality(for: poseFrame)))

                    guard let detectionEvent = detector.ingest(poseFrame) else {
                        continue
                    }

                    switch detectionEvent {
                    case .started:
                        continuation.yield(.strokeStarted(strokeType))

                    case let .finished(sequence):
                        metrics.swingCount += 1
                        guard let result = await coachingEngine.analyzeSwing(strokeType, sequence) else {
                            continuation.yield(.sessionMetricUpdated(metrics))
                            continue
                        }

                        metrics.analyzedCount += 1
                        continuation.yield(.strokeFinished(result))
                        continuation.yield(.sessionMetricUpdated(metrics))

                        if let cue = await coachingEngine.selectCue(result.detectedErrors, cueHistory) {
                            continuation.yield(.cueSelected(cue))
                            try? await audioFeedback.play(cue)
                            cueHistory.append(CueHistoryEntry(cueID: cue.id, playedAt: Date()))
                        }
                    }
                }

                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
                Task { await camera.stop() }
            }
        }
    }

    private func cameraQuality(for frame: PoseFrame) -> CameraQuality {
        guard frame.confidence >= 0.45 else {
            return .lowConfidence
        }

        let requiredLandmarks: [BodyLandmark] = [
            .leftShoulder,
            .rightShoulder,
            .leftHip,
            .rightHip,
            .leftWrist,
            .rightWrist
        ]
        let points = requiredLandmarks.compactMap { frame.landmarks[$0] }
        guard points.count >= 4 else {
            return .bodyOutOfFrame
        }

        let isNearEdge = points.contains { point in
            point.x < 0.04 || point.x > 0.96 || point.y < 0.04 || point.y > 0.96
        }
        return isNearEdge ? .bodyOutOfFrame : .ready
    }
}
