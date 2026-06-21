import Foundation
import TennisDomain

public struct CoachingEngineClient: Sendable {
    public var analyzeSwing: @Sendable (StrokeType, PoseSequence) async -> SwingAnalysisResult?
    public var selectCue: @Sendable ([DetectedError], [CueHistoryEntry]) async -> CoachingCue?

    public init(
        analyzeSwing: @escaping @Sendable (StrokeType, PoseSequence) async -> SwingAnalysisResult?,
        selectCue: @escaping @Sendable ([DetectedError], [CueHistoryEntry]) async -> CoachingCue?
    ) {
        self.analyzeSwing = analyzeSwing
        self.selectCue = selectCue
    }
}

public extension CoachingEngineClient {
    static let ruleBased = CoachingEngineClient(
        analyzeSwing: { strokeType, sequence in
            guard sequence.frames.count >= 3 else {
                return nil
            }
            let metrics = SwingMetricExtractor.extract(from: sequence)
            let errors: [DetectedError]
            switch strokeType {
            case .forehand:
                errors = ForehandRuleSet().analyze(metrics: metrics)
            case .twoHandBackhand:
                errors = BackhandRuleSet().analyze(metrics: metrics)
            }

            return SwingAnalysisResult(
                strokeType: strokeType,
                detectedErrors: errors,
                primaryError: errors.sorted { $0.severity > $1.severity }.first,
                metrics: metrics
            )
        },
        selectCue: { errors, history in
            CueSelectionPolicy().selectCue(from: errors, recentCueHistory: history)
        }
    )
}

enum SwingMetricExtractor {
    static func extract(from sequence: PoseSequence) -> SwingMetrics {
        let frameCount = max(sequence.frames.count, 1)
        let wristTravel = wristTravel(in: sequence)
        return SwingMetrics(
            shoulderLineAngle: 0,
            hipLineAngle: 0,
            shoulderTurnRange: min(60, wristTravel * 120),
            hipTurnRange: min(35, wristTravel * 70),
            shoulderHipSeparation: min(30, wristTravel * 45),
            wristVelocity: wristTravel / max(sequence.duration, 0.001),
            wristHeight: sequence.frames.last?.landmarks[.rightWrist]?.y ?? 0,
            wristRelativeX: (sequence.frames.last?.landmarks[.rightWrist]?.x ?? 0.5) - 0.5,
            elbowAngle: 90,
            kneeFlexion: 0.22,
            bodyBalance: 0.5,
            followThroughHeight: 1 - (sequence.frames.last?.landmarks[.rightWrist]?.y ?? 0.5),
            swingDuration: sequence.duration
        )
    }

    private static func wristTravel(in sequence: PoseSequence) -> Double {
        let points = sequence.frames.compactMap { $0.landmarks[.rightWrist] }
        guard points.count > 1 else { return 0 }
        return zip(points, points.dropFirst()).reduce(0) { total, pair in
            let dx = pair.1.x - pair.0.x
            let dy = pair.1.y - pair.0.y
            return total + sqrt(dx * dx + dy * dy)
        } / Double(points.count)
    }
}
