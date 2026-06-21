import Foundation
import TennisDomain

public struct PoseEstimationClient: Sendable {
    public var estimate: @Sendable (CameraFrame) async throws -> PoseFrame?

    public init(
        estimate: @escaping @Sendable (CameraFrame) async throws -> PoseFrame?
    ) {
        self.estimate = estimate
    }
}

public extension PoseEstimationClient {
    static let preview = PoseEstimationClient { frame in
        PoseFrame(
            timestamp: frame.timestamp,
            landmarks: [
                .leftShoulder: LandmarkPoint(x: 0.42, y: 0.32, confidence: 0.95),
                .rightShoulder: LandmarkPoint(x: 0.58, y: 0.32, confidence: 0.95),
                .leftHip: LandmarkPoint(x: 0.44, y: 0.56, confidence: 0.92),
                .rightHip: LandmarkPoint(x: 0.56, y: 0.56, confidence: 0.92),
                .leftWrist: LandmarkPoint(x: 0.36, y: 0.42, confidence: 0.9),
                .rightWrist: LandmarkPoint(x: 0.64, y: 0.42, confidence: 0.9),
                .leftKnee: LandmarkPoint(x: 0.43, y: 0.76, confidence: 0.88),
                .rightKnee: LandmarkPoint(x: 0.57, y: 0.76, confidence: 0.88),
                .leftAnkle: LandmarkPoint(x: 0.42, y: 0.94, confidence: 0.86),
                .rightAnkle: LandmarkPoint(x: 0.58, y: 0.94, confidence: 0.86)
            ],
            confidence: 0.92
        )
    }
}
