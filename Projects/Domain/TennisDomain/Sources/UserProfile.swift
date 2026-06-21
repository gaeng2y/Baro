import Foundation

public struct UserProfile: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var handedness: Handedness
    public var backhandType: BackhandType
    public var skillLevel: SkillLevel?
    public var feedbackFrequency: FeedbackFrequency
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        handedness: Handedness = .right,
        backhandType: BackhandType = .twoHanded,
        skillLevel: SkillLevel? = nil,
        feedbackFrequency: FeedbackFrequency = .normal,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.handedness = handedness
        self.backhandType = backhandType
        self.skillLevel = skillLevel
        self.feedbackFrequency = feedbackFrequency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
