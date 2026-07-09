import SwiftUI

// MARK: - Premade artwork slots

/// Shows the premade illustration from the asset catalog when it has been
/// added (e.g. exported from Figma into the named image set), otherwise
/// renders the built-in vector fallback. Drop a PNG into the matching
/// image set in Assets.xcassets and the screen picks it up automatically.
struct ArtImage<Fallback: View>: View {
    let name: String
    @ViewBuilder var fallback: () -> Fallback

    var body: some View {
        if UIImage(named: name) != nil {
            GeometryReader { geo in
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        } else {
            fallback()
        }
    }
}

// MARK: - Layout helper

/// Lays out fixed-coordinate artwork and scales it to fit (or fill) the
/// available space.
struct DesignCanvas<Content: View>: View {
    let design: CGSize
    var fill: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / design.width
            let sy = geo.size.height / design.height
            let scale = max(0.01, fill ? max(sx, sy) : min(sx, sy))
            ZStack { content() }
                .frame(width: design.width, height: design.height)
                .scaleEffect(scale)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

// MARK: - Primitive shapes

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

/// Filled half-circle sitting on its bottom edge (hair, helmets, crests).
struct Dome: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

/// Roman arch: half-circle top over straight sides.
struct ArchShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.width / 2
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// A theatrical curtain swag anchored to the top-leading corner.
/// Mirror with `scaleEffect(x: -1)` for the trailing side.
struct CurtainShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addCurve(
            to: CGPoint(x: w * 0.42, y: h),
            control1: CGPoint(x: w * 0.98, y: h * 0.35),
            control2: CGPoint(x: w * 0.72, y: h * 0.72)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.92),
            control: CGPoint(x: w * 0.18, y: h * 0.82)
        )
        path.closeSubpath()
        return path
    }
}

/// Classical fluted column with capital and base.
struct RomanColumn: View {
    var width: CGFloat = 34
    var height: CGFloat = 220
    var color: Color = Theme.orange50

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: width * 1.35, height: 10)
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: width, height: height - 40)
                .overlay(
                    HStack(spacing: width * 0.18) {
                        ForEach(0..<3, id: \.self) { _ in
                            Capsule()
                                .fill(Color.black.opacity(0.06))
                                .frame(width: width * 0.1)
                        }
                    }
                    .padding(.vertical, 6)
                )
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: width * 1.35, height: 10)
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: width * 1.55, height: 10)
        }
        .frame(height: height)
    }
}

// MARK: - Characters

/// The Tiber emperor mascot: laurel wreath, white toga, golden shield, scroll.
/// Natural design size: 240 x 260.
struct EmperorFigure: View {
    private let skin = Color(hex: "F3C29F")
    private let hair = Color(hex: "8B5E34")

