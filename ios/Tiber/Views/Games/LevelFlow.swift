import SwiftUI
import Combine

// MARK: - Flow coordinator

/// Play flow for one level: Cicero intro -> mini-game -> complete/failed.
struct LevelFlowView: View {
    @Environment(AppState.self) private var app
    let level: AcademyLevel
    /// Called when the flow closes; true if the level was completed.
    var onDismiss: (Bool) -> Void

    private enum Stage: Equatable {
        case intro
        case game
        case complete(stars: Int, coins: Int)
        case failed
        case comingSoon
    }

    @State private var stage: Stage = .intro
    @State private var gameID = UUID()   // fresh game state per attempt

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            switch stage {
            case .intro:
                CiceroIntroView(level: level) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        stage = level == .basilica ? .game : .comingSoon
                    }
                } onClose: {
                    onDismiss(false)
                }
                .transition(.opacity)

            case .game:
                ConjugationGameView(
                    questions: CiceroCurriculum.basilicaQuestions,
                    onFinish: { heartsLeft, coinsEarned in
                        let result = app.completeLevel(level, heartsRemaining: heartsLeft, coinsEarned: coinsEarned)
                        withAnimation { stage = .complete(stars: result.stars, coins: result.coinsBanked) }
                    },
                    onFail: {
                        withAnimation { stage = .failed }
                    },
                    onQuit: { onDismiss(false) },
                    onMiss: { app.recordMiss($0) }
                )
                .id(gameID)
                .transition(.opacity)

            case .complete(let stars, let coins):
                LevelCompleteView(
                    level: level,
                    stars: stars,
                    coins: coins,
                    vocab: CiceroCurriculum.vocab(for: level),
                    fact: CiceroCurriculum.randomFact(),
                    onContinue: { onDismiss(true) },
                    onReplay: {
                        gameID = UUID()
                        withAnimation { stage = .game }
                    }
                )
                .transition(.opacity)

            case .failed:
                LevelFailedView(
                    onRetry: {
                        gameID = UUID()
                        withAnimation { stage = .game }
                    },
                    onQuit: { onDismiss(false) }
                )
                .transition(.opacity)

            case .comingSoon:
                ComingSoonView(level: level) { onDismiss(false) }
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Speaker button (pronunciation)

/// Small speaker icon next to Latin text; speaks via the synthesizer and
/// shows a brief playing state.
struct SpeakerButton: View {
    let text: String
    var size: CGFloat = 16
    @State private var playing = false

