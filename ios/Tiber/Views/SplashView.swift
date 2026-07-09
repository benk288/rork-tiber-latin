import SwiftUI

/// Renders a Figma-exported asset at its design size; falls back to a flat
/// placeholder tint until `scripts/fetch-figma-assets.sh` has been run.
struct FigmaImage: View {
    let name: String
    var placeholder: Color = .clear

    var body: some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
    }
}

/// A000 - Splash (Figma node 479:5053): full-screen palace hall with the
/// centurion holding a scroll, and the layered arch rings at the top edge.
struct SplashView: View {
    var body: some View {
        DesignCanvas {
            Color.white

            // Top arch rings (ellipses cropped by the top edge)
            FigmaImage(name: "SplashEllipseOuter")
                .placed(x: 40.03, y: -48.07, w: 294.95, h: 97.14)
            FigmaImage(name: "SplashEllipseMid")
                .placed(x: 48.66, y: -48.07, w: 277.68, h: 97.14)
            FigmaImage(name: "SplashEllipseInner")
                .placed(x: 89.85, y: -33.66, w: 195.30, h: 68.32)
            FigmaImage(name: "SplashLaurel")
                .placed(x: 109, y: -39, w: 160, h: 72.85)
            FigmaImage(name: "SplashEllipseCore")
                .placed(x: 118.21, y: -23.74, w: 138.58, h: 48.48)

            // Palace hall + centurion (group 645:18557)
            FigmaImage(name: "SplashMain", placeholder: Theme.orange100)
                .placed(x: -287.10, y: -9.15, w: 948.44, h: 927.15)
        }
        .background(Color.white)
    }
}

#Preview {
    SplashView()
}
