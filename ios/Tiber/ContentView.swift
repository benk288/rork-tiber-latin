import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        TabView {
            Tab("Academy", systemImage: "map.fill") {
                HomeView()
            }
            Tab("Codex", systemImage: "book.closed.fill") {
                CodexView()
            }
            Tab("Rewards", systemImage: "medal.fill") {
                RewardsView()
            }
            Tab("Parents", systemImage: "chart.bar.fill") {
                ParentDashboardView()
            }
        }
        .tint(Theme.terracotta)
        .fullScreenCover(isPresented: .init(
            get: { !app.progress.hasOnboarded },
            set: { app.progress.hasOnboarded = !$0 }
        )) {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
