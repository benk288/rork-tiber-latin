import SwiftUI

/// Coins, achievement scrolls, streak, and the daily challenge.
struct RewardsView: View {
    @Environment(AppState.self) private var app

    @State private var showDailyChallenge = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.creamGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        treasuryCard
                        dailyChallengeCard
                        achievementsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Rewards")
            .sheet(isPresented: $showDailyChallenge) {
                DailyChallengeView()
                    .presentationDetents([.large])
            }
        }
    }

    private var treasuryCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Theme.gold, Theme.goldDeep], startPoint: .top, endPoint: .bottom))
                    .frame(width: 64, height: 64)
                Image(systemName: "building.columns")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.brown)
            }
            .shadow(color: Theme.goldDeep.opacity(0.5), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(app.progress.coins)")
                    .font(app.font(30, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
                Text("Bronze coins earned")
                    .font(app.font(14))
                    .foregroundStyle(Theme.brown)
            }
            Spacer()
            if app.progress.streak > 0 {
                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.crimson)
                    Text("\(app.progress.streak) day\(app.progress.streak == 1 ? "" : "s")")
                        .font(app.font(13, weight: .bold))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 24).fill(Theme.cream).shadow(color: Theme.rust.opacity(0.18), radius: 10, y: 5))
    }

    private var dailyChallengeCard: some View {
        let done = app.dailyChallengeCompletedToday
        let ready = app.learnedWords.count >= 3
        return Button {
            guard !done, ready else { return }
            Haptics.tap()
            showDailyChallenge = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: done ? "checkmark.seal.fill" : "sun.max.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(done ? Theme.success(colorBlind: app.progress.colorBlindMode) : Theme.cream)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(done ? Theme.cream : Theme.orange))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Challenge")
                        .font(app.font(17, weight: .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(done
                         ? "Completed today. Redi cras - return tomorrow!"
                         : ready
                            ? "5 quick questions from your Codex. +10 coins!"
                            : "Learn 3 words in the Academy to unlock.")
                        .font(app.font(13))
                        .foregroundStyle(Theme.brown)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if !done, ready {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.terracotta)
                }
            }
            .padding(16)
            .frame(minHeight: app.minTouch)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(done ? Theme.parchment : Theme.amber.opacity(0.55))
                    .shadow(color: Theme.rust.opacity(0.15), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievement Scrolls")
                .font(app.font(19, weight: .heavy))
                .foregroundStyle(Theme.ink)

            ForEach(AppState.achievements) { achievement in
                achievementRow(achievement)
            }
        }
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        let unlocked = app.progress.unlockedAchievements.contains(achievement.id)
        return HStack(spacing: 14) {
            Image(systemName: unlocked ? achievement.symbol : "scroll.fill")
                .font(.system(size: 20))
                .foregroundStyle(unlocked ? Theme.cream : Theme.brown.opacity(0.35))
                .frame(width: 46, height: 46)
                .background(
                    Circle().fill(unlocked
                        ? AnyShapeStyle(LinearGradient(colors: [Theme.gold, Theme.orange], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Theme.sand.opacity(0.4)))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(app.font(15, weight: .bold))
                    .foregroundStyle(unlocked ? Theme.ink : Theme.brown.opacity(0.5))
                Text(achievement.detail)
                    .font(app.font(13))
                    .foregroundStyle(Theme.brown.opacity(unlocked ? 0.85 : 0.45))
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 11))
                Text("+\(achievement.coins)")
                    .font(app.font(13, weight: .bold))
            }
            .foregroundStyle(unlocked ? Theme.goldDeep : Theme.brown.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(unlocked ? Theme.cream : Theme.parchment.opacity(0.5))
                .shadow(color: unlocked ? Theme.rust.opacity(0.15) : .clear, radius: 6, y: 3)
        )
    }
}

// MARK: - Daily challenge quiz

