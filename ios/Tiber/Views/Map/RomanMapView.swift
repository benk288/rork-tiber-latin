import SwiftUI

/// Map geometry in the illustration's own coordinate space (375 x 875).
/// The Figma frame showed the image offset -163pt, so absolute design
/// coordinates translate here as (x, y + 163).
enum MapGeometry {
    static let mapSize = CGSize(width: 375, height: 875)
    /// Foggy undiscovered band above the illustration.
    static let fogHeight: CGFloat = 220
    static var contentHeight: CGFloat { fogHeight + mapSize.height }

    /// Where each level's bubble sits.
    static func pill(for level: AcademyLevel) -> CGPoint {
        switch level {
        case .basilica: return CGPoint(x: 233, y: 581)   // dark bubble in the design
        case .colosseum: return CGPoint(x: 82, y: 507)   // white bubble in the design
        case .forum: return CGPoint(x: 140, y: 128)      // revealed by scrolling up
        }
    }

    /// Where the knight stands for each node.
    static func knight(for level: AcademyLevel) -> CGPoint {
        switch level {
        case .basilica: return CGPoint(x: 259, y: 612)
        case .colosseum: return CGPoint(x: 100, y: 545)
        case .forum: return CGPoint(x: 160, y: 180)
        }
    }

    /// Waypoints the knight walks through when advancing to `level`.
    static func walkPath(to level: AcademyLevel) -> [CGPoint] {
        switch level {
        case .basilica:
            return [knight(for: .basilica)]
        case .colosseum:
            return [CGPoint(x: 225, y: 598), CGPoint(x: 175, y: 570),
                    CGPoint(x: 135, y: 556), knight(for: .colosseum)]
        case .forum:
            return [CGPoint(x: 125, y: 480), CGPoint(x: 165, y: 400),
                    CGPoint(x: 200, y: 320), CGPoint(x: 185, y: 245),
                    knight(for: .forum)]
        }
    }

    /// Generous tap regions over each landmark.
    static func landmark(for level: AcademyLevel) -> CGRect {
        switch level {
        case .basilica: return CGRect(x: 40, y: 573, width: 190, height: 165)
        case .colosseum: return CGRect(x: 177, y: 415, width: 193, height: 181)
        case .forum: return CGRect(x: 85, y: 55, width: 210, height: 165)
        }
    }
}

