import SwiftUI
import Observation

/// Global observable app state: progress, rewards, settings, persistence.
@Observable
final class AppState {
    private static let storageKey = "tiber.progress.v1"

    var progress: SavedProgress {
        didSet { save() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(SavedProgress.self, from: data) {
            progress = decoded
        } else {
            progress = SavedProgress()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    // MARK: - Derived values

    var learnedWords: [LatinWord] {
        LatinContent.nouns.filter { (progress.mastery[$0.latin] ?? 0) > 0 }
    }

    var totalPlaySeconds: Int {
        progress.sessions.reduce(0) { $0 + $1.seconds }
    }

    func stars(for level: AcademyLevel) -> Int {
        progress.stars[level.rawValue] ?? 0
    }

    func isUnlocked(_ level: AcademyLevel) -> Bool {
        switch level {
        case .forum: return true
        case .basilica: return stars(for: .forum) >= 1
        case .colosseum: return stars(for: .basilica) >= 1
        }
    }

    var dailyChallengeCompletedToday: Bool {
        guard let last = progress.lastDailyChallenge else { return false }
        return Calendar.current.isDateInToday(last)
    }

    /// Accuracy per level for the parent dashboard, 0...1.
    func accuracy(for level: AcademyLevel) -> Double? {
        let sessions = progress.sessions.filter { $0.level == level }
        let total = sessions.reduce(0) { $0 + $1.total }
        guard total > 0 else { return nil }
        let correct = sessions.reduce(0) { $0 + $1.correct }
        return Double(correct) / Double(total)
    }

    // MARK: - Spaced repetition (lite)

    /// Picks words for a round: favors unseen and low-mastery words while
    /// resurfacing already-learned words so they are not forgotten.
    func pickWords(from pool: [LatinWord], count: Int) -> [LatinWord] {
        let sorted = pool.sorted { a, b in
            let ma = progress.mastery[a.latin] ?? 0
            let mb = progress.mastery[b.latin] ?? 0
            if ma == mb { return Bool.random() }
            return ma < mb
        }
        let fresh = Array(sorted.prefix(count * 2)).shuffled().prefix(count)
        var result = Array(fresh)
        // Resurface one well-known word if available.
        if let review = pool.filter({ (progress.mastery[$0.latin] ?? 0) >= 3 })
            .shuffled().first,
           !result.contains(review), result.count >= 2 {
            result[result.count - 1] = review
        }
        return result
    }

    // MARK: - Recording results

    func recordAnswer(word: LatinWord, correct: Bool) {
        if correct {
            progress.mastery[word.latin, default: 0] += 1
        }
    }

    func recordSession(level: AcademyLevel, correct: Int, total: Int, seconds: Int) -> Int {
        let session = GameSession(level: level, date: Date(), correct: correct, total: total, seconds: seconds)
        progress.sessions.append(session)
        if progress.sessions.count > 200 {
            progress.sessions.removeFirst(progress.sessions.count - 200)
        }

        let ratio = total > 0 ? Double(correct) / Double(total) : 0
        let starsEarned = ratio >= 0.9 ? 3 : ratio >= 0.7 ? 2 : ratio >= 0.5 ? 1 : 0
        let previous = stars(for: level)
        if starsEarned > previous {
            progress.stars[level.rawValue] = starsEarned
        }

        let coins = correct * 2 + starsEarned * 5
        progress.coins += coins
        checkAchievements()
        return coins
    }

    func completeDailyChallenge(correct: Int, total: Int) {
        progress.lastDailyChallenge = Date()
        let calendar = Calendar.current
        if let previous = progress.sessions.last?.date,
           calendar.isDateInYesterday(previous) || calendar.isDateInToday(previous) {
            progress.streak += 1
        } else {
            progress.streak = max(1, progress.streak == 0 ? 1 : 1)
        }
        progress.coins += correct * 2 + 10
        checkAchievements()
    }

    // MARK: - Achievements

    static let achievements: [Achievement] = [
        Achievement(id: "first_game", title: "Salve, Discipule!", detail: "Finish your first lesson", symbol: "hand.wave.fill", coins: 5),
        Achievement(id: "words_10", title: "Decem Verba", detail: "Learn 10 Latin words", symbol: "book.fill", coins: 10),
        Achievement(id: "words_25", title: "Codex Collector", detail: "Learn 25 Latin words", symbol: "books.vertical.fill", coins: 20),
        Achievement(id: "stars_forum", title: "Master Merchant", detail: "Earn 3 stars in the Forum", symbol: "basket.fill", coins: 15),
        Achievement(id: "stars_basilica", title: "Voice of the Court", detail: "Earn 3 stars in the Basilica", symbol: "building.columns.fill", coins: 15),
        Achievement(id: "stars_colosseum", title: "Grammar Gladiator", detail: "Earn 3 stars in the Colosseum", symbol: "shield.lefthalf.filled", coins: 15),
        Achievement(id: "coins_100", title: "Rich as Crassus", detail: "Collect 100 bronze coins", symbol: "circle.hexagongrid.fill", coins: 25),
        Achievement(id: "daily_first", title: "Daily Devotion", detail: "Complete a daily challenge", symbol: "sun.max.fill", coins: 10)
    ]

    private func checkAchievements() {
        var newly: [String] = []
        func unlock(_ id: String, when condition: Bool) {
            if condition, !progress.unlockedAchievements.contains(id) {
                progress.unlockedAchievements.insert(id)
                newly.append(id)
            }
        }
        let learned = progress.mastery.values.filter { $0 > 0 }.count
        unlock("first_game", when: !progress.sessions.isEmpty)
        unlock("words_10", when: learned >= 10)
        unlock("words_25", when: learned >= 25)
        unlock("stars_forum", when: stars(for: .forum) == 3)
        unlock("stars_basilica", when: stars(for: .basilica) == 3)
        unlock("stars_colosseum", when: stars(for: .colosseum) == 3)
        unlock("coins_100", when: progress.coins >= 100)
        unlock("daily_first", when: progress.lastDailyChallenge != nil)

        for id in newly {
            if let achievement = Self.achievements.first(where: { $0.id == id }) {
                progress.coins += achievement.coins
            }
        }
    }
}
