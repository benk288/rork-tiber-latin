import SwiftUI

/// Full-screen launch illustration: a centurion standing in a golden palace.
struct SplashView: View {
    @State private var appeared = false

    var body: some View {
        ArtImage(name: "SplashArt") { drawn }
            .ignoresSafeArea()
    }

    private var drawn: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.orange300, Theme.orange500, Theme.orange700],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            DesignCanvas(design: CGSize(width: 390, height: 844), fill: true) {
                // Back wall arches
                HStack(spacing: 34) {
                    ForEach(0..<3, id: \.self) { _ in
                        ArchShape()
                            .fill(Theme.orange200.opacity(0.35))
                            .frame(width: 90, height: 190)
                    }
                }
                .offset(y: -220)

                // Side columns
                RomanColumn(width: 44, height: 560, color: Theme.orange100.opacity(0.85))
                    .offset(x: -168, y: -60)
                RomanColumn(width: 44, height: 560, color: Theme.orange100.opacity(0.85))
                    .offset(x: 168, y: -60)

                // Candelabra
                candelabrum.offset(x: -108, y: 120)
                candelabrum.offset(x: 108, y: 120)

                // Floor
                Ellipse()
                    .fill(Theme.orange800.opacity(0.35))
                    .frame(width: 480, height: 190)
                    .offset(y: 400)
                Ellipse()
                    .fill(Theme.orange900.opacity(0.3))
                    .frame(width: 300, height: 70)
                    .offset(y: 320)

                CenturionFigure()
                    .offset(y: 110)
                    .scaleEffect(appeared ? 1 : 0.92)
                    .opacity(appeared ? 1 : 0)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var candelabrum: some View {
        VStack(spacing: 0) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.yellow300)
            Capsule().fill(Theme.yellow600).frame(width: 26, height: 8)
            Capsule().fill(Theme.yellow600).frame(width: 8, height: 96)
            Capsule().fill(Theme.yellow600).frame(width: 34, height: 8)
        }
    }
}

#Preview {
    SplashView()
}
