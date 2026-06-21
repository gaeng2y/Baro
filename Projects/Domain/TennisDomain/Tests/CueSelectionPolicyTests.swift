import XCTest
@testable import TennisDomain

final class CueSelectionPolicyTests: XCTestCase {
    func testSelectsHighestSeverityCue() {
        let policy = CueSelectionPolicy(severityThreshold: 0.2, cooldown: 10)
        let selected = policy.selectCue(
            from: [
                DetectedError(
                    type: .poorFollowThrough,
                    severity: 0.4,
                    cue: CoachingCueCatalog.cue(id: "fh-follow-high"),
                    phase: .followThrough
                ),
                DetectedError(
                    type: .lateContact,
                    severity: 0.8,
                    cue: CoachingCueCatalog.cue(id: "fh-contact-front"),
                    phase: .contact
                )
            ],
            recentCueHistory: [],
            now: Date(timeIntervalSince1970: 20)
        )

        XCTAssertEqual(selected?.id, "fh-contact-front")
    }

    func testSuppressesCueDuringCooldown() {
        let now = Date(timeIntervalSince1970: 20)
        let policy = CueSelectionPolicy(severityThreshold: 0.2, cooldown: 30)
        let selected = policy.selectCue(
            from: [
                DetectedError(
                    type: .lateContact,
                    severity: 0.8,
                    cue: CoachingCueCatalog.cue(id: "fh-contact-front"),
                    phase: .contact
                )
            ],
            recentCueHistory: [
                CueHistoryEntry(cueID: "fh-contact-front", playedAt: Date(timeIntervalSince1970: 5))
            ],
            now: now
        )

        XCTAssertNil(selected)
    }
}
