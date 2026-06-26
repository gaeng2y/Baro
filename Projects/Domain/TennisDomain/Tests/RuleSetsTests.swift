import XCTest
@testable import TennisDomain

final class RuleSetsTests: XCTestCase {
    func testForehandRuleSetReturnsNoErrorsForHealthyMetrics() {
        let errors = ForehandRuleSet().analyze(
            metrics: SwingMetrics(
                shoulderTurnRange: 42,
                hipTurnRange: 24,
                wristRelativeX: 0.16,
                kneeFlexion: 0.24,
                followThroughHeight: 0.7
            )
        )

        XCTAssertTrue(errors.isEmpty)
    }

    func testForehandRuleSetDetectsLateContact() {
        let errors = ForehandRuleSet().analyze(
            metrics: SwingMetrics(
                shoulderTurnRange: 42,
                hipTurnRange: 24,
                wristRelativeX: -0.2,
                kneeFlexion: 0.24,
                followThroughHeight: 0.7
            )
        )

        XCTAssertEqual(errors.map(\.type), [.lateContact])
        XCTAssertEqual(errors.first?.cue.id, "fh-contact-front")
        XCTAssertEqual(errors.first?.phase, .contact)
    }

    func testBackhandRuleSetDetectsSpacingBeforeLateContactWhenBothApply() {
        let errors = BackhandRuleSet().analyze(
            metrics: SwingMetrics(
                shoulderTurnRange: 48,
                hipTurnRange: 26,
                wristRelativeX: -0.1,
                followThroughHeight: 0.68
            )
        )

        XCTAssertEqual(errors.map(\.type), [.poorSpacing, .lateContact])
        XCTAssertEqual(errors.first?.cue.id, "bh-spacing")
    }
}
