import SwiftUI

/// The full-screen Roman world map behind the home screen: golden terrain,
/// a river with a bridge, a winding road, the Colosseum, temples and trees,
/// with a tappable level pill at each stop on the road.
struct RomanMapView: View {
    @Environment(AppState.self) private var app
    let selected: AcademyLevel
    let onSelect: (AcademyLevel) -> Void

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ArtImage(name: "MapArt") { drawnScenery(size: size) }

                // Level stops
                ForEach(AcademyLevel.allCases) { level in
                    MapLevelPill(
                        level: level,
                        isSelected: level == selected,
                        isUnlocked: app.isUnlocked(level)
                    ) {
                        onSelect(level)
                    }
                    .position(position(for: level, in: size))
                }
            }
        }
    }

    private func drawnScenery(size: CGSize) -> some View {
            ZStack {
                // Terrain
                LinearGradient(
                    colors: [Theme.yellow300, Theme.orange300, Theme.orange400],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Ellipse()
                    .fill(Theme.yellow200.opacity(0.45))
                    .frame(width: size.width * 1.0, height: size.height * 0.22)
                    .position(pt(0.28, 0.30, size))
                Ellipse()
                    .fill(Theme.orange200.opacity(0.5))
                    .frame(width: size.width * 0.9, height: size.height * 0.2)
                    .position(pt(0.75, 0.5, size))
                Ellipse()
                    .fill(Theme.yellow200.opacity(0.4))
                    .frame(width: size.width * 1.1, height: size.height * 0.24)
                    .position(pt(0.35, 0.72, size))
                Ellipse()
                    .fill(Theme.orange500.opacity(0.25))
                    .frame(width: size.width * 1.2, height: size.height * 0.2)
                    .position(pt(0.6, 0.97, size))

                // The Tiber river across the top
                RiverShape()
                    .stroke(Color(hex: "76B3DC"), style: StrokeStyle(lineWidth: 54, lineCap: .round))
                RiverShape()
                    .stroke(Color(hex: "9DCBE8").opacity(0.8), style: StrokeStyle(lineWidth: 16, lineCap: .round))

                // The road
                RoadShape()
                    .stroke(Theme.orange100, style: StrokeStyle(lineWidth: 42, lineCap: .round))
                RoadShape()
                    .stroke(
                        Color.white.opacity(0.65),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round, dash: [10, 13])
                    )

                // Bridge where the road meets the river
                bridge
                    .position(pt(0.55, 0.125, size))

                // Landmarks
                ColosseumView()
                    .frame(width: size.width * 0.46, height: size.width * 0.28)
                    .position(pt(0.76, 0.44, size))
                TempleView()
                    .frame(width: size.width * 0.3, height: size.width * 0.22)
                    .position(pt(0.14, 0.60, size))
                HouseView()
                    .frame(width: size.width * 0.16, height: size.width * 0.15)
                    .position(pt(0.85, 0.68, size))
                HouseView()
                    .frame(width: size.width * 0.14, height: size.width * 0.13)
                    .position(pt(0.16, 0.24, size))

                // Trees
                TreeView().frame(width: 34, height: 62).position(pt(0.08, 0.42, size))
                TreeView().frame(width: 28, height: 52).position(pt(0.9, 0.28, size))
                TreeView().frame(width: 30, height: 56).position(pt(0.62, 0.7, size))
                TreeView().frame(width: 26, height: 48).position(pt(0.1, 0.86, size))
                TreeView().frame(width: 30, height: 56).position(pt(0.88, 0.9, size))
                TreeView().frame(width: 24, height: 44).position(pt(0.3, 0.48, size))
            }
    }

    private var bridge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Theme.orange100)
                .frame(width: 64, height: 30)
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    Dome()
                        .fill(Color(hex: "76B3DC"))
                        .frame(width: 12, height: 8)
                        .scaleEffect(y: -1)
                }
            }
            .offset(y: 10)
        }
        .rotationEffect(.degrees(-6))
    }

    private func pt(_ x: CGFloat, _ y: CGFloat, _ size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }

    private func position(for level: AcademyLevel, in size: CGSize) -> CGPoint {
        switch level {
        case .forum: return pt(0.30, 0.79, size)
        case .basilica: return pt(0.68, 0.57, size)
        case .colosseum: return pt(0.40, 0.35, size)
        }
    }
}

// MARK: - Paths

private struct RoadShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: 0.50 * w, y: 1.04 * h))
        p.addCurve(
            to: CGPoint(x: 0.30 * w, y: 0.79 * h),
            control1: CGPoint(x: 0.52 * w, y: 0.94 * h),
            control2: CGPoint(x: 0.26 * w, y: 0.90 * h)
        )
        p.addCurve(
            to: CGPoint(x: 0.68 * w, y: 0.57 * h),
            control1: CGPoint(x: 0.34 * w, y: 0.68 * h),
            control2: CGPoint(x: 0.68 * w, y: 0.68 * h)
        )
        p.addCurve(
            to: CGPoint(x: 0.40 * w, y: 0.35 * h),
            control1: CGPoint(x: 0.68 * w, y: 0.46 * h),
            control2: CGPoint(x: 0.44 * w, y: 0.46 * h)
        )
        p.addCurve(
            to: CGPoint(x: 0.55 * w, y: 0.125 * h),
            control1: CGPoint(x: 0.36 * w, y: 0.24 * h),
            control2: CGPoint(x: 0.52 * w, y: 0.20 * h)
        )
        p.addCurve(
            to: CGPoint(x: 0.62 * w, y: -0.02 * h),
            control1: CGPoint(x: 0.57 * w, y: 0.08 * h),
            control2: CGPoint(x: 0.60 * w, y: 0.03 * h)
        )
        return p
    }
}