    var body: some View {
        ZStack {
            // Toga body
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.white)
                .frame(width: 148, height: 130)
                .offset(y: 72)
            // Toga folds
            Capsule().fill(Theme.gray100).frame(width: 5, height: 84).offset(x: -28, y: 82)
            Capsule().fill(Theme.gray100).frame(width: 5, height: 84).offset(x: 34, y: 82)
            // Orange sash
            Capsule()
                .fill(Theme.orange500)
                .frame(width: 30, height: 150)
                .rotationEffect(.degrees(32))
                .offset(x: 14, y: 62)
            // Arm holding the shield
            Capsule()
                .fill(skin)
                .frame(width: 24, height: 58)
                .rotationEffect(.degrees(-42))
                .offset(x: -42, y: 46)
            // Golden shield
            ZStack {
                Circle().fill(Theme.yellow400)
                Circle().strokeBorder(Theme.yellow600, lineWidth: 6)
                Image(systemName: "laurel.leading")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Theme.yellow700)
                    .offset(x: -8)
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Theme.yellow700)
                    .offset(x: 8)
            }
            .frame(width: 76, height: 76)
            .offset(x: -64, y: 66)
            // Scroll in the other hand
            RoundedRectangle(cornerRadius: 6)
                .fill(Theme.orange50)
                .frame(width: 54, height: 36)
                .overlay(
                    VStack(spacing: 6) {
                        Capsule().fill(Theme.gray200).frame(width: 32, height: 3)
                        Capsule().fill(Theme.gray200).frame(width: 24, height: 3)
                    }
                )
                .rotationEffect(.degrees(-12))
                .offset(x: 66, y: 50)
            Circle().fill(skin).frame(width: 22, height: 22).offset(x: 56, y: 66)
            // Neck
            RoundedRectangle(cornerRadius: 6)
                .fill(skin)
                .frame(width: 30, height: 22)
                .offset(y: 4)
            // Ears
            Circle().fill(skin).frame(width: 18, height: 18).offset(x: -44, y: -40)
            Circle().fill(skin).frame(width: 18, height: 18).offset(x: 44, y: -40)
            // Head
            Circle().fill(skin).frame(width: 88, height: 88).offset(y: -42)
            // Hair
            Dome()
                .fill(hair)
                .frame(width: 92, height: 42)
                .offset(y: -66)
            Capsule().fill(hair).frame(width: 12, height: 26).offset(x: -41, y: -52)
            Capsule().fill(hair).frame(width: 12, height: 26).offset(x: 41, y: -52)
            // Laurel wreath
            Image(systemName: "laurel.leading")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.yellow500)
                .rotationEffect(.degrees(-18))
                .offset(x: -34, y: -74)
            Image(systemName: "laurel.trailing")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.yellow500)
                .rotationEffect(.degrees(18))
                .offset(x: 34, y: -74)
            // Face
            Capsule().fill(hair).frame(width: 16, height: 4).offset(x: -16, y: -60)
            Capsule().fill(hair).frame(width: 16, height: 4).offset(x: 16, y: -60)
            Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: -16, y: -48)
            Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: 16, y: -48)
            Circle().fill(Theme.pink200.opacity(0.8)).frame(width: 12, height: 12).offset(x: -28, y: -34)
            Circle().fill(Theme.pink200.opacity(0.8)).frame(width: 12, height: 12).offset(x: 28, y: -34)
            Capsule().fill(Color(hex: "C96F4A")).frame(width: 18, height: 6).offset(y: -24)
        }
        .frame(width: 240, height: 260)
    }
}

/// The splash-screen centurion: crested helmet, armor, crimson cape, spear.
/// Natural design size: 260 x 420.
struct CenturionFigure: View {
    private let skin = Color(hex: "F3C29F")
    private let armor = Color(hex: "8A99B5")
    private let armorDark = Color(hex: "6E7D99")

