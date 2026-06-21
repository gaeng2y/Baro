import Foundation

public enum BodyLandmark: String, Codable, CaseIterable, Sendable {
    case nose
    case leftShoulder
    case rightShoulder
    case leftElbow
    case rightElbow
    case leftWrist
    case rightWrist
    case leftHip
    case rightHip
    case leftKnee
    case rightKnee
    case leftAnkle
    case rightAnkle
}

public struct LandmarkPoint: Equatable, Codable, Sendable {
    public var x: Double
    public var y: Double
    public var z: Double?
    public var confidence: Double

    public init(x: Double, y: Double, z: Double? = nil, confidence: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.confidence = confidence
    }
}

public struct PoseFrame: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var timestamp: TimeInterval
    public var landmarks: [BodyLandmark: LandmarkPoint]
    public var confidence: Double

    public init(
        id: UUID = UUID(),
        timestamp: TimeInterval,
        landmarks: [BodyLandmark: LandmarkPoint],
        confidence: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.landmarks = landmarks
        self.confidence = confidence
    }
}

public struct PoseSequence: Equatable, Codable, Sendable {
    public var frames: [PoseFrame]

    public init(frames: [PoseFrame]) {
        self.frames = frames
    }

    public var duration: TimeInterval {
        guard let first = frames.first?.timestamp, let last = frames.last?.timestamp else {
            return 0
        }
        return max(0, last - first)
    }
}
