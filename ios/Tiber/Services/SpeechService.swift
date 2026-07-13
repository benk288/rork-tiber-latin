import AVFoundation

/// Pronounces Latin words using the speech synthesizer with an Italian
/// voice, which is the closest match for classical Latin vowels.
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String, slow: Bool = false) {
        synthesizer.stopSpeaking(at: .immediate)
        // Strip macrons for the synthesizer; it reads plain vowels cleanly.
        let plain = text.folding(options: .diacriticInsensitive, locale: Locale(identifier: "en"))
        let utterance = AVSpeechUtterance(string: plain)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.rate = slow ? 0.32 : 0.42
        utterance.pitchMultiplier = 0.95
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
