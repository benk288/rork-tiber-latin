import SwiftUI

/// C000 - Contextual Tutorial (Figma section 479:4360): a four page carousel
/// with a 375x302 illustration, title + copy, Skip pill and Prev/Next bar.
struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @State private var page = 0

    private struct TutorialPage {
        let image: String
        let title: String
        let body1: String
        let body2: String
    }

    private let pages: [TutorialPage] = [
        TutorialPage(
            image: "TutorialWelcome",
            title: "Welcome to Tiber",
            body1: "Salve! Marcus Tullius Cicero - Rome's greatest speaker - has taken you on as his newest pupil.",
            body2: "Climb the winding road through ancient Rome. Every landmark hides a mini-game, and every game teaches you real Latin."
        ),
        TutorialPage(
            image: "TutorialCoins",
            title: "Tiber coins",
            body1: "Answer well and you earn coins - ten for every correct answer on your first climb through a level.",
            body2: "Hearts are your tries: three per challenge. Run out, and Cicero simply dusts you off for another attempt."
        ),
        TutorialPage(
            image: "TutorialTribes",
            title: "Your codex",
            body1: "Every word you master joins your codex - a growing treasury of Latin with meanings and pronunciation.",
            body2: "Tap the speaker on any word to hear it aloud, the way a Roman might have said it."
        ),
        TutorialPage(
            image: "TutorialOnline",
            title: "Play every day",
            body1: "Complete a level each day to grow your amphora streak - Rome was not built in a day, and neither is Latin.",
            body2: "The Practice arena remembers what tripped you up and serves it back until it sticks. Age - let us begin!"
        )
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Illustration - 375x302
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        FigmaImage(name: pages[index].image, placeholder: Theme.orange100)
                            .frame(height: 302)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 302)
                .animation(.easeInOut(duration: 0.25), value: page)

                // Title and copy: 24px below the illustration, 24px margins.
                VStack(alignment: .leading, spacing: 16) {
                    Text(pages[page].title)
                        .font(.rubik(20, .semibold))
                        .tracking(0.2)
                        .foregroundStyle(Theme.gray950)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(pages[page].body1)
                        Text(pages[page].body2)
                    }
                    .font(.rubik(14))
                    .tracking(0.14)
                    .lineSpacing(14 * 0.4)
                    .foregroundStyle(Theme.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .animation(nil, value: page)

                Spacer(minLength: 0)

                controls
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 36)
            }
            .ignoresSafeArea(edges: .top)

            // Skip pill, right-aligned in the 327pt header row (frame y 69).
            HStack {
                Spacer()
                Button {
                    Haptics.tap()
                    finish()
                } label: {
                    HStack(spacing: 8) {
                        Text("Skip")
                            .font(.rubik(14, .semibold))
                            .tracking(0.14)
                            .foregroundStyle(Theme.buttonText)
                        if UIImage(named: "IconChevronsRight") != nil {
                            Image("IconChevronsRight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.buttonText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background(Capsule().fill(Color.white))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 25) // 69 in design space minus the 44pt status bar
        }
    }

    /// Prev / page indicator / Next (Button Type 586:1380).
    private var controls: some View {
        HStack(spacing: 47) {
            Button {
                Haptics.tap()
                withAnimation { page = max(0, page - 1) }
            } label: {
                HStack(spacing: 8) {
                    if UIImage(named: "IconChevronLeft") != nil {
                        Image("IconChevronLeft")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .opacity(page == 0 ? 0.45 : 1)
                    } else {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(page == 0 ? Theme.gray400 : Theme.buttonText)
                    }
                    Text("Prev")
                        .font(.rubik(14, .semibold))
                        .tracking(0.14)
                        .foregroundStyle(page == 0 ? Theme.gray400 : Theme.buttonText)
                }
                .padding(.horizontal, 20)
                .frame(height: 48)
                .background(Capsule().fill(page == 0 ? Theme.gray100 : Theme.primary))
            }
            .disabled(page == 0)

            Text("\(page + 1)/\(pages.count)")
                .font(.rubik(12))
                .tracking(0.12)
                .foregroundStyle(Theme.gray600)
                .frame(maxWidth: .infinity)

            Button {
                Haptics.tap()
                if page == pages.count - 1 {
                    finish()
                } else {
                    withAnimation { page += 1 }
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.rubik(14, .semibold))
                        .tracking(0.14)
                        .foregroundStyle(Theme.buttonText)
                    if UIImage(named: "IconChevronRight") != nil {
                        Image("IconChevronRight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.buttonText)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 48)
                .background(Capsule().fill(Theme.primary))
            }
        }
    }

    private func finish() {
        withAnimation { app.progress.hasOnboarded = true }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
