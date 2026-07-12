import SwiftUI

/// Home: the scrollable academy map with the pinned HUD, the pinned level
/// card, and the knight marking the player's current node.
struct HomeView: View {
    @Environment(AppState.self) private var app
    var onAvatarTap: () -> Void = {}

    @State private var selected: AcademyLevel = .basilica
    @State private var playing: AcademyLevel?
    @State private var knightPosition = MapGeometry.knight(for: .basilica)
    @State private var shakeTrigger: [AcademyLevel: Int] = [:]

    var body: some View {
        ZStack(alignment: .top) {
            RomanMapView(
                selected: selected,
                currentNode: app.currentNode,
                knightPosition: knightPosition,
                isUnlocked: { app.isUnlocked($0) },
                shakeTrigger: shakeTrigger,
                onSelect: select
            )

            topBar

            VStack {
                Spacer()
                levelCard
                    .padding(.horizontal, 20)
                    // 16pt above the 100pt navbar (Content stack 129:6959).
                    .padding(.bottom, 116)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(item: $playing) { level in
            LevelFlowView(level: level) { didComplete in
                playing = nil
                if didComplete {
                    advanceKnightIfNeeded()
                }
            }
        }
        .onAppear {
            selected = app.currentNode
            knightPosition = MapGeometry.knight(for: app.currentNode)
        }
    }

    // MARK: - Interactions

    private func select(_ level: AcademyLevel) {
        Haptics.tap()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selected = level
        }
        if !app.isUnlocked(level) {
            withAnimation(.linear(duration: 0.4)) {
                shakeTrigger[level, default: 0] += 1
            }
        }
    }

    /// After a completion, walk the knight along the path to the newly
    /// current node and select it.
    private func advanceKnightIfNeeded() {
        let node = app.currentNode
        guard MapGeometry.knight(for: node) != knightPosition else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            for point in MapGeometry.walkPath(to: node) {
                withAnimation(.easeInOut(duration: 0.55)) {
                    knightPosition = point
                }
                try? await Task.sleep(for: .milliseconds(560))
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selected = node
            }
        }
    }

    // MARK: - Top Bar (92:1512)

    private var topBar: some View {
        HStack(alignment: .top) {
            HStack(spacing: 24) {
                statItem(icon: "HudCoin", fallback: "bitcoinsign.circle.fill", value: formatted(app.progress.coins))
                statItem(icon: "HudHeart", fallback: "heart.fill", value: "\(app.progress.hearts)")
                statItem(icon: "HudAmphora", fallback: "trophy.fill", value: "\(app.progress.amphorae)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white))

            Spacer()

            Button {
                Haptics.tap()
                onAvatarTap()
            } label: {
                AvatarBustView(config: app.progress.avatar, size: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.4), location: 0),
                    .init(color: .black.opacity(0.4), location: 0.486),
                    .init(color: .black.opacity(0), location: 0.93)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private func statItem(icon: String, fallback: String, value: String) -> some View {
        HStack(spacing: 6) {
            if UIImage(named: icon) != nil {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            } else {
                Image(systemName: fallback)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.orange400)
                    .frame(width: 28, height: 28)
            }
            Text(value)
                .font(.rubik(14))
                .foregroundStyle(Theme.inkText)
                .contentTransition(.numericText())
        }
    }

    /// Formats like the design's "2.451" (dot as thousands separator).
    private func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // MARK: - Floating level card (92:1913)

    private var locked: Bool { !app.isUnlocked(selected) }

    private var levelCard: some View {
        HStack {
            HStack(spacing: 10) {
                levelBadge
                    .frame(width: 68, height: 68)
                    .grayscale(locked ? 1 : 0)
                    .opacity(locked ? 0.6 : 1)

                VStack(alignment: .leading, spacing: 6) {
                    Text(selected.rank)
                        .font(.rubik(14, .semibold))
                        .foregroundStyle(locked ? Theme.gray400 : Theme.plum)
                    Text(locked ? "Complete the previous level to unlock" : selected.rankDescription)
                        .font(.rubik(13))
                        .lineSpacing(13 * 0.4)
                        .foregroundStyle(locked ? Theme.gray400 : Theme.gray600)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 137, alignment: .leading)
            }

            Spacer(minLength: 8)

            if locked {
                ZStack {
                    Circle().fill(Theme.gray100)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.gray400)
                }
                .frame(width: 40, height: 40)
            } else {
                Button {
                    Haptics.tap()
                    playing = selected
                } label: {
                    Text("Play")
                        .font(.rubik(14, .medium))
                        .foregroundStyle(Theme.maroon)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Theme.playCTA))
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
        .animation(.easeInOut(duration: 0.2), value: selected)
        .animation(.easeInOut(duration: 0.2), value: locked)
    }

    /// Exported hexagon badge, with a drawn stand-in until assets download.
    @ViewBuilder
    private var levelBadge: some View {
        if UIImage(named: "LevelBadgeBeginner") != nil {
            Image("LevelBadgeBeginner")
                .resizable()
                .scaledToFit()
        } else {
            ZStack {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.orange300, Theme.orange500],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Image(systemName: selected.symbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
