import Foundation

/// One of the three opening levels in Cicero's Roman Academy.
enum AcademyLevel: String, Codable, CaseIterable, Identifiable {
    case forum
    case basilica
    case colosseum

    var id: String { rawValue }

    var title: String {
        switch self {
        case .forum: return "Forum Romanum"
        case .basilica: return "Basilica"
        case .colosseum: return "Colosseum"
        }
    }

    var subtitle: String {
        switch self {
        case .forum: return "Merchant's Stall"
        case .basilica: return "Hall of Verbs"
        case .colosseum: return "Grammar Arena"
        }
    }

    var skill: String {
        switch self {
        case .forum: return "Sort nouns by their endings"
        case .basilica: return "Conjugate verbs against the clock"
        case .colosseum: return "Match nouns with adjectives"
        }
    }

    var symbol: String {
        switch self {
        case .forum: return "basket.fill"
        case .basilica: return "building.columns.fill"
        case .colosseum: return "shield.lefthalf.filled"
        }
    }

    /// Difficulty rank shown on the academy map pills.
    var rank: String {
        switch self {
        case .forum: return "Beginner"
        case .basilica: return "Elementary"
        case .colosseum: return "Advanced"
        }
    }

    /// Short blurb shown in the bottom level card on the home map.
    var rankDescription: String {
        switch self {
        case .forum: return "Learners gain a deeper understanding"
        case .basilica: return "Take your endings to the court of verbs"
        case .colosseum: return "Prove your grammar in the great arena"
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

/// A completed game session, recorded for the parent dashboard.
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
    var coins: Int = 0
    var hearts: Int = 5
    var stars: [String: Int] = [:]
    /// latin word -> number of correct answers (mastery)
    var mastery: [String: Int] = [:]
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
        coins = try c.decodeIfPresent(Int.self, forKey: .coins) ?? 0
        hearts = try c.decodeIfPresent(Int.self, forKey: .hearts) ?? 5
        stars = try c.decodeIfPresent([String: Int].self, forKey: .stars) ?? [:]
        mastery = try c.decodeIfPresent([String: Int].self, forKey: .mastery) ?? [:]
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