    var body: some View {
        ZStack {
            // Cape
            RoundedRectangle(cornerRadius: 54)
                .fill(Theme.pink700)
                .frame(width: 158, height: 210)
                .offset(y: 30)
            // Spear
            Capsule().fill(Theme.yellow600).frame(width: 9, height: 300).offset(x: 104, y: -10)
            Triangle().fill(Theme.yellow400).frame(width: 22, height: 30).offset(x: 104, y: -172)
            // Legs
            Capsule().fill(skin).frame(width: 27, height: 86).offset(x: -21, y: 168)
            Capsule().fill(skin).frame(width: 27, height: 86).offset(x: 21, y: 168)
            // Sandals
            RoundedRectangle(cornerRadius: 5).fill(Theme.yellow900).frame(width: 34, height: 14).offset(x: -22, y: 208)
            RoundedRectangle(cornerRadius: 5).fill(Theme.yellow900).frame(width: 34, height: 14).offset(x: 22, y: 208)
            // Pteruges (skirt straps)
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.orange900)
                        .frame(width: 17, height: 48)
                }
            }
            .offset(y: 118)
            // Torso armor
            RoundedRectangle(cornerRadius: 26)
                .fill(armor)
                .frame(width: 112, height: 112)
                .offset(y: 48)
            Capsule().fill(armorDark).frame(width: 100, height: 9).offset(y: 26)
            Capsule().fill(armorDark).frame(width: 100, height: 9).offset(y: 44)
            // Belt
            Capsule().fill(Theme.yellow500).frame(width: 112, height: 16).offset(y: 96)
            Circle().fill(Theme.yellow600).frame(width: 20, height: 20).offset(y: 96)
            // Shoulder guards
            RoundedRectangle(cornerRadius: 10).fill(armorDark).frame(width: 46, height: 26).offset(x: -50, y: 0)
            RoundedRectangle(cornerRadius: 10).fill(armorDark).frame(width: 46, height: 26).offset(x: 50, y: 0)
            // Arms
            Capsule().fill(skin).frame(width: 24, height: 70).offset(x: -64, y: 40)
            Capsule().fill(skin).frame(width: 24, height: 62).offset(x: 64, y: 36)
            Circle().fill(skin).frame(width: 22, height: 22).offset(x: 104, y: 62)
            // Neck & head
            RoundedRectangle(cornerRadius: 6).fill(skin).frame(width: 28, height: 20).offset(y: -22)
            Circle().fill(skin).frame(width: 80, height: 80).offset(y: -66)
            // Crest
            Dome()
                .fill(Theme.pink600)
                .frame(width: 118, height: 52)
                .offset(y: -122)
            // Helmet
            Dome()
                .fill(Theme.yellow500)
                .frame(width: 88, height: 44)
                .offset(y: -92)
            Capsule().fill(Theme.yellow600).frame(width: 94, height: 10).offset(y: -88)
            RoundedRectangle(cornerRadius: 5).fill(Theme.yellow500).frame(width: 15, height: 32).offset(x: -36, y: -62)
            RoundedRectangle(cornerRadius: 5).fill(Theme.yellow500).frame(width: 15, height: 32).offset(x: 36, y: -62)
            // Face
            Capsule().fill(Theme.yellow950).frame(width: 15, height: 4).offset(x: -15, y: -80)
            Capsule().fill(Theme.yellow950).frame(width: 15, height: 4).offset(x: 15, y: -80)
            Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: -15, y: -70)
            Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: 15, y: -70)
            Capsule().fill(Color(hex: "C96F4A")).frame(width: 16, height: 5).offset(y: -48)
        }
        .frame(width: 260, height: 420)
    }
}

/// Small toga person used in the "Tribes" onboarding scene.
struct TogaFigure: View {
    var tunic: Color = .white
    var sash: Color = Theme.orange500
    var skin: Color = Color(hex: "F3C29F")
    var hair: Color = Color(hex: "5A3A22")

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(tunic)
                .frame(width: 84, height: 96)
                .offset(y: 52)
            Capsule()
                .fill(sash)
                .frame(width: 18, height: 104)
                .rotationEffect(.degrees(30))
                .offset(x: 8, y: 48)
            RoundedRectangle(cornerRadius: 5).fill(skin).frame(width: 20, height: 14).offset(y: -2)
            Circle().fill(skin).frame(width: 62, height: 62).offset(y: -30)
            Dome().fill(hair).frame(width: 66, height: 30).offset(y: -48)
            Circle().fill(Theme.gray900).frame(width: 6, height: 6).offset(x: -11, y: -34)
            Circle().fill(Theme.gray900).frame(width: 6, height: 6).offset(x: 11, y: -34)
            Capsule().fill(Color(hex: "C96F4A")).frame(width: 12, height: 4).offset(y: -18)
        }
        .frame(width: 160, height: 200)
    }
}

// MARK: - Scene headers

/// Auth header: the emperor framed by a marble arch and red curtains.
struct AuthHeaderIllustration: View {
    var body: some View {
        ArtImage(name: "AuthHeaderArt") { drawn }
    }