    var body: some View {
        Button {
            Haptics.tap()
            SpeechService.shared.speak(text)
            playing = true
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                playing = false
            }
        } label: {
            Image(systemName: playing ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(playing ? Theme.orange500 : Theme.gray400)
                .frame(width: size + 12, height: size + 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Hear \(text) pronounced")
    }
}

// MARK: - Screen 2: Cicero intro

/// Cicero against the level backdrop, dialogue typed out bubble by bubble.
struct CiceroIntroView: View {
    let level: AcademyLevel
    var onContinue: () -> Void
    var onClose: () -> Void

    @State private var lineIndex = 0
    @State private var typed = ""

    private var lines: [String] { level.ciceroLines }
    private var isLastLine: Bool { lineIndex == lines.count - 1 }
    private var lineFinished: Bool { typed.count == lines[lineIndex].count }

    var body: some View {
        VStack(spacing: 0) {
            // Level backdrop with Cicero.
            FigmaImage(name: "AuthIllustrationSignIn", placeholder: Theme.orange100)
                .frame(height: 302)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Button {
                        Haptics.tap()
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.gray950)
                            .padding(10)
                            .background(Circle().fill(.white.opacity(0.9)))
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Text(level.title)
                        .font(.rubik(20, .semibold))
                        .tracking(0.2)
                        .foregroundStyle(Theme.gray950)
                    Text("\u{2022} \(level.gameName)")
                        .font(.rubik(14))
                        .foregroundStyle(Theme.gray600)
                }

                // Speech bubble with typewriter text.
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cicero")
                        .font(.rubik(12, .semibold))
                        .tracking(0.5)
                        .foregroundStyle(Theme.orange500)
                        .textCase(.uppercase)
                    Text(typed)
                        .font(.rubik(16))
                        .lineSpacing(5)
                        .foregroundStyle(Theme.gray950)
                        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .overlay(alignment: .bottomTrailing) {
                    if lineFinished, !isLastLine {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.gray300)
                            .padding(14)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: advance)

                Text("Tap the bubble to continue")
                    .font(.rubik(12))
                    .foregroundStyle(Theme.gray400)
                    .frame(maxWidth: .infinity)

                Spacer()

                if isLastLine && lineFinished {
                    Button {
                        Haptics.tap()
                        onContinue()
                    } label: {
                        Text("Continue")
                            .font(.rubik(16, .semibold))
                            .tracking(0.16)
                            .foregroundStyle(Theme.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(24)
        }
        .background(Color.white.ignoresSafeArea())
        .task(id: lineIndex) { await typeCurrentLine() }
    }

    private func advance() {
        if !lineFinished {
            // Skip the typewriter for the impatient.
            typed = lines[lineIndex]
        } else if !isLastLine {
            Haptics.tap()
            lineIndex += 1
        }
    }

    private func typeCurrentLine() async {
        typed = ""
        for character in lines[lineIndex] {
            guard typed.count < lines[lineIndex].count else { break }
            typed.append(character)
            try? await Task.sleep(for: .milliseconds(24))
        }
        typed = lines[lineIndex]
    }
}

// MARK: - Screen 3: Basilica Legal Puzzle (fully playable)

struct ConjugationGameView: View {
    let questions: [ConjugationQuestion]
    var coinsPerCorrect = 10
    var timeLimit = 60
    var onFinish: (_ heartsLeft: Int, _ coinsEarned: Int) -> Void
    var onFail: () -> Void
    var onQuit: () -> Void
    /// Called on each wrong answer so mistakes feed spaced repetition.
    var onMiss: (ConjugationQuestion) -> Void = { _ in }
    /// Called on each correct answer (Practice uses it to soften miss counts).
    var onHit: (ConjugationQuestion) -> Void = { _ in }

    @State private var index = 0
    @State private var hearts = 3
    @State private var coins = 0
    @State private var timeLeft: Int = -1
    @State private var picked: String?
    @State private var showRule: String?
    @State private var goldFlash = false
    @State private var toast: String?
    @State private var locked = false
    @State private var finished = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var question: ConjugationQuestion { questions[index] }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 20) {
                hud

                // Question card
                VStack(spacing: 14) {
                    Text("Fill in the verb")
                        .font(.rubik(12, .semibold))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.orange500)

                    HStack(spacing: 6) {
                        Text(question.sentence)
                            .font(.rubik(24, .semibold))
                            .foregroundStyle(Theme.gray950)
                            .multilineTextAlignment(.center)
                        SpeakerButton(text: question.sentence.replacingOccurrences(of: "___", with: question.answer))
                    }

                    Text("\u{201C}\(question.english)\u{201D}")
                        .font(.rubik(14))
                        .foregroundStyle(Theme.gray600)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 20)
                .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))

                // Options
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(question.options, id: \.self) { option in
                        optionButton(option)
                    }
                }

