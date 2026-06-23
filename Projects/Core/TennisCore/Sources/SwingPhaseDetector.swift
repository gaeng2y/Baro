import Foundation
import TennisDomain

enum SwingDetectionEvent: Equatable {
    case started
    case finished(PoseSequence)
}

struct SwingPhaseDetector {
    private enum DetectorState {
        case idle
        case swinging(frames: [PoseFrame], quietFrameCount: Int)
    }

    private let startVelocityThreshold = 0.85
    private let endVelocityThreshold = 0.2
    private let minimumDuration: TimeInterval = 0.35
    private let maximumDuration: TimeInterval = 2.4
    private let minimumFrameCount = 8
    private let quietFrameLimit = 6

    private var state: DetectorState = .idle
    private var previousFrame: PoseFrame?

    mutating func ingest(_ frame: PoseFrame) -> SwingDetectionEvent? {
        let velocity = wristVelocity(from: previousFrame, to: frame)
        defer { previousFrame = frame }

        switch state {
        case .idle:
            guard velocity >= startVelocityThreshold else {
                return nil
            }
            let frames = [previousFrame, frame].compactMap { $0 }
            state = .swinging(frames: frames, quietFrameCount: 0)
            return .started

        case let .swinging(existingFrames, quietFrameCount):
            var frames = existingFrames
            frames.append(frame)

            let nextQuietFrameCount = velocity <= endVelocityThreshold ? quietFrameCount + 1 : 0
            let sequence = PoseSequence(frames: frames)
            let shouldFinish =
                (sequence.duration >= minimumDuration && nextQuietFrameCount >= quietFrameLimit)
                || sequence.duration >= maximumDuration

            guard shouldFinish else {
                state = .swinging(frames: frames, quietFrameCount: nextQuietFrameCount)
                return nil
            }

            state = .idle
            guard sequence.frames.count >= minimumFrameCount, sequence.duration >= minimumDuration else {
                return nil
            }
            return .finished(sequence)
        }
    }

    private func wristVelocity(from previous: PoseFrame?, to current: PoseFrame) -> Double {
        guard
            let previous,
            let previousPoint = trackingWrist(in: previous),
            let currentPoint = trackingWrist(in: current)
        else {
            return 0
        }

        let dt = max(current.timestamp - previous.timestamp, 0.001)
        let dx = currentPoint.x - previousPoint.x
        let dy = currentPoint.y - previousPoint.y
        return sqrt(dx * dx + dy * dy) / dt
    }

    private func trackingWrist(in frame: PoseFrame) -> LandmarkPoint? {
        let right = frame.landmarks[.rightWrist]
        let left = frame.landmarks[.leftWrist]

        switch (right, left) {
        case let (right?, left?):
            return right.confidence >= left.confidence ? right : left
        case let (right?, nil):
            return right
        case let (nil, left?):
            return left
        case (nil, nil):
            return nil
        }
    }
}
