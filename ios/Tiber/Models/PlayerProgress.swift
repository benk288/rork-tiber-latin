import Foundation

/// The three levels of Cicero's Roman Academy, in path order.
/// Beginner = Basilica, Elementary = Colosseum, Intermediate = Forum.
enum AcademyLevel: String, Codable, CaseIterable, Identifiable {
    case basilica
    case colosseum
    case forum

    var id: String { rawValue }

    /// Path order, bottom of the map upward.
    static let pathOrder: [AcademyLevel] = [.basilica, .colosseum, .forum]

    var title: String {
        switch self {
        case .basilica: return "Basilica"
        case .colosseum: return "Colosseum"
        case .forum: return "Forum Romanum"
        }
    }

    /// Difficulty rank shown on the map pills and level card.
    var rank: String {
        switch self {
        case .basilica: return "Beginner"
        case .colosseum: return "Elementary"
        case .forum: return "Intermediate"
        }
    }

    /// Blurb shown in the bottom level card on the home map.
    var rankDescription: String {
        switch self {
        case .basilica: return "Learners gain a deeper understanding"
        case .colosseum: return "Match nouns and adjectives in the arena"
        case .forum: return "Sort the merchant's wares by declension"
        }
    }

    /// The mini-game headline for the Cicero intro.
    var gameName: String {
        switch self {
        case .basilica: return "Legal Puzzle"
        case .colosseum: return "Grammar Arena"
        case .forum: return "Merchant's Challenge"
        }
    }

    var symbol: String {
        switch self {
        case .basilica: return "building.columns.fill"
        case .colosseum: return "shield.lefthalf.filled"
        case .forum: return "basket.fill"
        }
    }

    /// Cicero's intro dialogue, one bubble per line.
    var ciceroLines: [String] {
        switch self {
        case .basilica:
            return [
                "Salve, discipule! I am Marcus Tullius Cicero, your magister.",
                "The Basilica is where Rome argues its cases. Today, we conjugate.",
                "Verbs are the engine of a sentence. Let us begin!"
            ]
        case .colosseum:
            return [
                "Welcome to the Colosseum, where grammar gladiators are made.",
                "A noun and its adjective must agree, like sword and shield.",
                "Match them well, and the crowd will roar for you!"
            ]
        case .forum:
            return [
                "The Forum! Merchants, senators, and a thousand nouns.",
                "Every noun has a family - we call it a declension.",
                "Sort the merchant's wares by their endings. Age!"
            ]
        }
    }
}

/// The player's customizable Roman avatar.
struct AvatarConfig: Codable, Equatable {
    var skinTone: Int = 1
    var hairstyle: Int = 1
    var hairColor: Int = 1
    var eyes: Int = 0
    var outfit: Int = 0
    var accessory: Int = 1
}

/// A single unlockable achievement scroll.
struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let coins: Int
}

/// A completed game session, kept for stats.
struct GameSession: Codable, Identifiable {
    var id = UUID()
    let level: AcademyLevel
    let date: Date
    let correct: Int
    let total: Int
    let seconds: Int
}

/// Everything that persists between launches.
struct SavedProgress: Codable {
    var hasOnboarded: Bool = false
    var isSignedIn: Bool = false
    var email: String = ""
    var playerName: String = "Discipulus"
    /// Coin balance shown in the HUD; +10 per correct answer.
    var coins: Int = 2451
    /// Heart balance shown in the HUD (display currency; the mini-game uses
    /// its own 3 hearts per attempt).
    var hearts: Int = 19
    /// Daily-streak amphorae, display only.
    var amphorae: Int = 21
    var stars: [String: Int] = [:]
    /// latin word -> number of correct answers (legacy mastery)
    var mastery: [String: Int] = [:]
    /// Latin dictionary forms collected into the codex.
    var collectedWords: Set<String> = []
    var sessions: [GameSession] = []
    var unlockedAchievements: Set<String> = []
    var lastDailyChallenge: Date?
    var streak: Int = 0
    var avatar: AvatarConfig = AvatarConfig()

    // Accessibility settings
    var readableFont: Bool = false
    var colorBlindMode: Bool = false
    var gameSpeed: Double = 1.0
    var largeTouchTargets: Bool = false
    var audioHints: Bool = false

    init() {}

    // Tolerant decoding so progress saved by older builds still loads.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hasOnboarded = try c.decodeIfPresent(Bool.self, forKey: .hasOnboarded) ?? false
        isSignedIn = try c.decodeIfPresent(Bool.self, forKey: .isSignedIn) ?? false
        email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        playerName = try c.decodeIfPresent(String.self, forKey: .playerName) ?? "Discipulus"
        coins = try c.decodeIfPresent(Int.self, forKey: .coins) ?? 2451
        hearts = try c.decodeIfPresent(Int.self, forKey: .hearts) ?? 19
        amphorae = try c.decodeIfPresent(Int.self, forKey: .amphorae) ?? 21
        stars = try c.decodeIfPresent([String: Int].self, forKey: .stars) ?? [:]
        mastery = try c.decodeIfPresent([String: Int].self, forKey: .mastery) ?? [:]
        collectedWords = try c.decodeIfPresent(Set<String>.self, forKey: .collectedWords) ?? []
        sessions = try c.decodeIfPresent([GameSession].self, forKey: .sessions) ?? []
        unlockedAchievements = try c.decodeIfPresent(Set<String>.self, forKey: .unlockedAchievements) ?? []
        lastDailyChallenge = try c.decodeIfPresent(Date.self, forKey: .lastDailyChallenge)
        streak = try c.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        avatar = try c.decodeIfPresent(AvatarConfig.self, forKey: .avatar) ?? AvatarConfig()
        readableFont = try c.decodeIfPresent(Bool.self, forKey: .readableFont) ?? false
        colorBlindMode = try c.decodeIfPresent(Bool.self, forKey: .colorBlindMode) ?? false
        gameSpeed = try c.decodeIfPresent(Double.self, forKey: .gameSpeed) ?? 1.0
        largeTouchTargets = try c.decodeIfPresent(Bool.self, forKey: .largeTouchTargets) ?? false
        audioHints = try c.decodeIfPresent(Bool.self, forKey: .audioHints) ?? false
    }
}
