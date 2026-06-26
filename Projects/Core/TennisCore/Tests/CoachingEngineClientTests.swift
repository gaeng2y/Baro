import XCTest
@testable import TennisCore
import TennisDomain

final class CoachingEngineClientTests: XCTestCase {
    func testRuleBasedEngineReturnsNilForTooFewFrames() async {
        let result = await CoachingEngineClient.ruleBased.analyzeSwing(
            .forehand,
            PoseSequence(frames: [poseFrame(timestamp: 0, wristX: 0.2)])
        )

        XCTAssertNil(result)
    }

    func testRuleBasedEngineExtractsMetricsAndErrors() async throws {
        let analysis = await CoachingEngineClient.ruleBased.analyzeSwing(
            .forehand,
            PoseSequence(
                frames: [
                    poseFrame(timestamp: 0, wristX: 0.6, wristY: 0.5),
                    poseFrame(timestamp: 0.2, wristX: 0.45, wristY: 0.55),
                    poseFrame(timestamp: 0.5, wristX: 0.28, wristY: 0.8)
                ]
            )
        )
        let result = try XCTUnwrap(analysis)

        XCTAssertEqual(result.strokeType, .forehand)
        XCTAssertGreaterThan(result.metrics.swingDuration, 0)
        XCTAssertTrue(result.detectedErrors.contains { $0.type == .lateContact })
    }

    func testRuleBasedCueSelectionUsesCuePolicy() async {
        let cue = CoachingCueCatalog.cue(id: "fh-contact-front")
        let selected = await CoachingEngineClient.ruleBased.selectCue(
            [
                DetectedError(type: .lateContact, severity: 0.9, cue: cue, phase: .contact)
            ],
            []
        )

        XCTAssertEqual(selected, cue)
    }

    private func poseFrame(timestamp: TimeInterval, wristX: Double, wristY: Double = 0.5) -> PoseFrame {
        PoseFrame(
            timestamp: timestamp,
            landmarks: [
                .rightWrist: LandmarkPoint(x: wristX, y: wristY, confidence: 0.95),
                .leftShoulder: LandmarkPoint(x: 0.42, y: 0.3, confidence: 0.95),
                .rightShoulder: LandmarkPoint(x: 0.58, y: 0.3, confidence: 0.95),
                .leftHip: LandmarkPoint(x: 0.44, y: 0.58, confidence: 0.95),
                .rightHip: LandmarkPoint(x: 0.56, y: 0.58, confidence: 0.95)
            ],
            confidence: 0.95
        )
    }
}
