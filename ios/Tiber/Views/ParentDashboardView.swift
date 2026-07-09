import SwiftUI

/// Parent dashboard behind a simple math gate: progress, time spent,
/// accuracy per game, and words learned.
struct ParentDashboardView: View {
    @Environment(AppState.self) private var app

    @State private var unlocked = false
    @State private var gateA = Int.random(in: 6...9)
    @State private var gateB = Int.random(in: 4...8)
    @State private var gateAnswer = ""
    @State private var gateError = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.creamGradient.ignoresSafeArea()

                if unlocked {
                    dashboard
                } else {
                    gate
                }
            }
            .navigationTitle("Parents")
        }
    }

    // MARK: - Gate

    private var gate: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.terracotta)
                .padding(24)
                .background(Circle().fill(Theme.parchment))

            Text("For grown-ups")
                .font(app.font(24, weight: .heavy))
                .foregroundStyle(Theme.ink)

            Text("Solve to enter: what is \(gateA) x \(gateB)?")
                .font(app.font(16))
                .foregroundStyle(Theme.brown)

            TextField("Answer", text: $gateAnswer)
                .keyboardType(.numberPad)
                .font(app.font(22, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .frame(width: 140)
                .background(Theme.cream)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(gateError ? Theme.crimson : Theme.sand, lineWidth: 2))

            Button("Enter Dashboard") {
                if Int(gateAnswer) == gateA * gateB {
                    Haptics.success()
                    unlocked = true
                } else {
                    Haptics.error()
                    gateError = true
                    gateAnswer = ""
                    gateA = Int.random(in: 6...9)
                    gateB = Int.random(in: 4...8)
                }
            }
            .buttonStyle(AcademyButtonStyle())
            .padding(.horizontal, 60)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Dashboard

    private var dashboard: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryGrid

                levelSection

                recentSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var summaryGrid: some View {
        let minutes = app.totalPlaySeconds / 60
        let learned = app.learnedWords.count
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            statCard(symbol: "clock.fill", value: minutes < 60 ? "\(minutes) min" : String(format: "%.1f hr", Double(minutes) / 60), label: "Time playing", color: Theme.orange)
            statCard(symbol: "book.fill", value: "\(learned)", label: "Words learned", color: Theme.laurel)
            statCard(symbol: "gamecontroller.fill", value: "\(app.progress.sessions.count)", label: "Games played", color: Theme.crimson)
            statCard(symbol: "flame.fill", value: "\(app.progress.streak)", label: "Day streak", color: Theme.terracotta)
        }
    }

    private func statCard(symbol: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(app.font(22, weight: .heavy))
                .foregroundStyle(Theme.ink)
            Text(label)
                .font(app.font(12, weight: .semibold))
                .foregroundStyle(Theme.brown)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.cream).shadow(color: Theme.rust.opacity(0.12), radius: 6, y: 3))
    }

    private var levelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skill accuracy")
                .font(app.font(18, weight: .heavy))
                .foregroundStyle(Theme.ink)

            ForEach(AcademyLevel.allCases) { level in
                let accuracy = app.accuracy(for: level)
                HStack(spacing: 12) {
                    Image(systemName: level.symbol)
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.terracotta)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.parchment))

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(level.title)
                                .font(app.font(15, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text(accuracy.map { "\(Int($0 * 100))%" } ?? "Not played")
                                .font(app.font(13, weight: .semibold))
                                .foregroundStyle(Theme.brown)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Theme.sand.opacity(0.4))
                                if let accuracy {
                                    Capsule()
                                        .fill(accuracy >= 0.7 ? Theme.success(colorBlind: app.progress.colorBlindMode) : Theme.orange)
                                        .frame(width: max(6, geo.size.width * accuracy))
                                }
                            }
                        }
                        .frame(height: 8)
                    }
                    StarRating(stars: app.stars(for: level), size: 11)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 18).fill(Theme.cream).shadow(color: Theme.rust.opacity(0.1), radius: 5, y: 2))
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent sessions")
                .font(app.font(18, weight: .heavy))
                .foregroundStyle(Theme.ink)

            if app.progress.sessions.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundStyle(Theme.sand)
                    Text("No games played yet. The Forum awaits!")
                        .font(app.font(14))
                        .foregroundStyle(Theme.brown)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18).fill(Theme.cream))
            } else {
                ForEach(app.progress.sessions.suffix(6).reversed()) { session in
                    HStack {
                        Image(systemName: session.level.symbol)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.terracotta)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Theme.parchment))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(session.level.title)
                                .font(app.font(14, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Text(session.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                                .font(app.font(12))
                                .foregroundStyle(Theme.brown.opacity(0.7))
                        }
                        Spacer()
                        Text("\(session.correct)/\(session.total)")
                            .font(app.font(14, weight: .bold))
                            .foregroundStyle(Double(session.correct) / Double(max(1, session.total)) >= 0.7
                                ? Theme.success(colorBlind: app.progress.colorBlindMode)
                                : Theme.orangeDeep)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cream))
                }
            }
        }
    }
}
