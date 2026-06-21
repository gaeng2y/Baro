import AVFoundation
import Foundation
import TennisDomain

public struct AudioFeedbackClient: Sendable {
    public var play: @Sendable (CoachingCue) async throws -> Void

    public init(play: @escaping @Sendable (CoachingCue) async throws -> Void) {
        self.play = play
    }
}

public extension AudioFeedbackClient {
    static let preview = AudioFeedbackClient { _ in }

    @MainActor
    static func live() -> AudioFeedbackClient {
        let player = SpeechCuePlayer()
        return AudioFeedbackClient { cue in
            await player.play(cue)
        }
    }
}

@MainActor
final class SpeechCuePlayer {
    private let synthesizer = AVSpeechSynthesizer()

    func play(_ cue: CoachingCue) {
        guard !synthesizer.isSpeaking else { return }
        let utterance = AVSpeechUtterance(string: cue.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}
