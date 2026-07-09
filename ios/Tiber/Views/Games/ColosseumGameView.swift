import SwiftUI

/// Colosseum: swipe-matching arena for noun-adjective agreement.
struct ColosseumGameView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case intro, playing, result
    }

    private struct Bout: Identifiable {
        let id = UUID()
        let noun: LatinWord
        let adjective: LatinAdjective
        let shownForm: String
        let agrees: Bool
    }

    private struct Feedback: Equatable {
        let isCorrect: Bool
        let title: String
        let detail: String
    }

    @State private var phase: Phase = .intro
    @State private var bouts: [Bout] = []
    @State private var index: Int = 0
    @State private var correctCount: Int = 0
    @State private var coinsEarned: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var feedback: Feedback?
    @State private var startDate = Date()

    private var currentBout: Bout? {
        index < bouts.count ? bouts[index] : nil
    }

    private var nextBout: Bout? {
        index + 1 < bouts.count ? bouts[index + 1] : nil
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.orange, Theme.terracotta], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .playing:
                playingView
            case .result:
                GameResultView(
                    level: .colosseum,
                    correct: correctCount,
                    total: bouts.count,
                    coinsEarned: coinsEarned,
                    onReplay: startRound,
                    onDone: { dismiss() }
                )
            }
        }
    }

    // MARK: - Intro

    private var introView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 64))
                .foregroundStyle(Theme.cream)
                .padding(30)
                .background(Circle().fill(Theme.crimsonDeep))
                .shadow(color: Theme.ink.opacity(0.4), radius: 14, y: 8)

            Text("Colosseum")
                .font(app.font(30, weight: .heavy))
                .foregroundStyle(Theme.cream)

            CiceroBubble(text: "The arena of agreement! An adjective must wear the same armor as its noun: puella bona, equus bonus, templum bonum. Swipe right if the pair agrees - swipe left if they clash!", animated: true)
                .padding(.horizontal, 20)

            Spacer()

            Button("Enter the Arena") {
                Haptics.tap()
                startRound()
            }
            .buttonStyle(AcademyButtonStyle(color: Theme.crimsonDeep))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        VStack(spacing: 0) {
            GameHeader(
                progress: bouts.isEmpty ? 0 : Double(index) / Double(bouts.count),
                score: correctCount,
                onClose: { dismiss() }
            )
            .padding(.top, 8)

            Spacer()

            ZStack {
                if let next = nextBout {
                    boutCard(next)
                        .scaleEffect(0.94)
                        .offset(y: 14)
                        .opacity(0.6)
                }
                if let bout = currentBout {
                    boutCard(bout)
                        .offset(dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset.width) / 16))
                        .overlay(swipeStamp)
                        .gesture(swipeGesture)
                        .id(bout.id)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            if let feedback {
                FeedbackBanner(isCorrect: feedback.isCorrect, title: feedback.title, detail: feedback.detail)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            } else {
                swipeHints
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }

            actionButtons
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
    }

    private func boutCard(_ bout: Bout) -> some View {
        VStack(spacing: 14) {
            Image(systemName: bout.noun.symbol)
                .font(.system(size: 44))
                .foregroundStyle(Theme.terracotta)

            VStack(spacing: 6) {
                Text("\(bout.noun.latin) \(bout.shownForm)")
                    .font(app.font(30, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                Text("\(bout.noun.meaning) + \(bout.adjective.meaning)")
                    .font(app.font(15))
                    .foregroundStyle(Theme.brown)
            }

            Button {
                Haptics.tap()
                SpeechService.shared.speak("\(bout.noun.latin) \(bout.shownForm)")
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.orange)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Theme.parchment))
            }

            Text("Do the endings agree?")
                .font(app.font(13, weight: .semibold))
                .foregroundStyle(Theme.brown.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Theme.cream)
                .shadow(color: Theme.ink.opacity(0.3), radius: 14, y: 8)
        )
    }

    @ViewBuilder
    private var swipeStamp: some View {
        let threshold: CGFloat = 40
        if dragOffset.width > threshold {
            stamp(text: "AGREES", color: Theme.success(colorBlind: app.progress.colorBlindMode), rotation: -12)
        } else if dragOffset.width < -threshold {
            stamp(text: "CLASH", color: Theme.failure(colorBlind: app.progress.colorBlindMode), rotation: 12)
        }
    }

    private func stamp(text: String, color: Color, rotation: Double) -> some View {
        Text(text)
            .font(app.font(26, weight: .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(color, lineWidth: 3))
            .rotationEffect(.degrees(rotation))
            .opacity(min(1, Double(abs(dragOffset.width) - 40) / 60))
    }

    private var swipeHints: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                Text("Clash")
            }
            .font(app.font(13, weight: .bold))
            .foregroundStyle(Theme.cream.opacity(0.85))
            Spacer()
            HStack(spacing: 6) {
                Text("Agrees")
                Image(systemName: "arrow.right")
            }
            .font(app.font(13, weight: .bold))
            .foregroundStyle(Theme.cream.opacity(0.85))
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button {
                resolve(agrees: false)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                    Text("Clash")
                }
                .font(app.font(16, weight: .bold))
                .foregroundStyle(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(minHeight: app.minTouch)
                .background(Capsule().fill(Theme.crimsonDeep))
            }
            Button {
                resolve(agrees: true)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text("Agrees")
                }
                .font(app.font(16, weight: .bold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity)
                .frame(minHeight: app.minTouch)
                .background(Capsule().fill(Theme.gold))
            }
        }
        .disabled(feedback != nil)
    }

    // MARK: - Swipe logic

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard feedback == nil else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard feedback == nil else { return }
                if value.translation.width > 90 {
                    resolve(agrees: true)
                } else if value.translation.width < -90 {
                    resolve(agrees: false)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func resolve(agrees answer: Bool) {
        guard let bout = currentBout, feedback == nil else { return }
        let isCorrect = answer == bout.agrees
        app.recordAnswer(word: bout.noun, correct: isCorrect)
        SpeechService.shared.speak("\(bout.noun.latin) \(bout.adjective.form(for: bout.noun.category))")

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dragOffset = CGSize(width: answer ? 520 : -520, height: -40)
        }

        let correctForm = bout.adjective.form(for: bout.noun.category)
        if isCorrect {
            correctCount += 1
            Haptics.success()
        } else {
            Haptics.error()
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            feedback = Feedback(
                isCorrect: isCorrect,
                title: isCorrect ? "Victoria!" : "The crowd gasps!",
                detail: bout.agrees
                    ? "\(bout.noun.latin) \(bout.shownForm) agrees - \(bout.noun.latin) takes \(bout.noun.category.endingLabel) endings."
                    : "\(bout.noun.latin) needs \(correctForm), not \(bout.shownForm). Nouns in \(bout.noun.category.endingLabel) take \(bout.noun.category.endingLabel) adjectives."
            )
        }

        Task {
            try? await Task.sleep(for: .seconds((isCorrect ? 1.5 : 2.7) / app.progress.gameSpeed))
            advance()
        }
    }

    private func advance() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            feedback = nil
        }
        dragOffset = .zero
        if index + 1 >= bouts.count {
            finishRound()
        } else {
            index += 1
        }
    }

    // MARK: - Round lifecycle

    private func startRound() {
        let nouns = app.pickWords(from: LatinContent.nouns, count: 12)
        var built: [Bout] = []
        for (i, noun) in nouns.enumerated() {
            guard let adjective = LatinContent.adjectives.randomElement() else { continue }
            let shouldAgree = i % 2 == 0
            let correctForm = adjective.form(for: noun.category)
            let shownForm: String
            if shouldAgree {
                shownForm = correctForm
            } else {
                let wrongCategories: [WordCategory] = [.firstDeclensionA, .secondDeclensionUs, .secondDeclensionUm]
                    .filter { $0 != noun.category }
                shownForm = adjective.form(for: wrongCategories.randomElement() ?? .firstDeclensionA)
            }
            built.append(Bout(noun: noun, adjective: adjective, shownForm: shownForm, agrees: shouldAgree))
        }
        bouts = built.shuffled()
        index = 0
        correctCount = 0
        coinsEarned = 0
        dragOffset = .zero
        feedback = nil
        startDate = Date()
        phase = .playing
    }

    private func finishRound() {
        let seconds = Int(Date().timeIntervalSince(startDate))
        coinsEarned = app.recordSession(level: .colosseum, correct: correctCount, total: bouts.count, seconds: seconds)
        phase = .result
    }
}