                // Cicero feedback banner
                if let rule = showRule {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.orange500)
                        Text(rule)
                            .font(.rubik(14))
                            .foregroundStyle(Theme.gray950)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.orange100))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
            .padding(20)
            .padding(.top, 8)

            // Gold flash + "Optime!" on a correct answer.
            if goldFlash {
                Theme.playCTA.opacity(0.28)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
            if let toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.rubik(18, .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.maroon))
                        .padding(.bottom, 110)
                }
                .allowsHitTesting(false)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            if timeLeft < 0 { timeLeft = timeLimit }
        }
        .onReceive(timer) { _ in
            // The clock pauses while Cicero is explaining or celebrating -
            // being corrected never costs the player time.
            guard !finished, !locked, timeLeft > 0 else { return }
            timeLeft -= 1
            if timeLeft == 0 {
                finished = true
                Haptics.error()
                SoundService.shared.play(.wrong)
                onFail()
            }
        }
    }

    // MARK: HUD: hearts / progress / timer

    private var hud: some View {
        HStack(spacing: 12) {
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < hearts ? "heart.fill" : "heart")
                        .font(.system(size: 15))
                        .foregroundStyle(i < hearts ? Theme.pink500 : Theme.gray300)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.gray100)
                    Capsule()
                        .fill(Theme.primary)
                        .frame(width: geo.size.width * CGFloat(index) / CGFloat(questions.count))
                        .animation(.easeInOut(duration: 0.3), value: index)
                }
            }
            .frame(height: 10)

            Text("\(index + 1)/\(questions.count)")
                .font(.rubik(12, .medium))
                .foregroundStyle(Theme.gray600)

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 13, weight: .semibold))
                Text("\(timeLeft < 0 ? timeLimit : timeLeft)s")
                    .font(.rubik(13, .semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(timeLeft >= 0 && timeLeft <= 10 ? Theme.pink600 : Theme.gray950)
            .accessibilityLabel("Time remaining \(timeLeft < 0 ? timeLimit : timeLeft) seconds")

            Button {
                Haptics.tap()
                onQuit()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.gray600)
                    .padding(8)
                    .background(Circle().fill(Color.white))
            }
        }
    }

    // MARK: Options

    private func optionButton(_ option: String) -> some View {
        let isPicked = picked == option
        let isAnswer = option == question.answer
        let showState = picked != nil

        return Button {
            choose(option)
        } label: {
            Text(option)
                .font(.rubik(17, .medium))
                .foregroundStyle(
                    showState && isAnswer ? Theme.buttonText :
                    showState && isPicked ? Theme.pink600 : Theme.gray950
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            showState && isAnswer ? Theme.playCTA :
                            showState && isPicked ? Theme.pink50 : Color.white
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            showState && isAnswer ? Theme.orange500 :
                            showState && isPicked ? Theme.pink300 : Theme.gray100,
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(locked)
        .accessibilityLabel("Answer \(option)")
    }

    private func choose(_ option: String) {
        guard !locked, !finished else { return }
        locked = true
        picked = option

        if option == question.answer {
            Haptics.success()
            SoundService.shared.play(.correct)
            onHit(question)
            coins += coinsPerCorrect
            withAnimation(.easeOut(duration: 0.15)) {
                goldFlash = true
                toast = "Optime!  +\(coinsPerCorrect)"
            }
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                withAnimation(.easeIn(duration: 0.25)) {
                    goldFlash = false
                    toast = nil
                }
                nextQuestion()
            }
        } else {
            Haptics.error()
            SoundService.shared.play(.wrong)
            onMiss(question)
            hearts -= 1
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showRule = question.rule
            }
            Task {
                try? await Task.sleep(for: .seconds(2.2))
                guard !finished else { return }
                withAnimation { showRule = nil }
                if hearts <= 0 {
                    finished = true
                    onFail()
                } else {
                    nextQuestion()
                }
            }
        }
    }

    private func nextQuestion() {
        guard !finished else { return }
        if index + 1 >= questions.count {
            finished = true
            onFinish(hearts, coins)
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                index += 1
                picked = nil
                locked = false
            }
        }
    }
}

// MARK: - Screen 4: Level complete

struct LevelCompleteView: View {
    let level: AcademyLevel
    let stars: Int
    let coins: Int
    let vocab: [VocabWord]
    let fact: String
    var onContinue: () -> Void
    var onReplay: () -> Void

    @State private var shownStars = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Level Complete!")
                    .font(.rubik(24, .semibold))
                    .foregroundStyle(Theme.gray950)
                    .padding(.top, 40)

                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < shownStars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundStyle(i < shownStars ? Theme.playCTA : Theme.gray200)
                            .scaleEffect(i < shownStars ? 1 : 0.85)
                    }
                }

                if coins > 0 {
                    HStack(spacing: 8) {
                        if UIImage(named: "HudCoin") != nil {
                            Image("HudCoin").resizable().scaledToFit().frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "circlebadge.2.fill")
                                .foregroundStyle(Theme.playCTA)
                        }
                        Text("+\(coins) coins")
                            .font(.rubik(16, .semibold))
                            .foregroundStyle(Theme.gray950)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white))
                } else {
                    Text("Repetitio mater studiorum - practice makes perfect!")
                        .font(.rubik(13))
                        .foregroundStyle(Theme.gray600)
                }

                // New vocabulary
                VStack(alignment: .leading, spacing: 12) {
                    Text("New words in your codex")
                        .font(.rubik(14, .semibold))
                        .foregroundStyle(Theme.plum)
                    ForEach(vocab) { word in
                        HStack(spacing: 8) {
                            Text(word.latin)
                                .font(.rubik(15, .medium))
                                .foregroundStyle(Theme.gray950)
                            Text("\u{2014} \(word.english)")
                                .font(.rubik(14))
                                .foregroundStyle(Theme.gray600)
                            Spacer()
                            SpeakerButton(text: word.latin, size: 14)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))

                // Did you know?
                VStack(alignment: .leading, spacing: 8) {
                    Text("Did you know?")
                        .font(.rubik(14, .semibold))
                        .foregroundStyle(Theme.orange500)
                    Text(fact)
                        .font(.rubik(14))
                        .lineSpacing(4)
                        .foregroundStyle(Theme.gray950)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20).fill(Theme.orange100))

                VStack(spacing: 12) {
                    Button {
                        Haptics.tap()
                        onContinue()
                    } label: {
                        Text("Continue")
                            .font(.rubik(16, .semibold))
                            .tracking(0.16)
                            .foregroundStyle(Theme.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
                    }
                    Button {
                        Haptics.tap()
                        onReplay()
                    } label: {
                        Text("Replay")
                            .font(.rubik(16, .semibold))
                            .tracking(0.16)
                            .foregroundStyle(Theme.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Theme.buttonText, lineWidth: 1))
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .background(Theme.cream.ignoresSafeArea())
        .overlay(ConfettiView().allowsHitTesting(false))
        .task {
            SoundService.shared.play(.fanfare)
            for star in 1...max(1, stars) {
                try? await Task.sleep(for: .milliseconds(450))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                    shownStars = star
                }
                Haptics.success()
                SoundService.shared.play(.star)
            }
        }
    }
}

