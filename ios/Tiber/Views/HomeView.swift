import SwiftUI

/// Home: the full-screen Roman academy map with the stats HUD on top and
/// the selected-level card floating above the tab bar.
struct HomeView: View {
    @Environment(AppState.self) private var app
    var onAvatarTap: () -> Void = {}

    @State private var selected: AcademyLevel = .forum
    @State private var activeLevel: AcademyLevel?

    var body: some View {
        ZStack {
            RomanMapView(selected: selected) { level in
                guard app.isUnlocked(level) else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selected = level
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                hud
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                Spacer()
                levelCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 88)
            }
        }
        .fullScreenCover(item: $activeLevel) { level in
            switch level {
            case .forum: ForumGameView()
            case .basilica: BasilicaGameView()
            case .colosseum: ColosseumGameView()
            }
        }
        .onAppear {
            // Start on the furthest unlocked level.
            selected = AcademyLevel.allCases.last(where: { app.isUnlocked($0) }) ?? .forum
        }
    }

    // MARK: - HUD

    private var hud: some View {
        HStack(spacing: 8) {
            HUDPill(value: app.progress.coins.formatted()) {
                ZStack {
                    Circle().fill(Theme.yellow400)
                    Circle().strokeBorder(Theme.yellow600, lineWidth: 1.5)
                    Image(systemName: "building.columns")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.yellow700)
                }
                .frame(width: 18, height: 18)
            }
            HUDPill(value: "\(app.progress.hearts)") {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.pink500)
            }
            HUDPill(value: "\(app.progress.unlockedAchievements.count)") {
                Image(systemName: "medal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.yellow600)
            }

            Spacer()

            Button {
                Haptics.tap()
                onAvatarTap()
            } label: {
                AvatarBustView(config: app.progress.avatar, size: 42)
            }
        }
    }

    // MARK: - Level card

    private var levelCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.yellow400, Theme.orange500],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Theme.orange500.opacity(0.4), radius: 4, y: 2)
                HStack(spacing: -3) {
                    Image(systemName: "laurel.leading")
                    Image(systemName: "laurel.trailing")
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(selected.rank)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.gray950)
                Text(selected.rankDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.gray500)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button {
                Haptics.tap()
                activeLevel = selected
            } label: {
                Text("Play")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(Theme.orange400))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Theme.orange900.opacity(0.25), radius: 12, y: 6)
        )
    }
}

/// Small white stat capsule in the map HUD.
private struct HUDPill<Icon: View>: View {
    let value: String
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        HStack(spacing: 5) {
            icon()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.gray950)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.white.opacity(0.95)))
        .shadow(color: Theme.orange900.opacity(0.2), radius: 3, y: 2)
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
