import Foundation

public struct TrainingSession: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var strokeType: StrokeType
    public var cameraMode: CameraMode
    public var startedAt: Date
    public var endedAt: Date?
    public var swingEvents: [SwingEvent]
    public var summary: SessionSummary?

    public init(
        id: UUID = UUID(),
        strokeType: StrokeType,
        cameraMode: CameraMode,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        swingEvents: [SwingEvent] = [],
        summary: SessionSummary? = nil
    ) {
        self.id = id
        self.strokeType = strokeType
        self.cameraMode = cameraMode
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.swingEvents = swingEvents
        self.summary = summary
    }
}

public struct SwingEvent: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var strokeType: StrokeType
    public var startedAt: TimeInterval
    public var endedAt: TimeInterval
    public var analysisResult: SwingAnalysisResult?
    public var selectedCue: CoachingCue?
    public var quality: AnalysisQuality

    public init(
        id: UUID = UUID(),
        strokeType: StrokeType,
        startedAt: TimeInterval,
        endedAt: TimeInterval,
        analysisResult: SwingAnalysisResult? = nil,
        selectedCue: CoachingCue? = nil,
        quality: AnalysisQuality
    ) {
        self.id = id
        self.strokeType = strokeType
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.analysisResult = analysisResult
        self.selectedCue = selectedCue
        self.quality = quality
    }
}

public struct SwingAnalysisResult: Equatable, Codable, Sendable {
    public var strokeType: StrokeType
    public var detectedErrors: [DetectedError]
    public var primaryError: DetectedError?
    public var metrics: SwingMetrics
    public var ruleVersion: RuleVersion

    public init(
        strokeType: StrokeType,
        detectedErrors: [DetectedError],
        primaryError: DetectedError?,
        metrics: SwingMetrics,
        ruleVersion: RuleVersion = .v0_1
    ) {
        self.strokeType = strokeType
        self.detectedErrors = detectedErrors
        self.primaryError = primaryError
        self.metrics = metrics
        self.ruleVersion = ruleVersion
    }
}

public struct DetectedError: Equatable, Codable, Identifiable, Sendable {
    public var id: String { "\(type.rawValue)-\(phase?.rawValue ?? "general")" }
    public var type: CoachingErrorType
    public var severity: Double
    public var cue: CoachingCue
    public var phase: SwingPhase?

    public init(
        type: CoachingErrorType,
        severity: Double,
        cue: CoachingCue,
        phase: SwingPhase? = nil
    ) {
        self.type = type
        self.severity = severity
        self.cue = cue
        self.phase = phase
    }
}

public struct CoachingCue: Equatable, Codable, Identifiable, Sendable {
    public var id: String
    public var text: String
    public var audioAssetName: String?
    public var category: CoachingCueCategory
    public var priority: Int

    public init(
        id: String,
        text: String,
        audioAssetName: String? = nil,
        category: CoachingCueCategory,
        priority: Int
    ) {
        self.id = id
        self.text = text
        self.audioAssetName = audioAssetName
        self.category = category
        self.priority = priority
    }
}

public struct SwingMetrics: Equatable, Codable, Sendable {
    public var shoulderLineAngle: Double
    public var hipLineAngle: Double
    public var shoulderTurnRange: Double
    public var hipTurnRange: Double
    public var shoulderHipSeparation: Double
    public var wristVelocity: Double
    public var wristHeight: Double
    public var wristRelativeX: Double
    public var elbowAngle: Double
    public var kneeFlexion: Double
    public var bodyBalance: Double
    public var followThroughHeight: Double
    public var swingDuration: TimeInterval

    public init(
        shoulderLineAngle: Double = 0,
        hipLineAngle: Double = 0,
        shoulderTurnRange: Double = 0,
        hipTurnRange: Double = 0,
        shoulderHipSeparation: Double = 0,
        wristVelocity: Double = 0,
        wristHeight: Double = 0,
        wristRelativeX: Double = 0,
        elbowAngle: Double = 0,
        kneeFlexion: Double = 0,
        bodyBalance: Double = 0,
        followThroughHeight: Double = 0,
        swingDuration: TimeInterval = 0
    ) {
        self.shoulderLineAngle = shoulderLineAngle
        self.hipLineAngle = hipLineAngle
        self.shoulderTurnRange = shoulderTurnRange
        self.hipTurnRange = hipTurnRange
        self.shoulderHipSeparation = shoulderHipSeparation
        self.wristVelocity = wristVelocity
        self.wristHeight = wristHeight
        self.wristRelativeX = wristRelativeX
        self.elbowAngle = elbowAngle
        self.kneeFlexion = kneeFlexion
        self.bodyBalance = bodyBalance
        self.followThroughHeight = followThroughHeight
        self.swingDuration = swingDuration
    }
}

public enum AnalysisQuality: Equatable, Codable, Sendable {
    case success
    case lowConfidence
    case bodyOutOfFrame
    case incompleteSwing
}

public struct SessionSummary: Equatable, Codable, Sendable {
    public var totalSwingCount: Int
    public var analyzedSwingCount: Int
    public var failedSwingCount: Int
    public var repeatedErrors: [ErrorCount]
    public var recommendedFocus: CoachingCue?

    public init(
        totalSwingCount: Int,
        analyzedSwingCount: Int,
        failedSwingCount: Int,
        repeatedErrors: [ErrorCount],
        recommendedFocus: CoachingCue?
    ) {
        self.totalSwingCount = totalSwingCount
        self.analyzedSwingCount = analyzedSwingCount
        self.failedSwingCount = failedSwingCount
        self.repeatedErrors = repeatedErrors
        self.recommendedFocus = recommendedFocus
    }
}

public struct ErrorCount: Equatable, Codable, Identifiable, Sendable {
    public var id: CoachingErrorType { type }
    public var type: CoachingErrorType
    public var count: Int
    public var cue: CoachingCue

    public init(type: CoachingErrorType, count: Int, cue: CoachingCue) {
        self.type = type
        self.count = count
        self.cue = cue
    }
}