/// Lightweight celebratory confetti: gold, terracotta and cream flecks that
/// tumble down for a few seconds after the screen appears.
struct ConfettiView: View {
    private struct Fleck {
        let x: Double        // 0...1 horizontal position
        let delay: Double
        let speed: Double    // fall duration
        let size: Double
        let spin: Double
        let color: Color
    }

    private let flecks: [Fleck] = {
        let palette: [Color] = [
            Theme.playCTA, Theme.orange400, Theme.orange500,
            Theme.pink400, Theme.orange100, Theme.maroon
        ]
        return (0..<36).map { i in
            Fleck(
                x: Double.random(in: 0.02...0.98),
                delay: Double.random(in: 0...0.8),
                speed: Double.random(in: 2.2...3.6),
                size: Double.random(in: 6...11),
                spin: Double.random(in: 2...6) * (Bool.random() ? 1 : -1),
                color: palette[i % palette.count]
            )
        }
    }()

    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(start)
            Canvas { canvas, size in
                for fleck in flecks {
                    let t = elapsed - fleck.delay
                    guard t > 0, t < fleck.speed else { continue }
                    let progress = t / fleck.speed
                    let y = progress * (size.height + 40) - 20
                    let wobble = sin(t * 5 + fleck.x * 20) * 14
                    let rect = CGRect(
                        x: fleck.x * size.width + wobble,
                        y: y,
                        width: fleck.size,
                        height: fleck.size * 0.62
                    )
                    var ctx = canvas
                    ctx.translateBy(x: rect.midX, y: rect.midY)
                    ctx.rotate(by: .radians(t * fleck.spin))
                    ctx.opacity = progress > 0.85 ? (1 - progress) / 0.15 : 1
                    ctx.fill(
                        Path(roundedRect: CGRect(
                            x: -rect.width / 2, y: -rect.height / 2,
                            width: rect.width, height: rect.height
                        ), cornerRadius: 1.5),
                        with: .color(fleck.color)
                    )
                }
            }
        }
    }
}

// MARK: - Level failed

struct LevelFailedView: View {
    var onRetry: () -> Void
    var onQuit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.pink400)
            Text("Out of hearts!")
                .font(.rubik(24, .semibold))
                .foregroundStyle(Theme.gray950)
            Text("Cicero: \u{201C}Do not despair, discipule. Even Rome was not built in a day. Let us try again!\u{201D}")
                .font(.rubik(15))
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.gray600)
                .padding(.horizontal, 12)
            Spacer()
            Button {
                Haptics.tap()
                onRetry()
            } label: {
                Text("Retry")
                    .font(.rubik(16, .semibold))
                    .tracking(0.16)
                    .foregroundStyle(Theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
            }
            Button {
                Haptics.tap()
                onQuit()
            } label: {
                Text("Back to map")
                    .font(.rubik(16, .semibold))
                    .tracking(0.16)
                    .foregroundStyle(Theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Theme.buttonText, lineWidth: 1))
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Theme.cream.ignoresSafeArea())
    }
}

// MARK: - Coming soon stub (Colosseum / Forum)

struct ComingSoonView: View {
    let level: AcademyLevel
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: level.symbol)
                .font(.system(size: 48))
                .foregroundStyle(Theme.orange400)
            Text("\(level.gameName)")
                .font(.rubik(22, .semibold))
                .foregroundStyle(Theme.gray950)
            Text("Coming soon! Cicero is still preparing this lesson.")
                .font(.rubik(15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.gray600)
            Spacer()
            Button {
                Haptics.tap()
                onBack()
            } label: {
                Text("Back to map")
                    .font(.rubik(16, .semibold))
                    .tracking(0.16)
                    .foregroundStyle(Theme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Theme.primary))
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .background(Theme.cream.ignoresSafeArea())
    }
}

#Preview("Game") {
    ConjugationGameView(
        questions: CiceroCurriculum.basilicaQuestions,
        onFinish: { _, _ in },
        onFail: {},
        onQuit: {}
    )
}
