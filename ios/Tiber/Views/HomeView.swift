import SwiftUI

/// The Academy map: a winding road through Rome with the three level nodes.
struct HomeView: View {
    @Environment(AppState.self) private var app

    @State private var activeLevel: AcademyLevel?
    @State private var showSettings = false
    @State private var greeting: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.skyGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header

                        CiceroBubble(text: greeting, animated: true)
                            .padding(.horizontal, 16)

                        mapCard
                            .padding(.horizontal, 16)

                        funFactCard
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.ink)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(item: $activeLevel) { level in
                switch level {
                case .forum: ForumGameView()
                case .basilica: BasilicaGameView()
                case .colosseum: ColosseumGameView()
                }
            }
            .onAppear { refreshGreeting() }
        }
    }

    private func refreshGreeting() {
        let name = app.progress.playerName
        let learned = app.learnedWords.count
        if learned == 0 {
            greeting = "Salve, \(name)! Rome awaits. Let us begin at the Forum, where every merchant knows their endings!"
        } else if !app.isUnlocked(.basilica) {
            greeting = "Back again, \(name)? Excellent. Earn a star at the Forum and the Basilica's doors will open to you."
        } else if !app.isUnlocked(.colosseum) {
            greeting = "Well done, \(name)! The courts of the Basilica await your verbs. The crowd at the Colosseum is already whispering your name..."
        } else {
            greeting = "Ah, \(name), \(learned) words in your Codex already! Even my rival Hortensius would be impressed."
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cicero's Academy")
                    .font(app.font(26, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Ave, \(app.progress.playerName)!")
                    .font(app.font(15, weight: .semibold))
                    .foregroundStyle(Theme.brown)
            }
            Spacer()
            HStack(spacing: 8) {
                if app.progress.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.crimson)
                        Text("\(app.progress.streak)")
                            .font(app.font(15, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.cream.opacity(0.92))
                    .clipShape(Capsule())
                }
                CoinBadge(amount: app.progress.coins)
            }
        }
        .padding(.horizontal, 16)
    }

    private var mapCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(AcademyLevel.allCases.enumerated()), id: \.element) { index, level in
                LevelNode(
                    level: level,
                    index: index,
                    isUnlocked: app.isUnlocked(level),
                    stars: app.stars(for: level),
                    alignLeft: index % 2 == 0
                ) {
                    Haptics.tap()
                    activeLevel = level
                }
                if index < AcademyLevel.allCases.count - 1 {
                    RoadSegment(flip: index % 2 == 1)
                        .frame(height: 56)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Theme.creamGradient)
                .shadow(color: Theme.rust.opacity(0.25), radius: 12, y: 6)
        )
    }

    private var funFactCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.max.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.gold)
                .padding(10)
                .background(Circle().fill(Theme.ink))
            VStack(alignment: .leading, spacing: 4) {
                Text("Did you know?")
                    .font(app.font(14, weight: .bold))
                    .foregroundStyle(Theme.terracotta)
                Text(dailyFact)
                    .font(app.font(15))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cream)
                .shadow(color: Theme.rust.opacity(0.18), radius: 8, y: 4)
        )
    }

    private var dailyFact: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return LatinContent.romanFacts[day % LatinContent.romanFacts.count]
    }
}

// MARK: - Level node

private struct LevelNode: View {
    @Environment(AppState.self) private var app
    let level: AcademyLevel
    let index: Int
    let isUnlocked: Bool
    let stars: Int
    let alignLeft: Bool
    let action: () -> Void

    @State private var pulse = false

    private var isNext: Bool {
        isUnlocked && stars == 0
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if !alignLeft { Spacer(minLength: 0) }

                ZStack {
                    Circle()
                        .fill(isUnlocked ? AnyShapeStyle(LinearGradient(colors: [Theme.gold, Theme.orange], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(Theme.sand.opacity(0.6)))
                        .frame(width: 74, height: 74)
                        .shadow(color: isUnlocked ? Theme.orange.opacity(0.45) : .clear, radius: pulse ? 14 : 6)
                    Circle()
                        .strokeBorder(isUnlocked ? Theme.goldDeep : Theme.sand, lineWidth: 3)
                        .frame(width: 74, height: 74)
                    Image(systemName: isUnlocked ? level.symbol : "lock.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(isUnlocked ? Theme.ink : Theme.brown.opacity(0.5))
                }
                .scaleEffect(isNext && pulse ? 1.06 : 1)

                VStack(alignment: alignLeft ? .leading : .trailing, spacing: 3) {
                    Text(level.title)
                        .font(app.font(18, weight: .heavy))
                        .foregroundStyle(isUnlocked ? Theme.ink : Theme.brown.opacity(0.5))
                    Text(isUnlocked ? level.skill : "Earn a star to unlock")
                        .font(app.font(13))
                        .foregroundStyle(Theme.brown.opacity(isUnlocked ? 0.85 : 0.5))
                        .multilineTextAlignment(alignLeft ? .leading : .trailing)
                    StarRating(stars: stars, size: 13)
                }

                if alignLeft { Spacer(minLength: 0) }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .frame(minHeight: app.minTouch)
        .onAppear {
            guard isNext else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// Dashed cobblestone road connecting level nodes.
private struct RoadSegment: View {
    let flip: Bool

    var body: some View {
        Canvas { context, size in
            var path = Path()
            let startX = flip ? size.width * 0.78 : size.width * 0.22
            let endX = flip ? size.width * 0.22 : size.width * 0.78
            path.move(to: CGPoint(x: startX, y: 0))
            path.addCurve(
                to: CGPoint(x: endX, y: size.height),
                control1: CGPoint(x: startX, y: size.height * 0.6),
                control2: CGPoint(x: endX, y: size.height * 0.4)
            )
            context.stroke(
                path,
                with: .color(Theme.amber),
                style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [1, 16])
            )
        }
    }
}
