import XCTest
@testable import TennisDomain

final class PoseModelsTests: XCTestCase {
    func testPoseSequenceDurationUsesFirstAndLastFrame() {
        let sequence = PoseSequence(
            frames: [
                poseFrame(timestamp: 1.2),
                poseFrame(timestamp: 1.8),
                poseFrame(timestamp: 2.7)
            ]
        )

        XCTAssertEqual(sequence.duration, 1.5, accuracy: 0.0001)
    }

    func testEmptyPoseSequenceDurationIsZero() {
        XCTAssertEqual(PoseSequence(frames: []).duration, 0)
    }

    private func poseFrame(timestamp: TimeInterval) -> PoseFrame {
        PoseFrame(
            timestamp: timestamp,
            landmarks: [
                .rightWrist: LandmarkPoint(x: 0.5, y: 0.5, confidence: 0.95)
            ],
            confidence: 0.95
        )
    }
}
