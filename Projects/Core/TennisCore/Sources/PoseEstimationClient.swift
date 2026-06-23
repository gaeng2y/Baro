@preconcurrency import CoreMedia
import Foundation
import ImageIO
import TennisDomain
@preconcurrency import Vision

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

    static let vision = PoseEstimationClient { frame in
        guard let sampleBuffer = frame.sampleBuffer else {
            return nil
        }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .right,
            options: [:]
        )
        try handler.perform([request])

        guard let observation = request.results?.first else {
            return nil
        }

        return observation.poseFrame(timestamp: frame.timestamp)
    }
}

private extension VNHumanBodyPoseObservation {
    func poseFrame(timestamp: TimeInterval) -> PoseFrame? {
        let mappings: [(BodyLandmark, JointName)] = [
            (.nose, .nose),
            (.leftShoulder, .leftShoulder),
            (.rightShoulder, .rightShoulder),
            (.leftElbow, .leftElbow),
            (.rightElbow, .rightElbow),
            (.leftWrist, .leftWrist),
            (.rightWrist, .rightWrist),
            (.leftHip, .leftHip),
            (.rightHip, .rightHip),
            (.leftKnee, .leftKnee),
            (.rightKnee, .rightKnee),
            (.leftAnkle, .leftAnkle),
            (.rightAnkle, .rightAnkle)
        ]

        var landmarks: [BodyLandmark: LandmarkPoint] = [:]
        for (landmark, jointName) in mappings {
            guard
                let point = try? recognizedPoint(jointName),
                point.confidence >= 0.15
            else {
                continue
            }
            landmarks[landmark] = LandmarkPoint(
                x: point.location.x,
                y: 1 - point.location.y,
                confidence: Double(point.confidence)
            )
        }

        guard
            landmarks[.leftShoulder] != nil,
            landmarks[.rightShoulder] != nil,
            landmarks[.leftWrist] != nil || landmarks[.rightWrist] != nil
        else {
            return nil
        }

        let confidence = landmarks.values.reduce(0) { $0 + $1.confidence } / Double(landmarks.count)
        guard confidence >= 0.2 else {
            return nil
        }

        return PoseFrame(
            timestamp: timestamp,
            landmarks: landmarks,
            confidence: confidence
        )
    }
}
