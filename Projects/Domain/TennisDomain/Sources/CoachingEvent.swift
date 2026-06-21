import Foundation

public enum CameraQuality: Equatable, Codable, Sendable {
    case ready
    case bodyOutOfFrame
    case lowLight
    case unstable
    case lowConfidence
}

public struct SessionMetric: Equatable, Codable, Sendable {
    public var swingCount: Int
    public var analyzedCount: Int

    public init(swingCount: Int, analyzedCount: Int) {
        self.swingCount = swingCount
        self.analyzedCount = analyzedCount
    }
}

public enum CoachingEvent: Equatable, Sendable {
    case bodyDetected(Bool)
    case cameraQualityChanged(CameraQuality)
    case strokeStarted(StrokeType)
    case strokeFinished(SwingAnalysisResult)
    case cueSelected(CoachingCue)
    case sessionMetricUpdated(SessionMetric)
}
