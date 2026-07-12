import Foundation

/// A codex vocabulary entry.
struct VocabWord: Identifiable, Equatable {
    let latin: String
    let english: String
    /// Grammar note shown on the card, e.g. "f., 1st declension".
    let detail: String
    /// The level whose completion collects this word.
    let level: AcademyLevel

    var id: String { latin }
}

/// One fill-in-the-blank conjugation question for the Basilica Legal Puzzle.
struct ConjugationQuestion: Identifiable {
    let sentence: String          // contains ___ for the blank
    let english: String
    let options: [String]
    let answer: String
    /// Gentle rule reminder Cicero gives on a wrong answer.
    let rule: String
    /// The dictionary form collected in the codex.
    let vocabLatin: String

    var id: String { sentence }
}

/// Curriculum content following Jenney's First Year Latin, Lesson 1-2 scope:
/// first-conjugation present tense and first-declension nouns.
enum CiceroCurriculum {

    // MARK: - Basilica: Legal Puzzle (present-tense conjugation)

    static let basilicaQuestions: [ConjugationQuestion] = [
        ConjugationQuestion(
            sentence: "Ego aquam ___.",
            english: "I carry water.",
            options: ["porto", "portas", "portat", "portant"],
            answer: "porto",
            rule: "Not quite - first person singular takes -o.",
            vocabLatin: "porto"
        ),
        ConjugationQuestion(
            sentence: "Tu viam ___.",
            english: "You watch the road.",
            options: ["specto", "spectas", "spectat", "spectamus"],
            answer: "spectas",
            rule: "Not quite - second person singular takes -s.",
            vocabLatin: "specto"
        ),
        ConjugationQuestion(
            sentence: "Puella rosam ___.",
            english: "The girl loves the rose.",
            options: ["amo", "amas", "amat", "amant"],
            answer: "amat",
            rule: "Not quite - third person singular takes -t.",
            vocabLatin: "amo"
        ),
        ConjugationQuestion(
            sentence: "Nos patriam ___.",
            english: "We love our homeland.",
            options: ["amo", "amamus", "amatis", "amant"],
            answer: "amamus",
            rule: "Not quite - first person plural takes -mus.",
            vocabLatin: "patria"
        ),
        ConjugationQuestion(
            sentence: "Vos magistrum ___.",
            english: "You all praise the teacher.",
            options: ["laudo", "laudas", "laudatis", "laudant"],
            answer: "laudatis",
            rule: "Not quite - second person plural takes -tis.",
            vocabLatin: "laudo"
        ),
        ConjugationQuestion(
            sentence: "Pueri in via ___.",
            english: "The boys walk in the road.",
            options: ["ambulo", "ambulat", "ambulamus", "ambulant"],
            answer: "ambulant",
            rule: "Not quite - third person plural takes -nt.",
            vocabLatin: "ambulo"
        ),
        ConjugationQuestion(
            sentence: "Ego Ciceronem ___.",
            english: "I praise Cicero.",
            options: ["laudo", "laudas", "laudat", "laudamus"],
            answer: "laudo",
            rule: "Not quite - first person singular takes -o.",
            vocabLatin: "laudo"
        ),
        ConjugationQuestion(
            sentence: "Tu nautam ___.",
            english: "You call the sailor.",
            options: ["voco", "vocas", "vocat", "vocant"],
            answer: "vocas",
            rule: "Not quite - second person singular takes -s.",
            vocabLatin: "voco"
        )
    ]

    // MARK: - Codex vocabulary

    static let vocabulary: [VocabWord] = [
        VocabWord(latin: "porto", english: "I carry", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "specto", english: "I watch", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "amo", english: "I love", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "laudo", english: "I praise", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "ambulo", english: "I walk", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "voco", english: "I call", detail: "1st conjugation verb", level: .basilica),
        VocabWord(latin: "aqua", english: "water", detail: "f., 1st declension", level: .basilica),
        VocabWord(latin: "via", english: "road", detail: "f., 1st declension", level: .basilica),
        VocabWord(latin: "patria", english: "homeland", detail: "f., 1st declension", level: .basilica),
        VocabWord(latin: "nauta", english: "sailor", detail: "m., 1st declension", level: .basilica),
        // Colosseum (locked until that level ships)
        VocabWord(latin: "gladius", english: "sword", detail: "m., 2nd declension", level: .colosseum),
        VocabWord(latin: "hasta", english: "spear", detail: "f., 1st declension", level: .colosseum),
        VocabWord(latin: "magnus", english: "great, large", detail: "adjective", level: .colosseum),
        VocabWord(latin: "arena", english: "sand, arena", detail: "f., 1st declension", level: .colosseum),
        // Forum
        VocabWord(latin: "mercator", english: "merchant", detail: "m., 3rd declension", level: .forum),
        VocabWord(latin: "forum", english: "marketplace", detail: "n., 2nd declension", level: .forum),
        VocabWord(latin: "templum", english: "temple", detail: "n., 2nd declension", level: .forum),
        VocabWord(latin: "amphora", english: "storage jar", detail: "f., 1st declension", level: .forum)
    ]

    static func vocab(for level: AcademyLevel) -> [VocabWord] {
        vocabulary.filter { $0.level == level }
    }

    // MARK: - "Did you know?" culture facts

    static let facts: [String] = [
        "Roman basilicas were law courts and meeting halls - centuries later, their design inspired the first churches.",
        "Cicero was Rome's most famous lawyer. Crowds gathered just to hear him argue a case.",
        "Roman children wrote on wax tablets with a stylus - and erased mistakes with the flat end.",
        "The Colosseum could hold about 50,000 spectators and even had a retractable awning called the velarium.",
        "Romans told time with sundials and water clocks - a lawyer's speaking time was measured in water!"
    ]

    static func randomFact() -> String {
        facts.randomElement() ?? facts[0]
    }
}
