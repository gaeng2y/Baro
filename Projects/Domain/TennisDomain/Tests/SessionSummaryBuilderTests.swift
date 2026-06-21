import XCTest
@testable import TennisDomain

final class SessionSummaryBuilderTests: XCTestCase {
    func testBuildsRepeatedErrorSummary() {
        let cue = CoachingCueCatalog.cue(id: "fh-contact-front")
        let result = SwingAnalysisResult(
            strokeType: .forehand,
            detectedErrors: [
                DetectedError(type: .lateContact, severity: 0.8, cue: cue, phase: .contact)
            ],
            primaryError: nil,
            metrics: SwingMetrics()
        )
        let summary = SessionSummaryBuilder.build(
            from: [
                SwingEvent(strokeType: .forehand, startedAt: 0, endedAt: 1, analysisResult: result, selectedCue: cue, quality: .success),
                SwingEvent(strokeType: .forehand, startedAt: 2, endedAt: 3, analysisResult: nil, selectedCue: nil, quality: .lowConfidence)
            ]
        )

        XCTAssertEqual(summary.totalSwingCount, 2)
        XCTAssertEqual(summary.analyzedSwingCount, 1)
        XCTAssertEqual(summary.failedSwingCount, 1)
        XCTAssertEqual(summary.recommendedFocus?.id, "fh-contact-front")
    }
}