private struct DailyChallengeView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    private struct Question: Identifiable {
        let id = UUID()
        let word: LatinWord
        let options: [String]
    }

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var correctCount = 0
    @State private var chosen: String?
    @State private var finished = false

    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Theme.sand).frame(width: 40, height: 5).padding(.top, 10)

            if finished {
                finishedView
            } else if index < questions.count {
                quizView(questions[index])
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.cream)
        .onAppear(perform: buildQuiz)
    }

    private func quizView(_ question: Question) -> some View {
        VStack(spacing: 20) {
            Text("Question \(index + 1) of \(questions.count)")
                .font(app.font(13, weight: .bold))
                .foregroundStyle(Theme.terracotta)
                .textCase(.uppercase)

            HStack(spacing: 10) {
                Text(question.word.latin)
                    .font(app.font(32, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Button {
                    SpeechService.shared.speak(question.word.latin)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Theme.orange))
                }
            }

            Text("What does it mean?")
                .font(app.font(15))
                .foregroundStyle(Theme.brown)

            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        answer(option, question: question)
                    } label: {
                        Text(option)
                            .font(app.font(17, weight: .semibold))
                            .foregroundStyle(optionColor(option, question: question))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: app.minTouch)
                            .background(Capsule().fill(optionFill(option, question: question)))
                            .overlay(Capsule().strokeBorder(Theme.sand, lineWidth: 1.5))
                    }
                    .disabled(chosen != nil)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 16)
    }

    private var finishedView: some View {
        VStack(spacing: 18) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 54))
                .foregroundStyle(Theme.gold)
                .padding(24)
                .background(Circle().fill(Theme.ink))

            Text("Challenge Complete!")
                .font(app.font(26, weight: .heavy))
                .foregroundStyle(Theme.ink)

            Text("\(correctCount) of \(questions.count) correct - you earned \(correctCount * 2 + 10) coins!")
                .font(app.font(16))
                .foregroundStyle(Theme.brown)
                .multilineTextAlignment(.center)

            Button("Gratias, Cicero!") {
                Haptics.success()
                dismiss()
            }
            .buttonStyle(AcademyButtonStyle())
            .padding(.horizontal, 24)
        }
        .padding(.top, 30)
    }

    private func optionFill(_ option: String, question: Question) -> Color {
        guard chosen != nil else { return Theme.parchment }
        if option == question.word.meaning {
            return Theme.success(colorBlind: app.progress.colorBlindMode).opacity(0.25)
        }
        if option == chosen {
            return Theme.failure(colorBlind: app.progress.colorBlindMode).opacity(0.2)
        }
        return Theme.parchment
    }

    private func optionColor(_ option: String, question: Question) -> Color {
        guard chosen != nil else { return Theme.ink }
        if option == question.word.meaning {
            return Theme.success(colorBlind: app.progress.colorBlindMode)
        }
        return Theme.ink.opacity(option == chosen ? 1 : 0.5)
    }

    private func buildQuiz() {
        let learned = app.learnedWords.shuffled()
        let pool = learned.prefix(5)
        questions = pool.map { word in
            var options = Set([word.meaning])
            let others = LatinContent.nouns.filter { $0.latin != word.latin }.shuffled()
            for other in others where options.count < 3 {
                options.insert(other.meaning)
            }
            return Question(word: word, options: Array(options).shuffled())
        }
    }

    private func answer(_ option: String, question: Question) {
        chosen = option
        let isCorrect = option == question.word.meaning
        if isCorrect {
            correctCount += 1
            Haptics.success()
        } else {
            Haptics.error()
        }
        app.recordAnswer(word: question.word, correct: isCorrect)

        Task {
            try? await Task.sleep(for: .seconds(1.2))
            chosen = nil
            if index + 1 >= questions.count {
                app.completeDailyChallenge(correct: correctCount, total: questions.count)
                finished = true
            } else {
                index += 1
            }
        }
    }
}
