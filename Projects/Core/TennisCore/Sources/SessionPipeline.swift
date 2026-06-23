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
            poseEstimator: .preview,
            coachingEngine: .ruleBased,
            audioFeedback: .live()
        )
    }
}