private struct RiverShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: -0.05 * w, y: 0.06 * h))
        p.addCurve(
            to: CGPoint(x: 0.55 * w, y: 0.125 * h),
            control1: CGPoint(x: 0.2 * w, y: 0.10 * h),
            control2: CGPoint(x: 0.35 * w, y: 0.14 * h)
        )
        p.addCurve(
            to: CGPoint(x: 1.05 * w, y: 0.05 * h),
            control1: CGPoint(x: 0.75 * w, y: 0.11 * h),
            control2: CGPoint(x: 0.9 * w, y: 0.03 * h)
        )
        return p
    }
}

// MARK: - Landmarks

/// Top-down-ish Colosseum: nested ellipses with an arcaded rim.
private struct ColosseumView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Ellipse()
                    .fill(Theme.orange900.opacity(0.25))
                    .frame(width: w, height: h * 0.9)
                    .offset(y: h * 0.08)
                Ellipse()
                    .fill(Theme.orange100)
                    .frame(width: w, height: h * 0.9)
                Ellipse()
                    .fill(Theme.orange200)
                    .frame(width: w * 0.8, height: h * 0.68)
                Ellipse()
                    .fill(Theme.orange100)
                    .frame(width: w * 0.62, height: h * 0.5)
                Ellipse()
                    .fill(Theme.yellow200)
                    .frame(width: w * 0.42, height: h * 0.32)
                // Arcade arches around the rim
                ForEach(0..<10, id: \.self) { i in
                    let angle = Double(i) / 10 * 2 * .pi
                    Circle()
                        .fill(Theme.orange700.opacity(0.55))
                        .frame(width: w * 0.045, height: w * 0.045)
                        .offset(
                            x: CGFloat(cos(angle)) * w * 0.44,
                            y: CGFloat(sin(angle)) * h * 0.4
                        )
                }
            }
            .frame(width: w, height: h)
        }
    }
}

/// Small classical temple with pediment and columns.
private struct TempleView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            VStack(spacing: 0) {
                Triangle()
                    .fill(Theme.orange700)
                    .frame(width: w * 0.95, height: w * 0.22)
                Rectangle()
                    .fill(Theme.orange50)
                    .frame(width: w, height: w * 0.06)
                HStack(spacing: w * 0.07) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.orange50)
                            .frame(width: w * 0.09, height: w * 0.34)
                    }
                }
                Rectangle()
                    .fill(Theme.orange100)
                    .frame(width: w, height: w * 0.07)
            }
            .shadow(color: Theme.orange900.opacity(0.3), radius: 5, y: 4)
            .position(x: w / 2, y: geo.size.height / 2)
        }
    }
}

/// Little terracotta-roofed domus.
private struct HouseView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            VStack(spacing: 0) {
                Triangle()
                    .fill(Theme.orange600)
                    .frame(width: w * 0.95, height: w * 0.38)
                ZStack {
                    Rectangle()
                        .fill(Theme.orange50)
                        .frame(width: w * 0.78, height: w * 0.5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.orange900)
                        .frame(width: w * 0.18, height: w * 0.3)
                        .offset(y: w * 0.1)
                }
            }
            .shadow(color: Theme.orange900.opacity(0.3), radius: 4, y: 3)
            .position(x: w / 2, y: geo.size.height / 2)
        }
    }
}

/// Mediterranean cypress.
private struct TreeView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            VStack(spacing: -2) {
                Ellipse()
                    .fill(Theme.laurel)
                    .frame(width: w, height: geo.size.height * 0.75)
                    .overlay(
                        Ellipse()
                            .fill(Theme.laurelDeep.opacity(0.5))
                            .frame(width: w * 0.55, height: geo.size.height * 0.45)
                            .offset(x: w * 0.14, y: geo.size.height * 0.1)
                    )
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.yellow900)
                    .frame(width: w * 0.16, height: geo.size.height * 0.22)
            }
            .shadow(color: Theme.orange900.opacity(0.25), radius: 3, y: 3)
            .position(x: w / 2, y: geo.size.height / 2)
        }
    }
}

// MARK: - Level pill

private struct MapLevelPill: View {
    let level: AcademyLevel
    let isSelected: Bool
    let isUnlocked: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button {
            if isUnlocked {
                Haptics.tap()
            } else {
                Haptics.error()
            }
            action()
        } label: {
            HStack(spacing: 5) {
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                }
                Text(level.rank)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(background)
            )
            .overlay(
                Capsule().strokeBorder(.white.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
            )
            .shadow(color: Theme.orange900.opacity(0.35), radius: 5, y: 3)
            .scaleEffect(isSelected && pulse ? 1.06 : 1)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var background: Color {
        if !isUnlocked { return Theme.gray400 }
        return isSelected ? Theme.orange500 : Theme.orange950
    }
}
