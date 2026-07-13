import SwiftUI

/// Screen 5 - Codex: a grid of collected vocabulary cards. Words the player
/// has not earned yet appear as locked silhouettes.
struct CodexView: View {
    @Environment(AppState.self) private var app

    private var collected: Int {
        CiceroCurriculum.vocabulary.filter { app.progress.collectedWords.contains($0.latin) }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Codex")
                    .font(.rubik(24, .semibold))
                    .foregroundStyle(Theme.gray950)
                    .padding(.top, 12)

                // Collection progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(collected) of \(CiceroCurriculum.vocabulary.count) words collected")
                        .font(.rubik(13))
                        .foregroundStyle(Theme.gray600)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.gray100)
                            Capsule()
                                .fill(Theme.primary)
                                .frame(width: max(10, geo.size.width * Double(collected) / Double(max(1, CiceroCurriculum.vocabulary.count))))
                        }
                    }
                    .frame(height: 10)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(CiceroCurriculum.vocabulary) { word in
                        if app.progress.collectedWords.contains(word.latin) {
                            collectedCard(word)
                        } else {
                            lockedCard(word)
                        }
                    }
                }
                .padding(.bottom, 130)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.cream.ignoresSafeArea())
    }

    private func collectedCard(_ word: VocabWord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(word.latin)
                    .font(.rubik(17, .semibold))
                    .foregroundStyle(Theme.gray950)
                Spacer()
                SpeakerButton(text: word.latin, size: 14)
            }
            Text(word.english)
                .font(.rubik(14))
                .foregroundStyle(Theme.gray600)
            Text(word.detail)
                .font(.rubik(11, .medium))
                .foregroundStyle(Theme.orange500)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Theme.orange100))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
    }

    private func lockedCard(_ word: VocabWord) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundStyle(Theme.gray300)
            // Silhouette of the hidden word.
            Text(String(repeating: "\u{25AA}", count: min(6, word.latin.count)))
                .font(.rubik(14))
                .foregroundStyle(Theme.gray200)
            Text(word.level.rank)
                .font(.rubik(11))
                .foregroundStyle(Theme.gray300)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 96)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.gray50)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.gray100, style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
        )
    }
}

/// Practice tab: a quick five-question review round. Questions the player
/// has missed before are served first (lightweight spaced repetition).
struct PracticeView: View {
    @Environment(AppState.self) private var app
    @State private var practicing = false

    private var unlocked: Bool { app.stars(for: .basilica) > 0 }
    private var missedCount: Int { app.progress.missedSentences.values.reduce(0, +) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: unlocked ? "figure.run" : "lock.fill")
                .font(.system(size: 44))
                .foregroundStyle(unlocked ? Theme.orange400 : Theme.gray300)
            Text("Practice")
                .font(.rubik(22, .semibold))
                .foregroundStyle(Theme.gray950)
            Text(unlocked
                 ? (missedCount > 0
                    ? "Cicero remembers what tripped you up - a quick round to master it."
                    : "A quick five-question review. Repetitio mater studiorum!")
                 : "Complete your first level to unlock daily practice.")
                .font(.rubik(15))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.gray600)
                .padding(.horizontal, 24)

            if unlocked {
                Button {
                    Haptics.tap()
                    practicing = true
                } label: {
                    Text("Start practice")
                        .font(.rubik(16, .semibold))
                        .tracking(0.16)
                        .foregroundStyle(Theme.buttonText)
                        .padding(.horizontal, 36)
                        .frame(height: 52)
                        .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
                }
                .padding(.top, 8)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.cream.ignoresSafeArea())
        .fullScreenCover(isPresented: $practicing) {
            PracticeSessionView { practicing = false }
        }
    }
}

/// One practice round: 5 prioritized questions, 45 seconds, +5 coins each.
private struct PracticeSessionView: View {
    @Environment(AppState.self) private var app
    var onDone: () -> Void

    private enum Stage { case playing, done(coins: Int) }
    @State private var stage: Stage = .playing
    @State private var questions: [ConjugationQuestion] = []

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            switch stage {
            case .playing:
                if questions.isEmpty {
                    Color.clear.onAppear {
                        questions = CiceroCurriculum.practiceQuestions(missed: app.progress.missedSentences)
                    }
                } else {
                    ConjugationGameView(
                        questions: questions,
                        coinsPerCorrect: 5,
                        timeLimit: 45,
                        onFinish: { _, coins in
                            app.progress.coins += coins
                            withAnimation { stage = .done(coins: coins) }
                        },
                        onFail: { withAnimation { stage = .done(coins: 0) } },
                        onQuit: { onDone() },
                        onMiss: { app.recordMiss($0) },
                        onHit: { app.recordPracticeHit($0) }
                    )
                }
            case .done(let coins):
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.orange400)
                    Text("Practice finished!")
                        .font(.rubik(22, .semibold))
                        .foregroundStyle(Theme.gray950)
                    if coins > 0 {
                        Text("+\(coins) coins")
                            .font(.rubik(16, .semibold))
                            .foregroundStyle(Theme.gray950)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white))
                    }
                    Text("Cicero: \u{201C}Bene factum! Every repetition builds the road.\u{201D}")
                        .font(.rubik(14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.gray600)
                        .padding(.horizontal, 24)
                    Spacer()
                    Button {
                        Haptics.tap()
                        onDone()
                    } label: {
                        Text("Done")
                            .font(.rubik(16, .semibold))
                            .tracking(0.16)
                            .foregroundStyle(Theme.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .onAppear { SoundService.shared.play(.fanfare) }
            }
        }
    }
}

#Preview {
    CodexView()
        .environment(AppState())
}
