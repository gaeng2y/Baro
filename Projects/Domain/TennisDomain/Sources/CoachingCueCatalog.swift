import Foundation

public enum CoachingCueCatalog {
    public static let forehand: [CoachingCue] = [
        CoachingCue(id: "fh-shoulder-turn", text: "어깨 돌려", category: .forehand, priority: 90),
        CoachingCue(id: "fh-contact-front", text: "앞에서 맞춰", category: .forehand, priority: 95),
        CoachingCue(id: "fh-follow-high", text: "마무리 높게", category: .forehand, priority: 80),
        CoachingCue(id: "fh-body-rotation", text: "몸통 써", category: .forehand, priority: 85),
        CoachingCue(id: "fh-knee-low", text: "무릎 낮춰", category: .forehand, priority: 70)
    ]

    public static let backhand: [CoachingCue] = [
        CoachingCue(id: "bh-shoulder-more", text: "어깨 더", category: .backhand, priority: 90),
        CoachingCue(id: "bh-body-first", text: "몸통 먼저", category: .backhand, priority: 95),
        CoachingCue(id: "bh-spacing", text: "간격 유지", category: .backhand, priority: 88),
        CoachingCue(id: "bh-contact-front", text: "앞에서 맞춰", category: .backhand, priority: 86),
        CoachingCue(id: "bh-finish", text: "끝까지", category: .backhand, priority: 78)
    ]

    public static let common: [CoachingCue] = [
        CoachingCue(id: "common-good", text: "좋아요", category: .common, priority: 10),
        CoachingCue(id: "common-ready", text: "다시 준비", category: .common, priority: 20),
        CoachingCue(id: "common-in-frame", text: "화면 안으로", category: .common, priority: 100),
        CoachingCue(id: "common-step-back", text: "조금 뒤로", category: .common, priority: 100)
    ]

    public static var all: [CoachingCue] {
        forehand + backhand + common
    }

    public static func cue(id: String) -> CoachingCue {
        all.first { $0.id == id } ?? common[0]
    }
}
