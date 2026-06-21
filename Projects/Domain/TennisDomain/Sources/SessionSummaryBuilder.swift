import Foundation

public enum SessionSummaryBuilder {
    public static func build(from events: [SwingEvent]) -> SessionSummary {
        let analyzed = events.filter { $0.analysisResult != nil }
        let errors = analyzed.flatMap { $0.analysisResult?.detectedErrors ?? [] }
        let grouped = Dictionary(grouping: errors, by: \.type)
        let ranked = grouped
            .map { type, errors in
                ErrorCount(type: type, count: errors.count, cue: errors.first?.cue ?? CoachingCueCatalog.common[0])
            }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.cue.priority > rhs.cue.priority
                }
                return lhs.count > rhs.count
            }

        return SessionSummary(
            totalSwingCount: events.count,
            analyzedSwingCount: analyzed.count,
            failedSwingCount: events.count - analyzed.count,
            repeatedErrors: Array(ranked.prefix(3)),
            recommendedFocus: ranked.first?.cue
        )
    }
}
