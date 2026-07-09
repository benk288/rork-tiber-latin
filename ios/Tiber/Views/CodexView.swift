import SwiftUI

/// The collectible vocabulary codex: every word mastered joins the treasury.
struct CodexView: View {
    @Environment(AppState.self) private var app

    @State private var selectedWord: LatinWord?

    private let columns = [GridItem(.adaptive(minimum: 105), spacing: 12)]

    private var collected: Int {
        LatinContent.nouns.filter { (app.progress.mastery[$0.latin] ?? 0) > 0 }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.creamGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        codexHeader

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(LatinContent.nouns) { word in
                                wordTile(word)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Codex")
            .sheet(item: $selectedWord) { word in
                WordDetailSheet(word: word)
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.scrolls)
            }
        }
    }

    private var codexHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Verba Collecta")
                        .font(app.font(18, weight: .heavy))
                        .foregroundStyle(Theme.ink)
                    Text("\(collected) of \(LatinContent.nouns.count) words collected")
                        .font(app.font(13))
                        .foregroundStyle(Theme.brown)
                }
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.sand.opacity(0.5))
                    Capsule()
                        .fill(LinearGradient(colors: [Theme.gold, Theme.orange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(10, geo.size.width * Double(collected) / Double(max(1, LatinContent.nouns.count))))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: collected)
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22).fill(Theme.cream).shadow(color: Theme.rust.opacity(0.15), radius: 8, y: 4))
        .padding(.horizontal, 16)
    }

    private func wordTile(_ word: LatinWord) -> some View {
        let mastery = app.progress.mastery[word.latin] ?? 0
        let isCollected = mastery > 0
        return Button {
            guard isCollected else {
                Haptics.error()
                return
            }
            Haptics.tap()
            selectedWord = word
        } label: {
            VStack(spacing: 8) {
                Image(systemName: isCollected ? word.symbol : "questionmark")
                    .font(.system(size: 26))
                    .foregroundStyle(isCollected ? Theme.terracotta : Theme.sand)
                    .frame(height: 32)
                Text(isCollected ? word.latin : "???")
                    .font(app.font(15, weight: .bold))
                    .foregroundStyle(isCollected ? Theme.ink : Theme.brown.opacity(0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if isCollected {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < min(mastery, 3) ? Theme.gold : Theme.sand.opacity(0.5))
                                .frame(width: 6, height: 6)
                        }
                    }
                } else {
                    Text(word.category.endingLabel)
                        .font(app.font(11, weight: .semibold))
                        .foregroundStyle(Theme.brown.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: app.progress.largeTouchTargets ? 118 : 104)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isCollected ? Theme.cream : Theme.parchment.opacity(0.6))
                    .shadow(color: isCollected ? Theme.rust.opacity(0.18) : .clear, radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isCollected ? Theme.gold.opacity(0.6) : Theme.sand.opacity(0.6), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Word detail

private struct WordDetailSheet: View {
    @Environment(AppState.self) private var app
    let word: LatinWord

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Capsule()
                    .fill(Theme.sand)
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                Image(systemName: word.symbol)
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.terracotta)
                    .padding(26)
                    .background(Circle().fill(Theme.parchment))
                    .overlay(Circle().strokeBorder(Theme.gold, lineWidth: 3))

                VStack(spacing: 6) {
                    HStack(spacing: 10) {
                        Text(word.latin)
                            .font(app.font(34, weight: .heavy))
                            .foregroundStyle(Theme.ink)
                        Button {
                            Haptics.tap()
                            SpeechService.shared.speak(word.latin, slow: true)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Theme.orange))
                        }
                    }
                    Text(word.meaning)
                        .font(app.font(19))
                        .foregroundStyle(Theme.brown)
                }

                HStack(spacing: 10) {
                    infoChip(label: "Genitive", value: word.genitive)
                    infoChip(label: "Group", value: word.category.endingLabel)
                    infoChip(label: "Mastery", value: "\(min(app.progress.mastery[word.latin] ?? 0, 99))")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Example")
                        .font(app.font(13, weight: .bold))
                        .foregroundStyle(Theme.terracotta)
                        .textCase(.uppercase)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(word.example)
                                .font(app.font(18, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Text(word.exampleMeaning)
                                .font(app.font(15))
                                .foregroundStyle(Theme.brown)
                        }
                        Spacer()
                        Button {
                            Haptics.tap()
                            SpeechService.shared.speak(word.example)
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(Theme.orange)
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.parchment))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Theme.cream)
    }

    private func infoChip(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(app.font(11, weight: .semibold))
                .foregroundStyle(Theme.brown.opacity(0.7))
            Text(value)
                .font(app.font(16, weight: .bold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(Theme.parchment))
    }
}
