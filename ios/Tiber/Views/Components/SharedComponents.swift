import SwiftUI

// MARK: - Font & touch-target helpers

extension AppState {
    /// App font honoring the readable-font accessibility setting.
    func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: progress.readableFont ? .rounded : .serif)
    }

    /// Minimum touch target size honoring the larger-targets setting.
    var minTouch: CGFloat {
        progress.largeTouchTargets ? 64 : 50
    }
}

// MARK: - Cicero

/// Cicero's illustrated avatar: a bust wearing a laurel wreath.
struct CiceroAvatar: View {
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.amber, Theme.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .strokeBorder(Theme.gold, lineWidth: size * 0.05)
            Image(systemName: "person.bust.fill")
                .font(.system(size: size * 0.48, weight: .medium))
                .foregroundStyle(Theme.cream)
                .offset(y: size * 0.04)
            Image(systemName: "laurel.leading")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(Theme.laurel)
                .rotationEffect(.degrees(-24))
                .offset(x: -size * 0.18, y: -size * 0.26)
            Image(systemName: "laurel.trailing")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(Theme.laurel)
                .rotationEffect(.degrees(24))
                .offset(x: size * 0.18, y: -size * 0.26)
        }
        .frame(width: size, height: size)
        .shadow(color: Theme.ink.opacity(0.18), radius: 4, y: 2)
    }
}

/// A speech bubble from Cicero with an optional typewriter reveal.
struct CiceroBubble: View {
    @Environment(AppState.self) private var app
    let text: String
    var animated: Bool = false

    @State private var visibleCount: Int = 0

    private var shownText: String {
        animated ? String(text.prefix(visibleCount)) : text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CiceroAvatar(size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text("Cicero")
                    .font(app.font(13, weight: .bold))
                    .foregroundStyle(Theme.terracotta)
                Text(shownText)
                    .font(app.font(16))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.none, value: shownText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.cream)
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Theme.sand, lineWidth: 1.5)
            )
        }
        .task(id: text) {
            guard animated else { return }
            visibleCount = 0
            if app.progress.audioHints {
                SpeechService.shared.speak(text)
            }
            for i in 0...text.count {
                visibleCount = i
                try? await Task.sleep(for: .milliseconds(14))
            }
        }
    }
}

// MARK: - HUD pieces

struct CoinBadge: View {
    @Environment(AppState.self) private var app
    let amount: Int

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle().fill(Theme.gold)
                Circle().strokeBorder(Theme.goldDeep, lineWidth: 1.5)
                Image(systemName: "building.columns")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.brown)
            }
            .frame(width: 20, height: 20)
            Text("\(amount)")
                .font(app.font(15, weight: .bold))
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.cream.opacity(0.92))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Theme.sand, lineWidth: 1))
    }
}

struct StarRating: View {
    let stars: Int
    var size: CGFloat = 16

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i < stars ? Theme.gold : Theme.sand)
            }
        }
    }
}

// MARK: - Buttons

/// Big rounded action button in the Tiber style with a press animation.
struct AcademyButtonStyle: ButtonStyle {
    @Environment(AppState.self) private var app
    var color: Color = Theme.orange
    var textColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(app.font(17, weight: .bold))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: app.minTouch)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Haptics

enum Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
