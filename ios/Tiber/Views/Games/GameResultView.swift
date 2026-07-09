import SwiftUI

/// Shared end-of-round screen: stars, coins, Cicero's verdict, and a
/// "Did you know?" Roman fact.
struct GameResultView: View {
    @Environment(AppState.self) private var app

    let level: AcademyLevel
    let correct: Int
    let total: Int
    let coinsEarned: Int
    let onReplay: () -> Void
    let onDone: () -> Void

    @State private var revealedStars: Int = 0
    @State private var fact: String = LatinContent.randomFact()

    private var starsEarned: Int {
        let ratio = total > 0 ? Double(correct) / Double(total) : 0
        return ratio >= 0.9 ? 3 : ratio >= 0.7 ? 2 : ratio >= 0.5 ? 1 : 0
    }

    private var ciceroVerdict: String {
        switch starsEarned {
        case 3: return "Magnificum! Not even the Senate could argue with a performance like that."
        case 2: return "Bene factum! A fine showing - one more round and you shall be flawless."
        case 1: return "A good start, pupil. Even I stumbled over my first declensions. Again!"
        default: return "Do not lose heart! Every great orator began exactly where you stand. Shall we try once more?"
        }
    }

    var body: some View {
        ZStack {
            Theme.skyGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    Text(level.title)
                        .font(app.font(24, weight: .heavy))
                        .foregroundStyle(Theme.ink)
                        .padding(.top, 24)

                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < revealedStars ? "star.fill" : "star")
                                .font(.system(size: 46))
                                .foregroundStyle(i < revealedStars ? Theme.gold : Theme.cream.opacity(0.6))
                                .scaleEffect(i < revealedStars ? 1 : 0.8)
                                .shadow(color: i < revealedStars ? Theme.goldDeep.opacity(0.6) : .clear, radius: 8)
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: revealedStars)

                    VStack(spacing: 14) {
                        HStack(spacing: 24) {
                            resultStat(value: "\(correct)/\(total)", label: "Correct", symbol: "checkmark.seal.fill", color: Theme.success(colorBlind: app.progress.colorBlindMode))
                            resultStat(value: "+\(coinsEarned)", label: "Coins", symbol: "circle.hexagongrid.fill", color: Theme.goldDeep)
                        }

                        CiceroBubble(text: ciceroVerdict)
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Theme.cream))
                    .padding(.horizontal, 16)

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.max.fill")
                            .foregroundStyle(Theme.gold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Did you know?")
                                .font(app.font(13, weight: .bold))
                                .foregroundStyle(Theme.gold)
                            Text(fact)
                                .font(app.font(14))
                                .foregroundStyle(Theme.cream)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Theme.ink.opacity(0.85)))
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        Button("Play Again") {
                            Haptics.tap()
                            onReplay()
                        }
                        .buttonStyle(AcademyButtonStyle(color: Theme.orange))

                        Button("Back to the Academy") {
                            Haptics.tap()
                            onDone()
                        }
                        .buttonStyle(AcademyButtonStyle(color: Theme.cream, textColor: Theme.ink))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .task {
            if app.progress.audioHints {
                SpeechService.shared.speak(ciceroVerdict)
            }
            for i in 1...max(starsEarned, 0) {
                try? await Task.sleep(for: .milliseconds(450))
                revealedStars = i
                Haptics.success()
            }
        }
    }

    private func resultStat(value: String, label: String, symbol: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(color)
            Text(value)
                .font(app.font(22, weight: .heavy))
                .foregroundStyle(Theme.ink)
            Text(label)
                .font(app.font(12, weight: .semibold))
                .foregroundStyle(Theme.brown)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shared in-game header

/// Close button + progress bar + live score used by all three games.
struct GameHeader: View {
    @Environment(AppState.self) private var app
    let progress: Double
    let score: Int
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Theme.cream.opacity(0.92)))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.cream.opacity(0.5))
                    Capsule()
                        .fill(Theme.gold)
                        .frame(width: max(12, geo.size.width * progress))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 12)

            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.goldDeep)
                Text("\(score)")
                    .font(app.font(15, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.cream.opacity(0.92)))
        }
        .padding(.horizontal, 16)
    }
}

/// Correct / incorrect feedback banner with a teaching explanation.
struct FeedbackBanner: View {
    @Environment(AppState.self) private var app
    let isCorrect: Bool
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "arrow.uturn.backward.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(isCorrect
                    ? Theme.success(colorBlind: app.progress.colorBlindMode)
                    : Theme.failure(colorBlind: app.progress.colorBlindMode))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(app.font(16, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(app.font(14))
                    .foregroundStyle(Theme.brown)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.cream))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    isCorrect
                        ? Theme.success(colorBlind: app.progress.colorBlindMode).opacity(0.5)
                        : Theme.failure(colorBlind: app.progress.colorBlindMode).opacity(0.5),
                    lineWidth: 2
                )
        )
        .shadow(color: Theme.ink.opacity(0.15), radius: 10, y: 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
