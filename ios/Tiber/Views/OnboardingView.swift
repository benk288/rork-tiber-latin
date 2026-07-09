import SwiftUI

/// Story-mode welcome: Cicero greets his newest pupil across a few
/// beautifully staged pages.
struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var page: Int = 0
    @State private var name: String = ""

    private let pages: [(symbol: String, title: String, text: String)] = [
        ("building.columns.fill", "Salve! Welcome to Rome",
         "I am Marcus Tullius Cicero - orator, consul, and now... your magister! You have just arrived in the greatest city in the world."),
        ("basket.fill", "Learn by Playing",
         "Forget dusty scrolls. We shall learn Latin in the Forum's market stalls, the Basilica's courts, and even the Colosseum's arena!"),
        ("book.closed.fill", "Collect Every Word",
         "Each word you master joins your Codex - your personal treasury of Latin. Earn bronze coins, achievement scrolls, and glory!")
    ]

    var body: some View {
        ZStack {
            Theme.skyGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                illustration
                    .frame(height: 260)

                VStack(spacing: 20) {
                    if page < pages.count {
                        VStack(spacing: 12) {
                            Text(pages[page].title)
                                .font(app.font(28, weight: .heavy))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.center)
                            Text(pages[page].text)
                                .font(app.font(17))
                                .foregroundStyle(Theme.brown)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .id(page)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))

                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { i in
                                Capsule()
                                    .fill(i == page ? Theme.orange : Theme.sand)
                                    .frame(width: i == page ? 24 : 8, height: 8)
                            }
                        }

                        Button(page == pages.count - 1 ? "One Last Thing" : "Next") {
                            Haptics.tap()
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                page += 1
                            }
                        }
                        .buttonStyle(AcademyButtonStyle())
                    } else {
                        namePage
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32)
                        .fill(Theme.cream)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }

    private var namePage: some View {
        VStack(spacing: 16) {
            Text("What shall I call you, pupil?")
                .font(app.font(26, weight: .heavy))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)

            TextField("Your name", text: $name)
                .font(app.font(18, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .background(Theme.parchment)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Theme.sand, lineWidth: 1.5))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()

            Button("Enter the Academy") {
                Haptics.success()
                let trimmed = name.trimmingCharacters(in: .whitespaces)
                app.progress.playerName = trimmed.isEmpty ? "Discipulus" : trimmed
                app.progress.hasOnboarded = true
                dismiss()
            }
            .buttonStyle(AcademyButtonStyle())

            Text("You can change accessibility settings anytime from the Academy map.")
                .font(app.font(13))
                .foregroundStyle(Theme.brown.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var illustration: some View {
        ZStack {
            // Sun glow
            Circle()
                .fill(
                    RadialGradient(colors: [Theme.gold.opacity(0.55), .clear], center: .center, startRadius: 10, endRadius: 160)
                )
                .frame(width: 320, height: 320)

            // Temple silhouette
            VStack(spacing: 0) {
                Triangle()
                    .fill(Theme.cream.opacity(0.9))
                    .frame(width: 190, height: 44)
                Rectangle()
                    .fill(Theme.cream.opacity(0.9))
                    .frame(width: 200, height: 10)
                HStack(spacing: 14) {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.cream.opacity(0.9))
                            .frame(width: 14, height: 84)
                    }
                }
                Rectangle()
                    .fill(Theme.cream.opacity(0.9))
                    .frame(width: 200, height: 12)
            }
            .shadow(color: Theme.rust.opacity(0.35), radius: 12, y: 8)
            .offset(y: 26)

            CiceroAvatar(size: page >= pages.count ? 120 : 96)
                .offset(y: -76)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: page)

            if page < pages.count {
                Image(systemName: pages[page].symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .padding(14)
                    .background(Circle().fill(Theme.gold))
                    .overlay(Circle().strokeBorder(Theme.goldDeep, lineWidth: 2))
                    .offset(x: 76, y: -104)
                    .transition(.scale.combined(with: .opacity))
                    .id("badge\(page)")
            }
        }
    }
}

/// Simple triangle shape for the temple pediment.
struct Triangle: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