    private var drawn: some View {
        DesignCanvas(design: CGSize(width: 390, height: 300), fill: true) {
            Rectangle().fill(Theme.orange50)
            // Arch window
            ArchShape()
                .fill(Theme.gray100)
                .frame(width: 320, height: 258)
                .offset(y: 21)
            ArchShape()
                .stroke(Theme.gray200, lineWidth: 6)
                .frame(width: 320, height: 258)
                .offset(y: 21)
            // Distant columns inside the arch
            HStack(spacing: 46) {
                RomanColumn(width: 22, height: 150, color: Theme.gray200)
                RomanColumn(width: 22, height: 150, color: Theme.gray200)
                RomanColumn(width: 22, height: 150, color: Theme.gray200)
            }
            .offset(y: 75)
            // Curtains
            CurtainShape()
                .fill(Theme.orange700)
                .frame(width: 150, height: 280)
                .offset(x: -120, y: 10)
            CurtainShape()
                .fill(Theme.orange700)
                .frame(width: 150, height: 280)
                .scaleEffect(x: -1)
                .offset(x: 120, y: 10)
            Capsule().fill(Theme.yellow500).frame(width: 44, height: 12)
                .rotationEffect(.degrees(24)).offset(x: -142, y: 96)
            Capsule().fill(Theme.yellow500).frame(width: 44, height: 12)
                .rotationEffect(.degrees(-24)).offset(x: 142, y: 96)
            // Valance across the top
            Rectangle().fill(Theme.orange700).frame(width: 390, height: 26).offset(y: -137)
            EmperorFigure()
                .offset(y: 40)
        }
        .clipped()
    }
}

/// Confirm-registration header: lavender vault doors and a golden code box.
struct ConfirmHeaderIllustration: View {
    private let wall = Color(hex: "C7C8E6")
    private let floor = Color(hex: "A5A6CE")
    private let door = Color(hex: "898BC0")
    private let panel = Color(hex: "6E70A3")

    var body: some View {
        ArtImage(name: "ConfirmHeaderArt") { drawn }
    }

    private var drawn: some View {
        DesignCanvas(design: CGSize(width: 390, height: 300), fill: true) {
            Rectangle().fill(wall)
            Rectangle().fill(floor).frame(width: 390, height: 58).offset(y: 121)
            doorView.offset(x: -92, y: 22)
            doorView.offset(x: 92, y: 22)
            // Golden code box between the doors
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.yellow400)
                .frame(width: 84, height: 108)
                .offset(y: 46)
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.yellow600)
                .frame(width: 60, height: 30)
                .offset(y: 16)
            HStack(spacing: 7) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Theme.yellow200).frame(width: 11, height: 11)
                }
            }
            .offset(y: 16)
            Circle()
                .strokeBorder(Theme.yellow700, lineWidth: 6)
                .frame(width: 40, height: 40)
                .offset(y: 66)
            Circle().fill(Theme.yellow700).frame(width: 10, height: 10).offset(y: 66)
        }
        .clipped()
    }

    private var doorView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(door)
            .frame(width: 128, height: 214)
            .overlay(
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(panel, lineWidth: 4)
                                .frame(width: 44, height: 52)
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(panel, lineWidth: 4)
                                .frame(width: 44, height: 52)
                        }
                    }
                }
            )
    }
}

// MARK: - Onboarding scenes

/// Illustration block for each onboarding page.
struct OnboardingIllustration: View {
    let page: Int

    var body: some View {
        ArtImage(name: "OnboardingArt\(page + 1)") {
            switch page {
            case 0: throneScene
            case 1: coinsScene
            case 2: tribesScene
            default: onlineScene
            }
        }
    }

