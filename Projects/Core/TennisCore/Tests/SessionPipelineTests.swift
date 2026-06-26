import XCTest
@testable import TennisCore
import TennisDomain

final class SessionPipelineTests: XCTestCase {
    func testPipelineEmitsCoachingEventsFromCameraFrames() async {
        let poseFrames = [
            poseFrame(timestamp: 0.0, wristX: 0.1),
            poseFrame(timestamp: 0.1, wristX: 0.32),
            poseFrame(timestamp: 0.2, wristX: 0.32),
            poseFrame(timestamp: 0.3, wristX: 0.32),
            poseFrame(timestamp: 0.4, wristX: 0.32),
            poseFrame(timestamp: 0.5, wristX: 0.32),
            poseFrame(timestamp: 0.6, wristX: 0.32),
            poseFrame(timestamp: 0.7, wristX: 0.32)
        ]
        let frameByTimestamp = Dictionary(uniqueKeysWithValues: poseFrames.map { ($0.timestamp, $0) })
        let cue = CoachingCueCatalog.cue(id: "fh-contact-front")
        let pipeline = SessionPipeline(
            camera: CameraClient(
                requestAccess: { true },
                frames: {
                    AsyncStream { continuation in
                        for frame in poseFrames {
                            continuation.yield(CameraFrame(timestamp: frame.timestamp))
                        }
                        continuation.finish()
                    }
                },
                stop: {}
            ),
            poseEstimator: PoseEstimationClient { cameraFrame in
                frameByTimestamp[cameraFrame.timestamp]
            },
            coachingEngine: CoachingEngineClient(
                analyzeSwing: { strokeType, sequence in
                    SwingAnalysisResult(
                        strokeType: strokeType,
                        detectedErrors: [
                            DetectedError(type: .lateContact, severity: 0.9, cue: cue, phase: .contact)
                        ],
                        primaryError: DetectedError(type: .lateContact, severity: 0.9, cue: cue, phase: .contact),
                        metrics: SwingMetrics(swingDuration: sequence.duration)
                    )
                },
                selectCue: { _, _ in cue }
            ),
            audioFeedback: AudioFeedbackClient { _ in }
        )

        var events: [CoachingEvent] = []
        for await event in pipeline.coachingEvents(strokeType: .forehand) {
            events.append(event)
        }

        XCTAssertTrue(events.contains(.bodyDetected(true)), "\(events)")
        XCTAssertTrue(events.contains(.cameraQualityChanged(.ready)), "\(events)")
        XCTAssertTrue(events.contains(.strokeStarted(.forehand)), "\(events)")
        XCTAssertTrue(events.contains { event in
            if case .strokeFinished = event {
                return true
            }
            return false
        }, "\(events)")
        XCTAssertTrue(events.contains(.cueSelected(cue)), "\(events)")
    }

    func testPipelineFinishesWhenCameraAccessIsDenied() async {
        let pipeline = SessionPipeline(
            camera: CameraClient(
                requestAccess: { false },
                frames: { AsyncStream { $0.finish() } },
                stop: {}
            ),
            poseEstimator: PoseEstimationClient { _ in nil },
            coachingEngine: .ruleBased,
            audioFeedback: .preview
        )

        var events: [CoachingEvent] = []
        for await event in pipeline.coachingEvents(strokeType: .forehand) {
            events.append(event)
        }

        XCTAssertEqual(events, [.bodyDetected(false), .cameraQualityChanged(.bodyOutOfFrame)])
    }

    private func poseFrame(timestamp: TimeInterval, wristX: Double) -> PoseFrame {
        PoseFrame(
            timestamp: timestamp,
            landmarks: [
                .rightWrist: LandmarkPoint(x: wristX, y: 0.5, confidence: 0.95),
                .leftShoulder: LandmarkPoint(x: 0.42, y: 0.3, confidence: 0.95),
                .rightShoulder: LandmarkPoint(x: 0.58, y: 0.3, confidence: 0.95),
                .leftHip: LandmarkPoint(x: 0.44, y: 0.58, confidence: 0.95),
                .rightHip: LandmarkPoint(x: 0.56, y: 0.58, confidence: 0.95)
            ],
            confidence: 0.95
        )
    }
}
