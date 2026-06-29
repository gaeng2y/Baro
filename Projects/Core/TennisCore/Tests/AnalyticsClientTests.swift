import XCTest
@testable import TennisCore
import TennisDomain

final class AnalyticsClientTests: XCTestCase {
    func testOnboardingCompletedEventUsesStableProfileValues() {
        let profile = UserProfile(
            handedness: .left,
            backhandType: .twoHanded,
            feedbackFrequency: .high
        )

        let event = AnalyticsEvent.onboardingCompleted(profile: profile)

        XCTAssertEqual(event.name, "onboarding_completed")
        XCTAssertEqual(event.parameters["handedness"], .string("left"))
        XCTAssertEqual(event.parameters["backhand_type"], .string("twoHanded"))
        XCTAssertEqual(event.parameters["feedback_frequency"], .string("high"))
    }

    func testSessionFinishedEventUsesCoarseSessionMetrics() {
        let startedAt = Date(timeIntervalSinceReferenceDate: 10)
        let endedAt = Date(timeIntervalSinceReferenceDate: 22)
        let session = TrainingSession(
            strokeType: .forehand,
            cameraMode: .side,
            startedAt: startedAt,
            endedAt: endedAt,
            swingEvents: [
                SwingEvent(
                    strokeType: .forehand,
                    startedAt: 10,
                    endedAt: 11,
                    quality: .success
                )
            ],
            summary: SessionSummary(
                totalSwingCount: 1,
                analyzedSwingCount: 1,
                failedSwingCount: 0,
                repeatedErrors: [],
                recommendedFocus: nil
            )
        )

        let event = AnalyticsEvent.sessionFinished(session)

        XCTAssertEqual(event.name, "session_finished")
        XCTAssertEqual(event.parameters["stroke_type"], .string("forehand"))
        XCTAssertEqual(event.parameters["camera_mode"], .string("side"))
        XCTAssertEqual(event.parameters["swing_count"], .int(1))
        XCTAssertEqual(event.parameters["analyzed_swing_count"], .int(1))
        XCTAssertEqual(event.parameters["failed_swing_count"], .int(0))
        XCTAssertEqual(event.parameters["duration_seconds"], .double(12))
    }
}
