import ComposableArchitecture
import XCTest
@testable import RecordFeature
import TennisDomain

@MainActor
final class RecordReducerTests: XCTestCase {
    func testStrokeFinishedAddsAnalyzedSwingEvent() async {
        let now = Date(timeIntervalSinceReferenceDate: 10)
        let eventID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let store = TestStore(initialState: RecordState(strokeType: .forehand, cameraMode: .side)) {
            RecordReducer(now: { now }, makeID: { eventID })
        }
        let cue = CoachingCueCatalog.cue(id: "fh-contact-front")
        let result = SwingAnalysisResult(
            strokeType: .forehand,
            detectedErrors: [
                DetectedError(type: .lateContact, severity: 0.8, cue: cue, phase: .contact)
            ],
            primaryError: DetectedError(type: .lateContact, severity: 0.8, cue: cue, phase: .contact),
            metrics: SwingMetrics(swingDuration: 0.8)
        )
        let event = SwingEvent(
            id: eventID,
            strokeType: .forehand,
            startedAt: 9.2,
            endedAt: 10,
            analysisResult: result,
            selectedCue: cue,
            quality: .success
        )

        await store.send(.coachingEvent(.strokeStarted(.forehand))) {
            $0.isSwinging = true
        }

        await store.send(.coachingEvent(.strokeFinished(result))) {
            $0.isSwinging = false
            $0.swingCount = 1
            $0.analyzedCount = 1
            $0.swingEvents = [event]
        }
    }

    func testCueSelectedUpdatesLatestCueAndLastEvent() async {
        let now = Date(timeIntervalSinceReferenceDate: 10)
        let eventID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let store = TestStore(initialState: RecordState(strokeType: .forehand, cameraMode: .side)) {
            RecordReducer(now: { now }, makeID: { eventID })
        }
        let cue = CoachingCueCatalog.cue(id: "fh-follow-high")
        let result = SwingAnalysisResult(
            strokeType: .forehand,
            detectedErrors: [],
            primaryError: nil,
            metrics: SwingMetrics(swingDuration: 0.8)
        )
        var event = SwingEvent(
            id: eventID,
            strokeType: .forehand,
            startedAt: 9.2,
            endedAt: 10,
            analysisResult: result,
            selectedCue: nil,
            quality: .success
        )

        await store.send(.coachingEvent(.strokeFinished(result))) {
            $0.swingCount = 1
            $0.analyzedCount = 1
            $0.swingEvents = [event]
        }

        event.selectedCue = cue
        await store.send(.coachingEvent(.cueSelected(cue))) {
            $0.latestCue = cue
            $0.swingEvents = [event]
        }
    }

    func testSessionMetricNeverMovesCountsBackward() async {
        let store = TestStore(initialState: RecordState(strokeType: .forehand, cameraMode: .side)) {
            RecordReducer()
        }

        await store.send(.coachingEvent(.sessionMetricUpdated(SessionMetric(swingCount: 4, analyzedCount: 3)))) {
            $0.swingCount = 4
            $0.analyzedCount = 3
        }

        await store.send(.coachingEvent(.sessionMetricUpdated(SessionMetric(swingCount: 2, analyzedCount: 1))))
    }

    func testStopSessionDisablesRecordingAndBuildsSession() async {
        let startedAt = Date(timeIntervalSinceReferenceDate: 3)
        let endedAt = Date(timeIntervalSinceReferenceDate: 12)
        let sessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let store = TestStore(
            initialState: RecordState(strokeType: .forehand, cameraMode: .side, startedAt: startedAt)
        ) {
            RecordReducer(now: { endedAt }, makeID: { sessionID })
        }

        await store.send(.stopSession) {
            $0.isRecording = false
            $0.finishedSession = TrainingSession(
                id: sessionID,
                strokeType: .forehand,
                cameraMode: .side,
                startedAt: startedAt,
                endedAt: endedAt,
                swingEvents: [],
                summary: SessionSummaryBuilder.build(from: [])
            )
        }
    }
}
