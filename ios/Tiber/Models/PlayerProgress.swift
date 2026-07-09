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
    var playerName: String = "Discipulus"
    var coins: Int = 0
    var stars: [String: Int] = [:]
    /// latin word -> number of correct answers (mastery)
    var mastery: [String: Int] = [:]
    var sessions: [GameSession] = []
    var unlockedAchievements: Set<String> = []
    var lastDailyChallenge: Date?
    var streak: Int = 0

    // Accessibility settings
    var readableFont: Bool = false
    var colorBlindMode: Bool = false
    var gameSpeed: Double = 1.0
    var largeTouchTargets: Bool = false
    var audioHints: Bool = false
}
