import XCTest
@testable import TennisCore
import TennisDomain

final class SwingPhaseDetectorTests: XCTestCase {
    func testDetectsStartedAndFinishedSwing() {
        var detector = SwingPhaseDetector()
        let frames = [
            poseFrame(timestamp: 0.0, wristX: 0.1),
            poseFrame(timestamp: 0.1, wristX: 0.32),
            poseFrame(timestamp: 0.2, wristX: 0.32),
            poseFrame(timestamp: 0.3, wristX: 0.32),
            poseFrame(timestamp: 0.4, wristX: 0.32),
            poseFrame(timestamp: 0.5, wristX: 0.32),
            poseFrame(timestamp: 0.6, wristX: 0.32),
            poseFrame(timestamp: 0.7, wristX: 0.32)
        ]

        let events = frames.compactMap { detector.ingest($0) }

        XCTAssertEqual(events.first, .started)
        guard case let .finished(sequence) = events.last else {
            return XCTFail("Expected finished event")
        }
        XCTAssertEqual(sequence.frames.count, 8)
        XCTAssertEqual(sequence.duration, 0.7, accuracy: 0.0001)
    }

    func testDoesNotStartWhenWristVelocityIsLow() {
        var detector = SwingPhaseDetector()
        let events = [
            poseFrame(timestamp: 0.0, wristX: 0.1),
            poseFrame(timestamp: 0.1, wristX: 0.11),
            poseFrame(timestamp: 0.2, wristX: 0.12)
        ].compactMap { detector.ingest($0) }

        XCTAssertTrue(events.isEmpty)
    }

    private func poseFrame(timestamp: TimeInterval, wristX: Double) -> PoseFrame {
        PoseFrame(
            timestamp: timestamp,
            landmarks: [
                .rightWrist: LandmarkPoint(x: wristX, y: 0.5, confidence: 0.95)
            ],
            confidence: 0.95
        )
    }
}