    /// Page 1 - Welcome: the emperor beneath a crimson canopy.
    private var throneScene: some View {
        DesignCanvas(design: CGSize(width: 390, height: 360), fill: true) {
            Rectangle().fill(Theme.orange50)
            HStack(spacing: 250) {
                RomanColumn(width: 30, height: 320, color: Theme.gray100)
                RomanColumn(width: 30, height: 320, color: Theme.gray100)
            }
            .offset(y: 20)
            // Throne back
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.yellow500)
                .frame(width: 190, height: 210)
                .offset(y: 70)
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.yellow400)
                .frame(width: 160, height: 184)
                .offset(y: 78)
            // Canopy
            CurtainShape()
                .fill(Theme.orange700)
                .frame(width: 130, height: 210)
                .offset(x: -130, y: -60)
            CurtainShape()
                .fill(Theme.orange700)
                .frame(width: 130, height: 210)
                .scaleEffect(x: -1)
                .offset(x: 130, y: -60)
            Rectangle().fill(Theme.orange700).frame(width: 390, height: 30).offset(y: -165)
            EmperorFigure().offset(y: 60)
        }
        .clipped()
    }

    /// Page 2 - Tiber coins: an overflowing bag of gold.
    private var coinsScene: some View {
        DesignCanvas(design: CGSize(width: 390, height: 360), fill: true) {
            LinearGradient(
                colors: [Theme.yellow900, Theme.yellow950],
                startPoint: .top,
                endPoint: .bottom
            )
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.yellow400.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 190
                    )
                )
                .frame(width: 380, height: 380)
            // Coin bag
            RoundedRectangle(cornerRadius: 60)
                .fill(Color(hex: "8A5B33"))
                .frame(width: 210, height: 180)
                .offset(y: 76)
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "6E4527"))
                .frame(width: 84, height: 40)
                .offset(y: -22)
            Capsule().fill(Theme.yellow500).frame(width: 96, height: 14).offset(y: -8)
            // Coins spilling out
            coin(size: 52).offset(x: 0, y: -52)
            coin(size: 40).offset(x: -58, y: -34)
            coin(size: 40).offset(x: 58, y: -34)
            coin(size: 34).offset(x: -110, y: 96)
            coin(size: 34).offset(x: 110, y: 96)
            coin(size: 30).offset(x: -140, y: 140)
            coin(size: 30).offset(x: 140, y: 140)
            Image(systemName: "sparkle")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.yellow300)
                .offset(x: -96, y: -84)
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.yellow300)
                .offset(x: 104, y: -104)
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.yellow200)
                .offset(x: 66, y: 10)
        }
        .clipped()
    }

    /// Page 3 - Tribes: two citizens side by side.
    private var tribesScene: some View {
        DesignCanvas(design: CGSize(width: 390, height: 360), fill: true) {
            Rectangle().fill(Theme.gray100)
            ArchShape()
                .fill(Theme.gray50)
                .frame(width: 250, height: 230)
                .offset(y: 65)
            HStack(spacing: 300) {
                RomanColumn(width: 28, height: 320, color: Theme.gray200)
                RomanColumn(width: 28, height: 320, color: Theme.gray200)
            }
            .offset(y: 20)
            TogaFigure(tunic: .white, sash: Theme.yellow500, hair: Color(hex: "3B2A1D"))
                .offset(x: -64, y: 82)
            TogaFigure(
                tunic: Theme.gray200,
                sash: Theme.gray400,
                skin: Color(hex: "C98A5E"),
                hair: Color(hex: "8B5E34")
            )
            .offset(x: 64, y: 82)
        }
        .clipped()
    }

    /// Page 4 - Online: the emperor checks his phone.
    private var onlineScene: some View {
        DesignCanvas(design: CGSize(width: 390, height: 360), fill: true) {
            Rectangle().fill(Theme.orange50)
            ArchShape()
                .fill(Theme.gray100)
                .frame(width: 280, height: 250)
                .offset(y: 55)
            HStack(spacing: 280) {
                RomanColumn(width: 28, height: 320, color: Theme.gray200)
                RomanColumn(width: 28, height: 320, color: Theme.gray200)
            }
            .offset(y: 20)
            EmperorFigure().offset(y: 70)
            // Phone in front
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.gray900)
                .frame(width: 52, height: 92)
                .rotationEffect(.degrees(8))
                .offset(x: 88, y: 96)
            RoundedRectangle(cornerRadius: 7)
                .fill(Theme.orange100)
                .frame(width: 42, height: 80)
                .rotationEffect(.degrees(8))
                .offset(x: 88, y: 96)
            Image(systemName: "wifi")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.orange500)
                .offset(x: 106, y: 22)
        }
        .clipped()
    }

    private func coin(size: CGFloat) -> some View {
        ZStack {
            Circle().fill(Theme.yellow400)
            Circle().strokeBorder(Theme.yellow600, lineWidth: size * 0.1)
            Image(systemName: "building.columns")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(Theme.yellow700)
        }
        .frame(width: size, height: size)
    }
}
