import Foundation

public struct CueSelectionPolicy: Sendable {
    public var severityThreshold: Double
    public var cooldown: TimeInterval

    public init(severityThreshold: Double = 0.25, cooldown: TimeInterval = 12) {
        self.severityThreshold = severityThreshold
        self.cooldown = cooldown
    }

    public func selectCue(
        from errors: [DetectedError],
        recentCueHistory: [CueHistoryEntry],
        now: Date = Date()
    ) -> CoachingCue? {
        errors
            .filter { $0.severity >= severityThreshold }
            .filter { error in
                !recentCueHistory.contains { entry in
                    entry.cueID == error.cue.id && now.timeIntervalSince(entry.playedAt) < cooldown
                }
            }
            .sorted { lhs, rhs in
                if lhs.severity == rhs.severity {
                    return lhs.cue.priority > rhs.cue.priority
                }
                return lhs.severity > rhs.severity
            }
            .first?
            .cue
    }
}

public struct CueHistoryEntry: Equatable, Codable, Sendable {
    public var cueID: String
    public var playedAt: Date

    public init(cueID: String, playedAt: Date) {
        self.cueID = cueID
        self.playedAt = playedAt
    }
}
