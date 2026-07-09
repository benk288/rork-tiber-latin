import SwiftUI

/// Four-page welcome carousel shown on first launch, mirroring the
/// "Concierge Tutorial" flow from the Tiber design file.
struct OnboardingView: View {
    @Environment(AppState.self) private var app

    @State private var page = 0

    private let pages: [(title: String, text: String)] = [
        ("Welcome to Tiber",
         "Tiber is your gateway to ancient Rome. Learn real Latin through playful lessons set in the Forum, the Basilica and the Colosseum - guided by the great orators themselves."),
        ("Tiber coins",
         "Every word you master earns you bronze coins. Spend them on outfits, accessories and rewards for your Roman avatar, and watch your treasury grow lesson after lesson."),
        ("Tribes",
         "Join a tribe of fellow learners. Practice together, share your progress and climb the weekly rankings side by side with your friends."),
        ("Online feature",
         "Your progress follows you everywhere. Sign in to sync across devices, challenge friends and compete in weekly arena events against learners across the world.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Illustration
            ZStack(alignment: .topTrailing) {
                OnboardingIllustration(page: page)
                    .id(page)
                    .transition(.opacity)

                Button {
                    Haptics.tap()
                    finish()
                } label: {
                    HStack(spacing: 4) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Theme.gray900)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.92)))
                }
                .padding(.trailing, 20)
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 340)
            .clipped()

            // Copy
            VStack(alignment: .leading, spacing: 14) {
                Text(pages[page].title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.gray950)
                Text(pages[page].text)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.gray500)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .id("copy\(page)")
            .transition(.opacity)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 28)

            Spacer()

            // Prev / position / Next
            HStack {
                Button {
                    Haptics.tap()
                    withAnimation(.easeInOut(duration: 0.25)) { page -= 1 }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                        Text("Prev")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(Theme.orange600)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(Theme.orange100))
                }
                .disabled(page == 0)
                .opacity(page == 0 ? 0.4 : 1)

                Spacer()

                Text("\(page + 1)/\(pages.count)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.gray400)

                Spacer()

                Button {
                    Haptics.tap()
                    if page == pages.count - 1 {
                        finish()
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) { page += 1 }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(Theme.orange500))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color.white.ignoresSafeArea())
        .gesture(
            DragGesture(minimumDistance: 30).onEnded { value in
                withAnimation(.easeInOut(duration: 0.25)) {
                    if value.translation.width < 0, page < pages.count - 1 {
                        page += 1
                    } else if value.translation.width > 0, page > 0 {
                        page -= 1
                    }
                }
            }
        )
    }

    private func finish() {
        Haptics.success()
        app.progress.hasOnboarded = true
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
