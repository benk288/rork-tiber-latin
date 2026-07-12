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

/// Simple placeholder for the Practice tab.
struct PracticeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "figure.run")
                .font(.system(size: 44))
                .foregroundStyle(Theme.orange400)
            Text("Practice")
                .font(.rubik(22, .semibold))
                .foregroundStyle(Theme.gray950)
            Text("Coming soon! Daily drills with Cicero.")
                .font(.rubik(15))
                .foregroundStyle(Theme.gray600)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.cream.ignoresSafeArea())
    }
}

#Preview {
    CodexView()
        .environment(AppState())
}
