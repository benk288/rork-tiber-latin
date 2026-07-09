import SwiftUI

/// The Home map from "Home color option 01" (Figma node 92:1510): the full
/// isometric illustration with the Colosseum, the knight rider and the two
/// level pills, laid out in the design's 375x812 coordinate space.
struct RomanMapView: View {
    let selected: AcademyLevel
    var onSelect: (AcademyLevel) -> Void = { _ in }

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 375
            ZStack(alignment: .topLeading) {
                // Illustrasion (192:5343): 375x875 anchored at y -163.
                FigmaImage(name: "HomeMapIllustration", placeholder: Theme.orange300)
                    .frame(width: 375 * s, height: 875 * s)
                    .offset(y: -163 * s)

                // Colosseum overlay group (250:25579).
                FigmaImage(name: "HomeColosseum")
                    .frame(width: 192.28 * s, height: 180.91 * s)
                    .offset(x: 177.56 * s, y: 252 * s)

                // Elementary pill (192:3407) - white.
                LevelPill(
                    title: "Elementary",
                    fill: .white,
                    textColor: Theme.inkText,
                    isSelected: selected == .basilica
                ) {
                    onSelect(.basilica)
                }
                .offset(x: 82 * s, y: 344 * s)
                .scaleEffect(s, anchor: .topLeading)

                // Knight rider (264:1148).
                FigmaImage(name: "HomeKnight")
                    .frame(width: 60.85 * s, height: 72.80 * s)
                    .offset(x: 259.14 * s, y: 449.14 * s)

                // Beginner pill (192:3425) - maroon.
                LevelPill(
                    title: "Beginner",
                    fill: Theme.maroon,
                    textColor: .white,
                    isSelected: selected == .forum
                ) {
                    onSelect(.forum)
                }
                .offset(x: 233 * s, y: 418.12 * s)
                .scaleEffect(s, anchor: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .clipped()
        }
        .ignoresSafeArea()
        .background(Theme.orange300)
    }
}

/// Level pill (Figma "Level"): 33pt capsule, 16/6 padding, with the small
/// downward triangle pointer underneath.
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

#Preview {
    RomanMapView(selected: .forum)
}
