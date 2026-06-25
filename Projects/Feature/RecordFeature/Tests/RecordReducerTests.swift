import XCTest
@testable import RecordFeature
import TennisDomain

final class RecordReducerTests: XCTestCase {
    func testStrokeFinishedAddsAnalyzedSwingEvent() {
        var state = RecordState(strokeType: .forehand, cameraMode: .side)
        let reducer = RecordReducer()
        let cue = CoachingCueCatalog.cue(id: "fh-contact-front")
        let result = SwingAnalysisResult(
            strokeType: .forehand,
            detectedErrors: [
                DetectedError(type: .lateContact, severity: 0.8, cue: cue, phase: .contact)
            ],
            primaryError: DetectedError(type: .lateContact, severity: 0.8, cue: cue, phase: .contact),
            metrics: SwingMetrics(swingDuration: 0.8)
        )

        reducer.reduce(state: &state, action: .coachingEvent(.strokeStarted(.forehand)))
        reducer.reduce(state: &state, action: .coachingEvent(.strokeFinished(result)))

        XCTAssertFalse(state.isSwinging)
        XCTAssertEqual(state.swingCount, 1)
        XCTAssertEqual(state.analyzedCount, 1)
        XCTAssertEqual(state.swingEvents.count, 1)
        XCTAssertEqual(state.swingEvents.first?.analysisResult, result)
        XCTAssertEqual(state.swingEvents.first?.selectedCue, cue)
    }

    func testCueSelectedUpdatesLatestCueAndLastEvent() {
        var state = RecordState(strokeType: .forehand, cameraMode: .side)
        let reducer = RecordReducer()
        let cue = CoachingCueCatalog.cue(id: "fh-follow-high")
        let result = SwingAnalysisResult(
            strokeType: .forehand,
            detectedErrors: [],
            primaryError: nil,
            metrics: SwingMetrics(swingDuration: 0.8)
        )

        reducer.reduce(state: &state, action: .coachingEvent(.strokeFinished(result)))
        reducer.reduce(state: &state, action: .coachingEvent(.cueSelected(cue)))

        XCTAssertEqual(state.latestCue, cue)
        XCTAssertEqual(state.swingEvents.first?.selectedCue, cue)
    }

    func testSessionMetricNeverMovesCountsBackward() {
        var state = RecordState(strokeType: .forehand, cameraMode: .side)
        let reducer = RecordReducer()

        reducer.reduce(
            state: &state,
            action: .coachingEvent(.sessionMetricUpdated(SessionMetric(swingCount: 4, analyzedCount: 3)))
        )
        reducer.reduce(
            state: &state,
            action: .coachingEvent(.sessionMetricUpdated(SessionMetric(swingCount: 2, analyzedCount: 1)))
        )

        XCTAssertEqual(state.swingCount, 4)
        XCTAssertEqual(state.analyzedCount, 3)
    }

    func testStopSessionDisablesRecording() {
        var state = RecordState(strokeType: .forehand, cameraMode: .side)
        let reducer = RecordReducer()

        reducer.reduce(state: &state, action: .stopSession)

        XCTAssertFalse(state.isRecording)
    }
}
