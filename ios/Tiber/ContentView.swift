import SwiftUI

/// Root flow: Splash -> Onboarding -> Sign in -> Main tabs.
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
            try? await Task.sleep(for: .seconds(2))
            splashDone = true
        }
    }
}

// MARK: - Main tabs

enum MainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case codex = "Codex"
    case rewards = "Rewards"
    case parents = "Parents"
    case profile = "Profile"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .codex: return "book.closed.fill"
        case .rewards: return "medal.fill"
        case .parents: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @State private var tab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home:
                    HomeView(onAvatarTap: { tab = .profile })
                case .codex:
                    CodexView()
                case .rewards:
                    RewardsView()
                case .parents:
                    ParentDashboardView()
                case .profile:
                    AvatarCreatorView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TiberTabBar(selected: $tab)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
        }
        .ignoresSafeArea(.keyboard)
    }
}

/// Floating white tab bar; the active tab expands into an amber pill.
struct TiberTabBar: View {
    @Binding var selected: MainTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selected = tab
                    }
                } label: {
                    if selected == tab {
                        HStack(spacing: 6) {
                            Image(systemName: tab.symbol)
                                .font(.system(size: 16, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(Theme.orange950)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(Theme.orange300))
                    } else {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Theme.gray300)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white)
                .shadow(color: Theme.gray950.opacity(0.15), radius: 10, y: 4)
        )
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
