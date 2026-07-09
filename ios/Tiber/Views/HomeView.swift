import SwiftUI

/// Home (Figma "Home color option 01", node 92:1510): full-screen map with
/// the stats HUD, level pills and the floating level card above the navbar.
struct HomeView: View {
    @Environment(AppState.self) private var app
    var onAvatarTap: () -> Void = {}

    @State private var selected: AcademyLevel = .forum
    @State private var activeLevel: AcademyLevel?

    var body: some View {
        ZStack(alignment: .top) {
            RomanMapView(selected: selected) { level in
                guard app.isUnlocked(level) else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selected = level
                }
            }

            topBar

            VStack {
                Spacer()
                levelCard
                    .padding(.horizontal, 20)
                    // 16pt above the 100pt navbar, per the Content stack (129:6959).
                    .padding(.bottom, 116)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(item: $activeLevel) { level in
            switch level {
            case .forum: ForumGameView()
            case .basilica: BasilicaGameView()
            case .colosseum: ColosseumGameView()
            }
        }
        .onAppear {
            selected = AcademyLevel.allCases.last(where: { app.isUnlocked($0) }) ?? .forum
        }
    }

    // MARK: - Top Bar (92:1512)

    private var topBar: some View {
        HStack(alignment: .top) {
            // "Strike" pill: white, radius 100, px16 py8, groups spaced 24.
            HStack(spacing: 24) {
                statItem(icon: "HudCoin", fallback: "bitcoinsign.circle.fill", value: formatted(app.progress.coins))
                statItem(icon: "HudHeart", fallback: "heart.fill", value: "\(app.progress.hearts)")
                statItem(icon: "HudAmphora", fallback: "trophy.fill", value: "\(app.progress.unlockedAchievements.count)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white))

            Spacer()

            // Profile chip (176:4901): 44pt circle on #FFEEC2.
            Button {
                Haptics.tap()
                onAvatarTap()
            } label: {
                ZStack {
                    Circle().fill(Theme.avatarCircle)
                    FigmaImage(name: "HudProfile")
                        .clipShape(Circle())
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            // Scrim: black 40% fading out at ~93% of the 108pt header.
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

    // MARK: - Floating Games Info (92:1913)

    private var levelCard: some View {
        HStack {
            HStack(spacing: 10) {
                // Level Image (192:43): 68pt hexagon badge.
                FigmaImage(name: "LevelBadgeBeginner", placeholder: Theme.orange200)
                    .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 6) {
                    Text(selected.rank)
                        .font(.rubik(14, .semibold))
                        .foregroundStyle(Theme.plum)
                    Text(selected.rankDescription)
                        .font(.rubik(13))
                        .lineSpacing(13 * 0.4)
                        .foregroundStyle(Theme.gray600)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 137, alignment: .leading)
            }

            Spacer(minLength: 8)

            Button {
                Haptics.tap()
                activeLevel = selected
            } label: {
                Text("Play")
                    .font(.rubik(14, .medium))
                    .foregroundStyle(Theme.maroon)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.playCTA))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
