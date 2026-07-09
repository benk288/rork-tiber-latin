import Foundation

/// The grammatical bucket a vocabulary word belongs to, following
/// Jenney's First Year Latin early lessons.
enum WordCategory: String, Codable, CaseIterable {
    case firstDeclensionA
    case secondDeclensionUs
    case secondDeclensionUm
    case verb
    case adjective

    var endingLabel: String {
        switch self {
        case .firstDeclensionA: return "-a"
        case .secondDeclensionUs: return "-us"
        case .secondDeclensionUm: return "-um"
        case .verb: return "verb"
        case .adjective: return "adj."
        }
    }

    var displayName: String {
        switch self {
        case .firstDeclensionA: return "1st Declension"
        case .secondDeclensionUs: return "2nd Declension (m.)"
        case .secondDeclensionUm: return "2nd Declension (n.)"
        case .verb: return "1st Conjugation Verb"
        case .adjective: return "Adjective"
        }
    }
}

/// A single Latin vocabulary entry.
struct LatinWord: Codable, Identifiable, Hashable {
    var id: String { latin }
    let latin: String
    let meaning: String
    let category: WordCategory
    let genitive: String
    let symbol: String
    let example: String
    let exampleMeaning: String
}

/// A first-conjugation verb with its full present-tense forms.
struct LatinVerb: Identifiable, Hashable {
    var id: String { latin }
    let latin: String
    let meaning: String
    /// Forms in order: ego, tu, is/ea, nos, vos, ei/eae.
    let forms: [String]
}

/// Adjective with -us / -a / -um forms for the agreement arena.
struct LatinAdjective: Identifiable, Hashable {
    var id: String { masculine }
    let masculine: String
    let feminine: String
    let neuter: String
    let meaning: String

    func form(for category: WordCategory) -> String {
        switch category {
        case .firstDeclensionA: return feminine
        case .secondDeclensionUs: return masculine
        default: return neuter
        }
    }
}

/// Static curriculum content for the opening levels.
enum LatinContent {

