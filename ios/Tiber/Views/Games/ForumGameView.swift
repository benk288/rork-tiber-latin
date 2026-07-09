import SwiftUI

/// Forum Romanum: drag goods to the correct merchant's stall by noun ending.
struct ForumGameView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case intro, playing, result
    }

    private struct Feedback: Equatable {
        let isCorrect: Bool
        let title: String
        let detail: String
    }

    @State private var phase: Phase = .intro
    @State private var deck: [LatinWord] = []
    @State private var index: Int = 0
    @State private var correctCount: Int = 0
    @State private var coinsEarned: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var feedback: Feedback?
    @State private var cardShake: Bool = false
    @State private var startDate = Date()
    @State private var hoveredStall: WordCategory?

    private let stalls: [WordCategory] = [.firstDeclensionA, .secondDeclensionUs, .secondDeclensionUm]

    private var currentWord: LatinWord? {
        index < deck.count ? deck[index] : nil
    }

    var body: some View {
        ZStack {
            Theme.skyGradient.ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .playing:
                playingView
            case .result:
                GameResultView(
                    level: .forum,
                    correct: correctCount,
                    total: deck.count,
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
            Image(systemName: "basket.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.cream)
                .padding(30)
                .background(Circle().fill(Theme.terracotta))
                .shadow(color: Theme.rust.opacity(0.5), radius: 14, y: 8)

            Text("Forum Romanum")
                .font(app.font(30, weight: .heavy))
                .foregroundStyle(Theme.ink)

            CiceroBubble(text: "Welcome to the market! Every noun belongs at a stall: words ending in -a with the amphorae, -us with the horses, -um with the temple goods. Drag each word to its stall!", animated: true)
                .padding(.horizontal, 20)

            Spacer()

            Button("Open the Stalls") {
                Haptics.tap()
                startRound()
            }
            .buttonStyle(AcademyButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                GameHeader(
                    progress: deck.isEmpty ? 0 : Double(index) / Double(deck.count),
                    score: correctCount,
                    onClose: { dismiss() }
                )
                .padding(.top, 8)

                Spacer()

                if let word = currentWord {
                    wordCard(word)
                        .offset(dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset.width) / 22))
                        .offset(x: cardShake ? -9 : 0)
                        .gesture(dragGesture(in: geo.size))
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: dragOffset == .zero)
                        .zIndex(2)
                }

                Spacer()

                if let feedback {
                    FeedbackBanner(isCorrect: feedback.isCorrect, title: feedback.title, detail: feedback.detail)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                }

                stallsRow
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
            }
        }
    }

    private func wordCard(_ word: LatinWord) -> some View {
        VStack(spacing: 10) {
            Image(systemName: word.symbol)
                .font(.system(size: 40))
                .foregroundStyle(Theme.terracotta)

            HStack(spacing: 8) {
                Text(word.latin)
                    .font(app.font(30, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Button {
                    Haptics.tap()
                    SpeechService.shared.speak(word.latin)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.orange)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Theme.parchment))
                }
            }

            Text(word.meaning)
                .font(app.font(16))
                .foregroundStyle(Theme.brown)

            HStack(spacing: 5) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 12))
                Text("Drag me to a stall")
                    .font(app.font(12, weight: .semibold))
            }
            .foregroundStyle(Theme.brown.opacity(0.55))
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 34)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Theme.cream)
                .shadow(color: Theme.ink.opacity(isDragging ? 0.3 : 0.18), radius: isDragging ? 18 : 10, y: 8)
        )
        .scaleEffect(isDragging ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }

    private var stallsRow: some View {
        HStack(spacing: 10) {
            ForEach(stalls, id: \.self) { stall in
                stallView(stall)
            }
        }
    }

    private func stallView(_ stall: WordCategory) -> some View {
        let isHovered = hoveredStall == stall
        return VStack(spacing: 6) {
            // Awning
            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { i in
                    UnevenRoundedRectangle(bottomLeadingRadius: 6, bottomTrailingRadius: 6)
                        .fill(i % 2 == 0 ? Theme.terracotta : Theme.cream)
                        .frame(height: 14)
                }
            }
            .clipShape(.rect(cornerRadius: 4))

            Image(systemName: stallSymbol(stall))
                .font(.system(size: 24))
                .foregroundStyle(Theme.brown)

            Text(stall.endingLabel)
                .font(app.font(24, weight: .heavy))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: app.progress.largeTouchTargets ? 128 : 110)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isHovered ? Theme.gold : Theme.parchment)
                .shadow(color: Theme.rust.opacity(isHovered ? 0.5 : 0.25), radius: isHovered ? 12 : 6, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(isHovered ? Theme.goldDeep : Theme.sand, lineWidth: 2)
        )
        .scaleEffect(isHovered ? 1.06 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
    }

    private func stallSymbol(_ stall: WordCategory) -> String {
        switch stall {
        case .firstDeclensionA: return "drop.fill"
        case .secondDeclensionUs: return "figure.equestrian.sports"
        default: return "building.columns.fill"
        }
    }

    // MARK: - Drag logic

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard feedback == nil else { return }
                isDragging = true
                dragOffset = value.translation
                hoveredStall = stallUnderDrag(value.translation, in: size)
            }
            .onEnded { value in
                isDragging = false
                let target = stallUnderDrag(value.translation, in: size)
                hoveredStall = nil
                if let target {
                    resolveDrop(on: target)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    /// The card starts near the vertical center; a stall is targeted when the
    /// drag ends low on the screen, in the matching horizontal third.
    private func stallUnderDrag(_ translation: CGSize, in size: CGSize) -> WordCategory? {
        guard translation.height > size.height * 0.18 else { return nil }
        let finalX = size.width / 2 + translation.width
        let third = size.width / 3
        let column = min(2, max(0, Int(finalX / third)))
        return stalls[column]
    }

    private func resolveDrop(on stall: WordCategory) {
        guard let word = currentWord, feedback == nil else { return }
        let isCorrect = word.category == stall
        app.recordAnswer(word: word, correct: isCorrect)
        SpeechService.shared.speak(word.latin)

        if isCorrect {
            correctCount += 1
            Haptics.success()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                feedback = Feedback(
                    isCorrect: true,
                    title: "Optime! \(word.latin) is sold!",
                    detail: "\(word.latin.capitalized) (\(word.meaning)) ends in \(word.category.endingLabel) - \(word.category.displayName)."
                )
                dragOffset = CGSize(width: dragOffset.width, height: 500)
            }
        } else {
            Haptics.error()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                dragOffset = .zero
            }
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(4)) {
                cardShake.toggle()
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                feedback = Feedback(
                    isCorrect: false,
                    title: "Not quite, pupil!",
                    detail: "Look at the ending: \(word.latin) ends in \(word.category.endingLabel), so it belongs at the \(word.category.endingLabel) stall. Try the next one!"
                )
            }
        }

        Task {
            try? await Task.sleep(for: .seconds((isCorrect ? 1.6 : 2.6) / app.progress.gameSpeed))
            advance(afterCorrect: isCorrect)
        }
    }

    private func advance(afterCorrect: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            feedback = nil
        }
        dragOffset = .zero
        if index + 1 >= deck.count {
            finishRound()
        } else {
            index += 1
        }
    }

    // MARK: - Round lifecycle

    private func startRound() {
        deck = app.pickWords(from: LatinContent.nouns, count: 10)
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
        coinsEarned = app.recordSession(level: .forum, correct: correctCount, total: deck.count, seconds: seconds)
        phase = .result
    }
}
