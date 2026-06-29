import Foundation
import TennisDomain

public struct AnalyticsClient: Sendable {
    public var track: @Sendable (AnalyticsEvent) -> Void

    public init(track: @escaping @Sendable (AnalyticsEvent) -> Void) {
        self.track = track
    }
}

public extension AnalyticsClient {
    static let noop = AnalyticsClient { _ in }
    static let preview = noop
}

public struct AnalyticsEvent: Equatable, Sendable {
    public var name: String
    public var parameters: [String: AnalyticsValue]

    public init(
        name: String,
        parameters: [String: AnalyticsValue] = [:]
    ) {
        self.name = name
        self.parameters = parameters
    }
}

public enum AnalyticsValue: Equatable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
}

public extension AnalyticsEvent {
    static let appOpened = AnalyticsEvent(name: "app_opened")
    static let localDataDeleted = AnalyticsEvent(name: "local_data_deleted")

    static func onboardingCompleted(profile: UserProfile) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "onboarding_completed",
            parameters: [
                "handedness": .string(profile.handedness.rawValue),
                "backhand_type": .string(profile.backhandType.rawValue),
                "feedback_frequency": .string(profile.feedbackFrequency.rawValue)
            ]
        )
    }

    static func trainingSetupOpened(initialStroke: StrokeType?) -> AnalyticsEvent {
        var parameters: [String: AnalyticsValue] = [:]
        if let initialStroke {
            parameters["initial_stroke_type"] = .string(initialStroke.rawValue)
            parameters["entry_point"] = .string("quick_start")
        } else {
            parameters["entry_point"] = .string("start_training")
        }
        return AnalyticsEvent(name: "training_setup_opened", parameters: parameters)
    }

    static func sessionStarted(
        strokeType: StrokeType,
        cameraMode: CameraMode
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "session_started",
            parameters: [
                "stroke_type": .string(strokeType.rawValue),
                "camera_mode": .string(cameraMode.rawValue)
            ]
        )
    }

    static func sessionFinished(_ session: TrainingSession) -> AnalyticsEvent {
        var parameters: [String: AnalyticsValue] = [
            "stroke_type": .string(session.strokeType.rawValue),
            "camera_mode": .string(session.cameraMode.rawValue),
            "swing_count": .int(session.swingEvents.count)
        ]
        if let summary = session.summary {
            parameters["analyzed_swing_count"] = .int(summary.analyzedSwingCount)
            parameters["failed_swing_count"] = .int(summary.failedSwingCount)
        }
        if let endedAt = session.endedAt {
            parameters["duration_seconds"] = .double(endedAt.timeIntervalSince(session.startedAt))
        }
        return AnalyticsEvent(name: "session_finished", parameters: parameters)
    }

    static func settingsChanged(
        key: String,
        value: AnalyticsValue
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "settings_changed",
            parameters: [
                "setting_key": .string(key),
                "setting_value": value
            ]
        )
    }
}