    static let nouns: [LatinWord] = [
        LatinWord(latin: "puella", meaning: "girl", category: .firstDeclensionA, genitive: "puellae", symbol: "figure.dress.line.vertical.figure", example: "Puella aquam portat.", exampleMeaning: "The girl carries water."),
        LatinWord(latin: "aqua", meaning: "water", category: .firstDeclensionA, genitive: "aquae", symbol: "drop.fill", example: "Aqua est clara.", exampleMeaning: "The water is clear."),
        LatinWord(latin: "casa", meaning: "cottage, house", category: .firstDeclensionA, genitive: "casae", symbol: "house.fill", example: "Casa est parva.", exampleMeaning: "The cottage is small."),
        LatinWord(latin: "via", meaning: "road, way", category: .firstDeclensionA, genitive: "viae", symbol: "road.lanes", example: "Via est longa.", exampleMeaning: "The road is long."),
        LatinWord(latin: "silva", meaning: "forest", category: .firstDeclensionA, genitive: "silvae", symbol: "tree.fill", example: "Silva est magna.", exampleMeaning: "The forest is large."),
        LatinWord(latin: "terra", meaning: "land, earth", category: .firstDeclensionA, genitive: "terrae", symbol: "globe.europe.africa.fill", example: "Terra est lata.", exampleMeaning: "The land is wide."),
        LatinWord(latin: "regina", meaning: "queen", category: .firstDeclensionA, genitive: "reginae", symbol: "crown.fill", example: "Regina est bona.", exampleMeaning: "The queen is good."),
        LatinWord(latin: "stella", meaning: "star", category: .firstDeclensionA, genitive: "stellae", symbol: "star.fill", example: "Stella est clara.", exampleMeaning: "The star is bright."),
        LatinWord(latin: "insula", meaning: "island", category: .firstDeclensionA, genitive: "insulae", symbol: "water.waves", example: "Insula est parva.", exampleMeaning: "The island is small."),
        LatinWord(latin: "femina", meaning: "woman", category: .firstDeclensionA, genitive: "feminae", symbol: "person.fill", example: "Femina rosam amat.", exampleMeaning: "The woman loves the rose."),
        LatinWord(latin: "rosa", meaning: "rose", category: .firstDeclensionA, genitive: "rosae", symbol: "camera.macro", example: "Rosa est pulchra.", exampleMeaning: "The rose is beautiful."),
        LatinWord(latin: "luna", meaning: "moon", category: .firstDeclensionA, genitive: "lunae", symbol: "moon.fill", example: "Luna est alta.", exampleMeaning: "The moon is high."),
        LatinWord(latin: "amicus", meaning: "friend", category: .secondDeclensionUs, genitive: "amici", symbol: "person.2.fill", example: "Amicus est bonus.", exampleMeaning: "The friend is good."),
        LatinWord(latin: "equus", meaning: "horse", category: .secondDeclensionUs, genitive: "equi", symbol: "figure.equestrian.sports", example: "Equus est magnus.", exampleMeaning: "The horse is big."),
        LatinWord(latin: "dominus", meaning: "master, lord", category: .secondDeclensionUs, genitive: "domini", symbol: "person.crop.rectangle.fill", example: "Dominus servum vocat.", exampleMeaning: "The master calls the servant."),
        LatinWord(latin: "servus", meaning: "servant", category: .secondDeclensionUs, genitive: "servi", symbol: "figure.walk", example: "Servus aquam portat.", exampleMeaning: "The servant carries water."),
        LatinWord(latin: "filius", meaning: "son", category: .secondDeclensionUs, genitive: "filii", symbol: "figure.and.child.holdinghands", example: "Filius est parvus.", exampleMeaning: "The son is small."),
        LatinWord(latin: "hortus", meaning: "garden", category: .secondDeclensionUs, genitive: "horti", symbol: "leaf.fill", example: "Hortus est pulcher.", exampleMeaning: "The garden is beautiful."),
        LatinWord(latin: "murus", meaning: "wall", category: .secondDeclensionUs, genitive: "muri", symbol: "square.grid.3x3.fill", example: "Murus est altus.", exampleMeaning: "The wall is high."),
        LatinWord(latin: "ventus", meaning: "wind", category: .secondDeclensionUs, genitive: "venti", symbol: "wind", example: "Ventus est magnus.", exampleMeaning: "The wind is strong."),
        LatinWord(latin: "templum", meaning: "temple", category: .secondDeclensionUm, genitive: "templi", symbol: "building.columns.fill", example: "Templum est magnum.", exampleMeaning: "The temple is large."),
        LatinWord(latin: "donum", meaning: "gift", category: .secondDeclensionUm, genitive: "doni", symbol: "gift.fill", example: "Donum est pulchrum.", exampleMeaning: "The gift is beautiful."),
        LatinWord(latin: "bellum", meaning: "war", category: .secondDeclensionUm, genitive: "belli", symbol: "shield.fill", example: "Bellum est longum.", exampleMeaning: "The war is long."),
        LatinWord(latin: "oppidum", meaning: "town", category: .secondDeclensionUm, genitive: "oppidi", symbol: "building.2.fill", example: "Oppidum est parvum.", exampleMeaning: "The town is small."),
        LatinWord(latin: "aurum", meaning: "gold", category: .secondDeclensionUm, genitive: "auri", symbol: "circle.hexagongrid.fill", example: "Aurum est carum.", exampleMeaning: "Gold is precious."),
        LatinWord(latin: "frumentum", meaning: "grain", category: .secondDeclensionUm, genitive: "frumenti", symbol: "laurel.leading", example: "Frumentum est bonum.", exampleMeaning: "The grain is good."),
        LatinWord(latin: "caelum", meaning: "sky", category: .secondDeclensionUm, genitive: "caeli", symbol: "cloud.sun.fill", example: "Caelum est clarum.", exampleMeaning: "The sky is clear."),
        LatinWord(latin: "vinum", meaning: "wine", category: .secondDeclensionUm, genitive: "vini", symbol: "wineglass.fill", example: "Vinum est novum.", exampleMeaning: "The wine is new.")
    ]

