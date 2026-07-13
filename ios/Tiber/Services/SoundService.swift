import AVFoundation

/// Plays the bundled game sounds. Uses the ambient session category so
/// sounds mix with other audio and respect the silent switch - the right
/// behavior for a kids' game.
final class SoundService {
    static let shared = SoundService()

    enum Effect: String, CaseIterable {
        case correct, wrong, coin, star, fanfare
    }

    private var players: [Effect: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        for effect in Effect.allCases {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.volume = 0.55
            player.prepareToPlay()
            players[effect] = player
        }
    }

    func play(_ effect: Effect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }
}
