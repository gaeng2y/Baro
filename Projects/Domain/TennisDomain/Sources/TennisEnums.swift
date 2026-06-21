import Foundation

public enum Handedness: String, Codable, CaseIterable, Sendable {
    case right
    case left
}

public enum BackhandType: String, Codable, CaseIterable, Sendable {
    case twoHanded
    case oneHandedExperimental
}

public enum SkillLevel: String, Codable, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
}

public enum FeedbackFrequency: String, Codable, CaseIterable, Sendable {
    case low
    case normal
    case high
}

public enum StrokeType: String, Codable, CaseIterable, Sendable, Identifiable {
    case forehand
    case twoHandBackhand

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .forehand:
            "포핸드"
        case .twoHandBackhand:
            "양손 백핸드"
        }
    }
}

public enum CameraMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case side
    case rearDiagonal

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .side:
            "측면 촬영"
        case .rearDiagonal:
            "후방 대각선"
        }
    }
}

public enum SwingPhase: String, Codable, CaseIterable, Sendable {
    case preparation
    case backswing
    case forwardSwing
    case contact
    case followThrough
}

public enum CoachingCueCategory: String, Codable, CaseIterable, Sendable {
    case forehand
    case backhand
    case common
}

public enum CoachingErrorType: String, Codable, CaseIterable, Sendable {
    case shoulderTurnLack
    case lateContact
    case poorFollowThrough
    case lowerBodyInactive
    case insufficientBodyRotation
    case poorSpacing
}

public struct RuleVersion: Equatable, Codable, Sendable, RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let v0_1 = RuleVersion(rawValue: "rule-v0.1")
}