    static let verbs: [LatinVerb] = [
        LatinVerb(latin: "porto", meaning: "carry", forms: ["porto", "portas", "portat", "portamus", "portatis", "portant"]),
        LatinVerb(latin: "amo", meaning: "love", forms: ["amo", "amas", "amat", "amamus", "amatis", "amant"]),
        LatinVerb(latin: "voco", meaning: "call", forms: ["voco", "vocas", "vocat", "vocamus", "vocatis", "vocant"]),
        LatinVerb(latin: "laudo", meaning: "praise", forms: ["laudo", "laudas", "laudat", "laudamus", "laudatis", "laudant"]),
        LatinVerb(latin: "specto", meaning: "watch", forms: ["specto", "spectas", "spectat", "spectamus", "spectatis", "spectant"]),
        LatinVerb(latin: "ambulo", meaning: "walk", forms: ["ambulo", "ambulas", "ambulat", "ambulamus", "ambulatis", "ambulant"]),
        LatinVerb(latin: "laboro", meaning: "work", forms: ["laboro", "laboras", "laborat", "laboramus", "laboratis", "laborant"]),
        LatinVerb(latin: "narro", meaning: "tell", forms: ["narro", "narras", "narrat", "narramus", "narratis", "narrant"])
    ]

    /// Subjects paired with the index of the correct verb form.
    static let subjects: [(pronoun: String, meaning: String, formIndex: Int)] = [
        ("ego", "I", 0),
        ("tu", "you", 1),
        ("puella", "the girl", 2),
        ("nos", "we", 3),
        ("vos", "you all", 4),
        ("amici", "the friends", 5)
    ]

    static let adjectives: [LatinAdjective] = [
        LatinAdjective(masculine: "bonus", feminine: "bona", neuter: "bonum", meaning: "good"),
        LatinAdjective(masculine: "magnus", feminine: "magna", neuter: "magnum", meaning: "big"),
        LatinAdjective(masculine: "parvus", feminine: "parva", neuter: "parvum", meaning: "small"),
        LatinAdjective(masculine: "altus", feminine: "alta", neuter: "altum", meaning: "tall, high"),
        LatinAdjective(masculine: "longus", feminine: "longa", neuter: "longum", meaning: "long"),
        LatinAdjective(masculine: "novus", feminine: "nova", neuter: "novum", meaning: "new"),
        LatinAdjective(masculine: "clarus", feminine: "clara", neuter: "clarum", meaning: "bright, famous"),
        LatinAdjective(masculine: "latus", feminine: "lata", neuter: "latum", meaning: "wide")
    ]

    /// "Did you know?" facts about Roman life, shown after games.
    static let romanFacts: [String] = [
        "The Forum Romanum was the beating heart of Rome - part market, part courthouse, part town square!",
        "Roman children played with wooden swords, hoops, and even board games like latrunculi, a bit like chess.",
        "Cicero was famous for his speeches. Romans would gather just to hear him argue a court case!",
        "Romans wrote on wax tablets with a pointed stick called a stylus - and erased with the flat end.",
        "The Colosseum could hold about 50,000 spectators and even had a retractable sun shade called the velarium.",
        "Roman roads were so well built that some are still walked on today, 2,000 years later!",
        "A basilica was not a church in ancient Rome - it was a huge hall for law courts and business.",
        "Wealthy Roman children had a pedagogus, a personal tutor who walked them to school.",
        "Romans loved fast food! Shops called thermopolia sold hot meals over marble counters.",
        "Latin gave birth to Spanish, French, Italian, Portuguese, and Romanian - the Romance languages.",
        "Roman coins carried the emperor's face - news traveled through pockets!",
        "Purple dye was so expensive that only emperors could afford to wear all-purple robes."
    ]

    static func randomFact() -> String {
        romanFacts.randomElement() ?? romanFacts[0]
    }

    static func word(for latin: String) -> LatinWord? {
        nouns.first { $0.latin == latin }
    }
}