/// The scrollable isometric world. The map is the home screen: one
/// continuous illustration with the winding path, tappable landmarks,
/// level bubbles, the knight at the current node, and ambient life.
struct RomanMapView: View {
    let selected: AcademyLevel
    let currentNode: AcademyLevel
    let knightPosition: CGPoint
    var isUnlocked: (AcademyLevel) -> Bool = { _ in true }
    var shakeTrigger: [AcademyLevel: Int] = [:]
    var onSelect: (AcademyLevel) -> Void = { _ in }

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / MapGeometry.mapSize.width
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    mapArt(scale: s)
                    ambientLife(scale: s)
                    landmarks(scale: s)
                    knight(scale: s)
                    pills(scale: s)
                    fog(scale: s)
                }
                .frame(
                    width: geo.size.width,
                    height: MapGeometry.contentHeight * s,
                    alignment: .topLeading
                )
            }
            .defaultScrollAnchor(.bottom)
            .background(Theme.orange300)
        }
        .ignoresSafeArea()
    }

    // MARK: - Layers

    private func mapArt(scale s: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            FigmaImage(name: "HomeMapIllustration", placeholder: Theme.orange300)
                .frame(width: 375 * s, height: 875 * s)

            // Colosseum overlay (design group 250:25579), above the base map.
            FigmaImage(name: "HomeColosseum")
                .frame(width: 192.28 * s, height: 180.91 * s)
                .offset(x: 177.56 * s, y: 415 * s)
        }
        .offset(y: MapGeometry.fogHeight * s)
    }

    /// Fog of undiscovered lands above the last landmark.
    private func fog(scale s: CGFloat) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    .init(color: Theme.orange100, location: 0),
                    .init(color: Theme.orange100.opacity(0.95), location: 0.55),
                    .init(color: Theme.orange100.opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: (MapGeometry.fogHeight + 130) * s)
            .overlay(alignment: .bottom) {
                FogClouds()
                    .frame(height: 120 * s)
                    .padding(.bottom, 8 * s)
            }
            Spacer(minLength: 0)
        }
        .allowsHitTesting(false)
    }

    /// Subtle idle animations: brazier flames flicker, river shimmers.
    private func ambientLife(scale s: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            FlameFlicker()
                .frame(width: 26 * s, height: 26 * s)
                .position(x: 30 * s, y: (MapGeometry.fogHeight + 448) * s)
            FlameFlicker()
                .frame(width: 26 * s, height: 26 * s)
                .position(x: 95 * s, y: (MapGeometry.fogHeight + 468) * s)
            WaterShimmer()
                .frame(width: 150 * s, height: 60 * s)
                .position(x: 130 * s, y: (MapGeometry.fogHeight + 460) * s)
            WaterShimmer(delay: 1.4)
                .frame(width: 100 * s, height: 40 * s)
                .position(x: 60 * s, y: (MapGeometry.fogHeight + 560) * s)
        }
        .allowsHitTesting(false)
    }

    /// Invisible tap targets over each landmark building.
    private func landmarks(scale s: CGFloat) -> some View {
        ForEach(AcademyLevel.pathOrder) { level in
            let rect = MapGeometry.landmark(for: level)
            Color.clear
                .contentShape(Rectangle())
                .frame(width: rect.width * s, height: rect.height * s)
                .offset(x: rect.minX * s, y: (rect.minY + MapGeometry.fogHeight) * s)
                .onTapGesture { onSelect(level) }
        }
    }

    private func knight(scale s: CGFloat) -> some View {
        FigmaImage(name: "HomeKnight")
            .frame(width: 60.85 * s, height: 72.80 * s)
            .position(
                x: (knightPosition.x + 30.4) * s,
                y: (knightPosition.y + MapGeometry.fogHeight + 36.4) * s
            )
            .allowsHitTesting(false)
    }

    private func pills(scale s: CGFloat) -> some View {
        ForEach(AcademyLevel.pathOrder) { level in
            let pt = MapGeometry.pill(for: level)
            let isCurrent = level == currentNode
            LevelPill(
                title: level.rank,
                fill: isCurrent ? Theme.maroon : .white,
                textColor: isCurrent ? .white : Theme.inkText,
                isSelected: selected == level
            ) {
                onSelect(level)
            }
            .modifier(Shake(trigger: CGFloat(shakeTrigger[level] ?? 0)))
            .scaleEffect(s, anchor: .topLeading)
            .offset(x: pt.x * s, y: (pt.y + MapGeometry.fogHeight) * s)
        }
    }
}

// MARK: - Pieces

/// Level bubble (Figma "Level"): 33pt capsule with a pointer triangle.
struct LevelPill: View {
    let title: String
    let fill: Color
    let textColor: Color
    var isSelected = false
    var action: () -> Void = {}

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: 0) {
                Text(title)
                    .font(.rubik(14, .medium))
                    .foregroundStyle(textColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(fill))
                Triangle()
                    .fill(fill)
                    .frame(width: 14, height: 8.4)
            }
            .scaleEffect(isSelected ? 1.08 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

/// Downward-pointing pill pointer (vector 17929).
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Horizontal wiggle used when a locked marker is tapped.
struct Shake: GeometryEffect {
    var trigger: CGFloat

    var animatableData: CGFloat {
        get { trigger }
        set { trigger = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: 7 * sin(trigger * .pi * 4), y: 0
        ))
    }
}

/// Soft pulsing glow over a brazier flame.
private struct FlameFlicker: View {
    @State private var bright = false

    var body: some View {
        RadialGradient(
            colors: [Theme.orange300.opacity(bright ? 0.75 : 0.3), .clear],
            center: .center,
            startRadius: 1,
            endRadius: 14
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                bright = true
            }
        }
    }
}

/// Slow-moving highlight band over the river.
private struct WaterShimmer: View {
    var delay: Double = 0
    @State private var on = false

    var body: some View {
        Capsule()
            .fill(Color.white.opacity(on ? 0.16 : 0.02))
            .rotationEffect(.degrees(-18))
            .blur(radius: 6)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.4)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    on = true
                }
            }
    }
}

/// Puffy cloud band at the fog boundary.
private struct FogClouds: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    Ellipse()
                        .fill(Theme.orange100.opacity(0.9))
                        .frame(width: w * 0.42, height: geo.size.height * 0.9)
                        .position(
                            x: w * (0.05 + Double(i) * 0.18),
                            y: geo.size.height * (i.isMultiple(of: 2) ? 0.35 : 0.6)
                        )
                        .blur(radius: 14)
                }
            }
        }
    }
}

#Preview {
    RomanMapView(
        selected: .basilica,
        currentNode: .basilica,
        knightPosition: MapGeometry.knight(for: .basilica)
    )
}
