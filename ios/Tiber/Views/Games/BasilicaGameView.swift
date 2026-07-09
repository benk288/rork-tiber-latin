import SwiftUI
import Combine

/// Basilica: timed fill-in-the-blank verb conjugation puzzles.
struct BasilicaGameView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    private enum Phase {
        case intro, playing, result
    }

    private struct Question: Identifiable {
        let id = UUID()
        let verb: LatinVerb
        let pronoun: String
        let pronounMeaning: String
        let correct: String
        let options: [String]
    }

    private struct Feedback: Equatable {
        let isCorrect: Bool
        let title: String
        let detail: String
    }

    @State private var phase: Phase = .intro
    @State private var questions: [Question] = []
    @State private var index: Int = 0
    @State private var correctCount: Int = 0
    @State private var coinsEarned: Int = 0
    @State private var feedback: Feedback?
    @State private var timeRemaining: Double = 12
    @State private var timerActive = false
    @State private var selectedOption: String?
    @State private var startDate = Date()

    private var questionTime: Double {
        12 / app.progress.gameSpeed
    }

    private var currentQuestion: Question? {
        index < questions.count ? questions[index] : nil
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.parchment, Theme.amber], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch phase {
            case .intro:
                introView
            case .playing:
                playingView
            case .result:
                GameResultView(
                    level: .basilica,
                    correct: correctCount,
                    total: questions.count,
                    coinsEarned: coinsEarned,
                    onReplay: startRound,
                    onDone: { dismiss() }
                )
            }
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            guard phase == .playing, timerActive, feedback == nil else { return }
            timeRemaining -= 0.05
            if timeRemaining <= 0 {
                timeExpired()
            }
        }
    }

    // MARK: - Intro

    private var introView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "building.columns.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.cream)
                .padding(30)
                .background(Circle().fill(Theme.rust))
                .shadow(color: Theme.rust.opacity(0.5), radius: 14, y: 8)

            Text("Basilica")
                .font(app.font(30, weight: .heavy))
                .foregroundStyle(Theme.ink)

            CiceroBubble(text: "The court is in session! A verb changes its ending to match who is acting: portO means I carry, portAS means you carry. Complete each sentence before the water clock runs dry!", animated: true)
                .padding(.horizontal, 20)

            Spacer()

            Button("Take the Floor") {
                Haptics.tap()
                startRound()
            }
            .buttonStyle(AcademyButtonStyle(color: Theme.rust))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Playing

    private var playingView: some View {
        VStack(spacing: 0) {
            GameHeader(
                progress: questions.isEmpty ? 0 : Double(index) / Double(questions.count),
                score: correctCount,
                onClose: { dismiss() }
            )
            .padding(.top, 8)

            waterClock
                .padding(.horizontal, 16)
                .padding(.top, 14)

            Spacer()

            if let question = currentQuestion {
                questionCard(question)
                    .padding(.horizontal, 16)
                    .id(question.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }

            Spacer()

            if let feedback {
                FeedbackBanner(isCorrect: feedback.isCorrect, title: feedback.title, detail: feedback.detail)
                    .padding(.horizontal, 16)
            }

            if let question = currentQuestion {
                optionsGrid(question)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
            }
        }
    }

    private var waterClock: some View {
        HStack(spacing: 8) {
            Image(systemName: "hourglass")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.rust)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.cream.opacity(0.7))
                    Capsule()
                        .fill(timeRemaining / questionTime > 0.3 ? Theme.orange : Theme.crimson)
                        .frame(width: max(8, geo.size.width * timeRemaining / questionTime))
                }
            }
            .frame(height: 10)
        }
    }

    private func questionCard(_ question: Question) -> some View {
        VStack(spacing: 14) {
            Text("Complete the sentence")
                .font(app.font(13, weight: .bold))
                .foregroundStyle(Theme.terracotta)
                .textCase(.uppercase)

            HStack(spacing: 8) {
                Text(question.pronoun)
                    .font(app.font(28, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Text(selectedOption ?? "______")
                    .font(app.font(28, weight: .heavy))
                    .foregroundStyle(selectedOption == nil ? Theme.brown.opacity(0.4) : Theme.orangeDeep)
                    .contentTransition(.opacity)
            }

            Text("\(question.pronounMeaning) \(question.verb.meaning)")
                .font(app.font(16))
                .foregroundStyle(Theme.brown)

            Button {
                Haptics.tap()
                SpeechService.shared.speak("\(question.pronoun) \(question.correct)")
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Hear it")
                }
                .font(app.font(13, weight: .semibold))
                .foregroundStyle(Theme.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.parchment))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Theme.cream)
                .shadow(color: Theme.ink.opacity(0.15), radius: 12, y: 6)
        )
    }

    private func optionsGrid(_ question: Question) -> some View {
        VStack(spacing: 10) {
            ForEach(question.options, id: \.self) { option in
                Button {
                    choose(option, for: question)
                } label: {
                    Text(option)
                        .font(app.font(19, weight: .bold))
                        .foregroundStyle(optionTextColor(option, question: question))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: app.minTouch)
                        .background(
                            Capsule().fill(optionBackground(option, question: question))
                        )
                        .overlay(Capsule().strokeBorder(Theme.sand, lineWidth: 1.5))
                }
                .disabled(feedback != nil)
            }
        }
    }

    private func optionBackground(_ option: String, question: Question) -> Color {
        guard feedback != nil else { return Theme.cream }
        if option == question.correct {
            return Theme.success(colorBlind: app.progress.colorBlindMode).opacity(0.25)
        }
        if option == selectedOption {
            return Theme.failure(colorBlind: app.progress.colorBlindMode).opacity(0.2)
        }
        return Theme.cream
    }

    private func optionTextColor(_ option: String, question: Question) -> Color {
        guard feedback != nil else { return Theme.ink }
        if option == question.correct {
            return Theme.success(colorBlind: app.progress.colorBlindMode)
        }
        return Theme.ink.opacity(option == selectedOption ? 1 : 0.5)
    }

    // MARK: - Game logic

    private func choose(_ option: String, for question: Question) {
        guard feedback == nil else { return }
        selectedOption = option
        timerActive = false
        let isCorrect = option == question.correct
        SpeechService.shared.speak("\(question.pronoun) \(question.correct)")

        if isCorrect {
            correctCount += 1
            Haptics.success()
        } else {
            Haptics.error()
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            feedback = Feedback(
                isCorrect: isCorrect,
                title: isCorrect ? "Recte dictum!" : "Almost, pupil!",
                detail: "\(question.pronoun) \(question.correct) - \(question.pronounMeaning) \(question.verb.meaning). The ending \(endingHint(for: question)) matches \(question.pronoun)."
            )
        }

        Task {
            try? await Task.sleep(for: .seconds((isCorrect ? 1.7 : 2.8) / app.progress.gameSpeed))
            advance()
        }
    }

    private func timeExpired() {
        guard feedback == nil, let question = currentQuestion else { return }
        timerActive = false
        Haptics.error()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            feedback = Feedback(
                isCorrect: false,
                title: "The water clock ran dry!",
                detail: "The answer was \(question.pronoun) \(question.correct) - \(question.pronounMeaning) \(question.verb.meaning)."
            )
        }
        Task {
            try? await Task.sleep(for: .seconds(2.8 / app.progress.gameSpeed))
            advance()
        }
    }

    private func advance() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            feedback = nil
            selectedOption = nil
            if index + 1 >= questions.count {
                finishRound()
            } else {
                index += 1
                timeRemaining = questionTime
                timerActive = true
            }
        }
    }

    private func endingHint(for question: Question) -> String {
        let stemLength = question.verb.forms[2].count - 1
        return "-" + String(question.correct.dropFirst(max(0, stemLength - 1)))
    }


    // MARK: - Round lifecycle

    private func startRound() {
        var built: [Question] = []
        let verbs = LatinContent.verbs.shuffled()
        let subjects = LatinContent.subjects.shuffled()
        for i in 0..<8 {
            let verb = verbs[i % verbs.count]
            let subject = subjects[i % subjects.count]
            let correct = verb.forms[subject.formIndex]
            var options = Set([correct])
            while options.count < 3 {
                if let random = verb.forms.randomElement() {
                    options.insert(random)
                }
            }
            built.append(Question(
                verb: verb,
                pronoun: subject.pronoun,
                pronounMeaning: subject.meaning,
                correct: correct,
                options: Array(options).shuffled()
            ))
        }
        questions = built
        index = 0
        correctCount = 0
        coinsEarned = 0
        feedback = nil
        selectedOption = nil
        timeRemaining = questionTime
        timerActive = true
        startDate = Date()
        phase = .playing
    }

    private func finishRound() {
        timerActive = false
        let seconds = Int(Date().timeIntervalSince(startDate))
        coinsEarned = app.recordSession(level: .basilica, correct: correctCount, total: questions.count, seconds: seconds)
        phase = .result
    }
}
