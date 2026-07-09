import SwiftUI

/// Root flow: Splash -> Tutorial -> Sign in -> Main tabs.
struct ContentView: View {
    @Environment(AppState.self) private var app
    @State private var splashDone = false

    var body: some View {
        ZStack {
            if !splashDone {
                SplashView()
                    .transition(.opacity)
            } else if !app.progress.hasOnboarded {
                OnboardingView()
                    .transition(.opacity)
            } else if !app.progress.isSignedIn {
                AuthFlowView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: splashDone)
        .animation(.easeInOut(duration: 0.35), value: app.progress.hasOnboarded)
        .animation(.easeInOut(duration: 0.35), value: app.progress.isSignedIn)
        .task {
            TiberFont.registerIfNeeded()
            try? await Task.sleep(for: .seconds(2))
            splashDone = true
        }
    }
}

// MARK: - Main tabs (Figma Navbar 213:8946)

enum MainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case leaderboard = "Leaderboard"
    case tutorials = "Tutorials"
    case tracker = "Tracker"
    case settings = "Settings"

    var id: String { rawValue }

    /// Figma-exported icon asset for the navbar.
    var asset: String {
        switch self {
        case .home: return "TabIconHome"
        case .leaderboard: return "TabIconLeaderboard"
        case .tutorials: return "TabIconTutorials"
        case .tracker: return "TabIconTracker"
        case .settings: return "TabIconSettings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .leaderboard: return "trophy.fill"
        case .tutorials: return "book.closed.fill"
        case .tracker: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var app
    @State private var tab: MainTab = .home
    @State private var showAvatarCreator = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home:
                    HomeView(onAvatarTap: { showAvatarCreator = true })
                case .leaderboard:
                    RewardsView()
                case .tutorials:
                    CodexView()
                case .tracker:
                    ParentDashboardView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TiberNavbar(selected: $tab)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showAvatarCreator) {
            AvatarCreatorView()
        }
    }
}

/// The design's bottom navbar (213:8956): a 100pt white bar, the active tab
/// as a 112x44 gradient pill with icon + label, other tabs as 24pt icons.
struct TiberNavbar: View {
    @Binding var selected: MainTab

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Rectangle 4: white navbar backdrop.
            if UIImage(named: "NavbarBackground") != nil {
                Image("NavbarBackground")
                    .resizable()
                    .frame(height: 100)
            } else {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 100)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
            }

            HStack(spacing: 27) {
                activePill

                HStack(spacing: 28) {
                    ForEach(MainTab.allCases.filter { $0 != selected }) { tab in
                        Button {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selected = tab
                            }
                        } label: {
                            navIcon(tab, size: 24)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 44)
            }
            .padding(.leading, 24)
            .padding(.top, 14)
        }
        .frame(height: 100, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(edges: .bottom)
    }

    private var activePill: some View {
        HStack(spacing: 0) {
            navIcon(selected, size: 36)
                .padding(.leading, 4)
            Text(selected.rawValue)
                .font(.rubik(14, .medium))
                .foregroundStyle(Theme.maroon)
                .frame(maxWidth: .infinity)
                .padding(.trailing, 8)
        }
        .frame(width: 112, height: 44)
        .background(Capsule().fill(Theme.homePillGradient))
    }

    @ViewBuilder
    private func navIcon(_ tab: MainTab, size: CGFloat) -> some View {
        if UIImage(named: tab.asset) != nil {
            Image(tab.asset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: tab.symbol)
                .font(.system(size: size * 0.66, weight: .medium))
                .foregroundStyle(tab == selected ? Theme.maroon : Theme.gray300)
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
