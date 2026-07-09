import SwiftUI

// MARK: - Style catalog

enum AvatarStyle {
    static let skinTones: [Color] = [
        Color(hex: "FFE0C7"), Color(hex: "F3C29F"), Color(hex: "E0A981"),
        Color(hex: "C68863"), Color(hex: "9C6644"), Color(hex: "6E4A2F")
    ]

    static let hairColors: [Color] = [
        Color(hex: "3B2A1D"), Color(hex: "5A3A22"), Color(hex: "8B5E34"),
        Color(hex: "C99147"), Color(hex: "D9B382"), Color(hex: "8F8F8F")
    ]

    static let hairstyleCount = 6
    static let eyeCount = 4
    static let outfitCount = 6
    static let accessoryCount = 3

    static func skin(_ config: AvatarConfig) -> Color {
        skinTones[min(max(config.skinTone, 0), skinTones.count - 1)]
    }

    static func hair(_ config: AvatarConfig) -> Color {
        hairColors[min(max(config.hairColor, 0), hairColors.count - 1)]
    }
}

// MARK: - Full-body avatar

/// Renders the player's avatar from an `AvatarConfig`.
/// Scales to any frame; natural proportions 220 x 330.
struct AvatarView: View {
    let config: AvatarConfig

    var body: some View {
        DesignCanvas(design: CGSize(width: 220, height: 330)) {
            let skin = AvatarStyle.skin(config)

            // Legs & sandals
            Capsule().fill(skin).frame(width: 24, height: 72).offset(x: -17, y: 122)
            Capsule().fill(skin).frame(width: 24, height: 72).offset(x: 17, y: 122)
            RoundedRectangle(cornerRadius: 4).fill(Theme.yellow900).frame(width: 30, height: 12).offset(x: -18, y: 156)
            RoundedRectangle(cornerRadius: 4).fill(Theme.yellow900).frame(width: 30, height: 12).offset(x: 18, y: 156)

            // Arms
            Capsule().fill(skin).frame(width: 22, height: 66)
                .rotationEffect(.degrees(14)).offset(x: -56, y: 46)
            Capsule().fill(skin).frame(width: 22, height: 66)
                .rotationEffect(.degrees(-14)).offset(x: 56, y: 46)

            outfit

            // Neck & head
            RoundedRectangle(cornerRadius: 6).fill(skin).frame(width: 26, height: 18).offset(y: -32)
            Circle().fill(skin).frame(width: 15, height: 15).offset(x: -41, y: -70)
            Circle().fill(skin).frame(width: 15, height: 15).offset(x: 41, y: -70)
            Circle().fill(skin).frame(width: 82, height: 82).offset(y: -70)

            AvatarHair(config: config)
                .offset(y: -70)

            AvatarFace(config: config)
                .offset(y: -70)

            AvatarAccessory(config: config)
                .offset(y: -70)
        }
    }

    @ViewBuilder
    private var outfit: some View {
        switch config.outfit {
        case 1: // Legionary armor
            RoundedRectangle(cornerRadius: 22).fill(Theme.orange700).frame(width: 96, height: 100).offset(y: 32)
            RoundedRectangle(cornerRadius: 8).fill(Theme.orange800).frame(width: 38, height: 20).offset(x: -42, y: -12)
            RoundedRectangle(cornerRadius: 8).fill(Theme.orange800).frame(width: 38, height: 20).offset(x: 42, y: -12)
            Capsule().fill(Theme.yellow500).frame(width: 96, height: 13).offset(y: 66)
            Circle().fill(Theme.yellow600).frame(width: 17, height: 17).offset(y: 66)
        case 2: // Blue toga
            RoundedRectangle(cornerRadius: 22).fill(Color(hex: "5B7DB1")).frame(width: 96, height: 100).offset(y: 32)
            Capsule().fill(.white).frame(width: 22, height: 106)
                .rotationEffect(.degrees(32)).offset(x: 8, y: 26)
        case 3: // Green tunic
            RoundedRectangle(cornerRadius: 22).fill(Theme.laurel).frame(width: 96, height: 100).offset(y: 32)
            Capsule().fill(Theme.yellow900).frame(width: 96, height: 11).offset(y: 52)
        case 4: // Royal gold
            RoundedRectangle(cornerRadius: 22).fill(Theme.yellow400).frame(width: 96, height: 100).offset(y: 32)
            Capsule().fill(Theme.pink700).frame(width: 22, height: 106)
                .rotationEffect(.degrees(32)).offset(x: 8, y: 26)
        case 5: // Gray pallium
            RoundedRectangle(cornerRadius: 22).fill(Theme.gray200).frame(width: 96, height: 100).offset(y: 32)
            Capsule().fill(Theme.gray400).frame(width: 96, height: 11).offset(y: 52)
        default: // White tunic + orange sash
            RoundedRectangle(cornerRadius: 22).fill(.white).frame(width: 96, height: 100).offset(y: 32)
            Capsule().fill(Theme.orange500).frame(width: 22, height: 106)
                .rotationEffect(.degrees(32)).offset(x: 8, y: 26)
        }
    }
}

/// Head-only crop used for option previews. Natural size 120 x 120.
struct AvatarHeadView: View {
    let config: AvatarConfig

    var body: some View {
        DesignCanvas(design: CGSize(width: 120, height: 120)) {
            let skin = AvatarStyle.skin(config)
            Circle().fill(skin).frame(width: 15, height: 15).offset(x: -41, y: 8)
            Circle().fill(skin).frame(width: 15, height: 15).offset(x: 41, y: 8)
            Circle().fill(skin).frame(width: 82, height: 82).offset(y: 8)
            AvatarHair(config: config).offset(y: 8)
            AvatarFace(config: config).offset(y: 8)
            AvatarAccessory(config: config).offset(y: 8)
        }
    }
}

/// Circular avatar bust for HUDs and nav bars.
struct AvatarBustView: View {
    let config: AvatarConfig
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle().fill(Theme.orange100)
            AvatarHeadView(config: config)
                .frame(width: size * 0.94, height: size * 0.94)
                .offset(y: size * 0.06)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
        .shadow(color: Theme.gray950.opacity(0.15), radius: 3, y: 1)
    }
}

// MARK: - Avatar parts

private struct AvatarHair: View {
    let config: AvatarConfig

    var body: some View {
        let color = AvatarStyle.hair(config)
        ZStack {
            switch config.hairstyle {
            case 1: // Short crop
                Dome().fill(color).frame(width: 86, height: 38).offset(y: -24)
                Capsule().fill(color).frame(width: 10, height: 22).offset(x: -38, y: -12)
                Capsule().fill(color).frame(width: 10, height: 22).offset(x: 38, y: -12)
            case 2: // Fringe
                Dome().fill(color).frame(width: 86, height: 40).offset(y: -24)
                Circle().fill(color).frame(width: 20, height: 20).offset(x: -22, y: -28)
                Circle().fill(color).frame(width: 20, height: 20).offset(x: 0, y: -32)
                Circle().fill(color).frame(width: 20, height: 20).offset(x: 22, y: -28)
            case 3: // Curly
                Circle().fill(color).frame(width: 30, height: 30).offset(x: -30, y: -28)
                Circle().fill(color).frame(width: 34, height: 34).offset(x: 0, y: -38)
                Circle().fill(color).frame(width: 30, height: 30).offset(x: 30, y: -28)
                Circle().fill(color).frame(width: 24, height: 24).offset(x: -40, y: -8)
                Circle().fill(color).frame(width: 24, height: 24).offset(x: 40, y: -8)
            case 4: // Long
                Dome().fill(color).frame(width: 88, height: 40).offset(y: -24)
                Capsule().fill(color).frame(width: 18, height: 62).offset(x: -38, y: 8)
                Capsule().fill(color).frame(width: 18, height: 62).offset(x: 38, y: 8)
            case 5: // Top knot
                Dome().fill(color).frame(width: 86, height: 36).offset(y: -25)
                Circle().fill(color).frame(width: 24, height: 24).offset(y: -48)
            default: // Bald
                EmptyView()
            }
        }
    }
}

private struct AvatarFace: View {
    let config: AvatarConfig

    var body: some View {
        let hair = AvatarStyle.hair(config)
        ZStack {
            // Brows
            Capsule().fill(hair.opacity(config.hairstyle == 0 ? 0.6 : 1))
                .frame(width: 15, height: 4).offset(x: -15, y: -16)
            Capsule().fill(hair.opacity(config.hairstyle == 0 ? 0.6 : 1))
                .frame(width: 15, height: 4).offset(x: 15, y: -16)

            // Eyes
            switch config.eyes {
            case 1: // Happy
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Theme.gray900)
                    .offset(x: -15, y: -4)
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Theme.gray900)
                    .offset(x: 15, y: -4)
            case 2: // Wide
                Circle().fill(.white).frame(width: 16, height: 16).offset(x: -15, y: -4)
                Circle().fill(.white).frame(width: 16, height: 16).offset(x: 15, y: -4)
                Circle().fill(Theme.gray950).frame(width: 7, height: 7).offset(x: -15, y: -4)
                Circle().fill(Theme.gray950).frame(width: 7, height: 7).offset(x: 15, y: -4)
            case 3: // Sleepy
                Capsule().fill(Theme.gray900).frame(width: 14, height: 4).offset(x: -15, y: -4)
                Capsule().fill(Theme.gray900).frame(width: 14, height: 4).offset(x: 15, y: -4)
            default: // Dots
                Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: -15, y: -4)
                Circle().fill(Theme.gray900).frame(width: 8, height: 8).offset(x: 15, y: -4)
            }

            // Blush & mouth
            Circle().fill(Theme.pink200.opacity(0.8)).frame(width: 11, height: 11).offset(x: -26, y: 8)
            Circle().fill(Theme.pink200.opacity(0.8)).frame(width: 11, height: 11).offset(x: 26, y: 8)
            Capsule().fill(Color(hex: "C96F4A")).frame(width: 16, height: 5).offset(y: 18)
        }
    }
}

private struct AvatarAccessory: View {
    let config: AvatarConfig

    var body: some View {
        ZStack {
            switch config.accessory {
            case 1: // Golden laurel
                Image(systemName: "laurel.leading")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.yellow500)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -31, y: -30)
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.yellow500)
                    .rotationEffect(.degrees(18))
                    .offset(x: 31, y: -30)
            case 2: // Red headband
                Capsule().fill(Theme.pink600).frame(width: 82, height: 11).offset(y: -26)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Create Avatar screen

private enum AvatarCategory: String, CaseIterable, Identifiable {
    case skin = "Skin Tone"
    case hair = "Hairstyles"
    case hairColor = "Hair Color"
    case eyes = "Eyes"
    case outfit = "Full Body"
    case accessory = "Accessories"

    var id: String { rawValue }

    var group: AvatarGroup {
        switch self {
        case .skin, .hair, .hairColor, .eyes: return .appearance
        case .outfit, .accessory: return .clothing
        }
    }

    var optionCount: Int {
        switch self {
        case .skin: return AvatarStyle.skinTones.count
        case .hair: return AvatarStyle.hairstyleCount
        case .hairColor: return AvatarStyle.hairColors.count
        case .eyes: return AvatarStyle.eyeCount
        case .outfit: return AvatarStyle.outfitCount
        case .accessory: return AvatarStyle.accessoryCount
        }
    }
}

private enum AvatarGroup {
    case appearance
    case clothing
}

/// The "Create Avatar" editor from the profile designs.
struct AvatarCreatorView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    var isPresentedModally: Bool = false

    @State private var config = AvatarConfig()
    @State private var history: [AvatarConfig] = []
    @State private var future: [AvatarConfig] = []
    @State private var group: AvatarGroup = .appearance
    @State private var category: AvatarCategory = .skin
    @State private var showSettings = false
    @State private var loaded = false

    private let columns = [GridItem(.adaptive(minimum: 84), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            navBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    previewCard
                    categoryTabs
                    optionGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 110)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            guard !loaded else { return }
            config = app.progress.avatar
            loaded = true
        }
    }

    // MARK: Pieces

    private var navBar: some View {
        ZStack {
            Text("Create Avatar")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.gray950)
            HStack {
                Button {
                    Haptics.tap()
                    if isPresentedModally {
                        dismiss()
                    } else {
                        showSettings = true
                    }
                } label: {
                    Image(systemName: isPresentedModally ? "chevron.left" : "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.gray950)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.gray50))
                }
                Spacer()
                Button {
                    Haptics.success()
                    app.progress.avatar = config
                    if isPresentedModally { dismiss() }
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Theme.orange400))
                }
            }
        }
    }

    private var previewCard: some View {
        ZStack(alignment: .bottom) {
            ArtImage(name: "AvatarStageArt") {
                LinearGradient(
                    colors: [Theme.orange100, Theme.orange300],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))

            AvatarView(config: config)
                .frame(height: 250)
                .padding(.bottom, 46)

            HStack {
                groupButton(icon: "person.fill", value: .appearance)
                groupButton(icon: "tshirt.fill", value: .clothing)
                Spacer()
                historyButton(icon: "arrow.uturn.backward", enabled: !history.isEmpty) { undo() }
                historyButton(icon: "arrow.uturn.forward", enabled: !future.isEmpty) { redo() }
            }
            .padding(12)
        }
        .frame(height: 320)
    }

    private func groupButton(icon: String, value: AvatarGroup) -> some View {
        Button {
            Haptics.tap()
            group = value
            category = value == .appearance ? .skin : .outfit
        } label: {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(group == value ? .white : Theme.gray500)
                .frame(width: 40, height: 40)
                .background(Circle().fill(group == value ? Theme.orange500 : .white))
                .shadow(color: Theme.gray950.opacity(0.12), radius: 3, y: 1)
        }
    }

    private func historyButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.gray700)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.white))
                .shadow(color: Theme.gray950.opacity(0.12), radius: 3, y: 1)
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 22) {
                ForEach(AvatarCategory.allCases.filter { $0.group == group }) { item in
                    Button {
                        Haptics.tap()
                        category = item
                    } label: {
                        VStack(spacing: 6) {
                            Text(item.rawValue)
                                .font(.system(size: 14, weight: category == item ? .bold : .medium))
                                .foregroundStyle(category == item ? Theme.gray950 : Theme.gray400)
                            Capsule()
                                .fill(category == item ? Theme.orange500 : .clear)
                                .frame(width: 26, height: 3)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var optionGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<category.optionCount, id: \.self) { index in
                optionTile(index: index)
            }
        }
    }

    private func optionTile(index: Int) -> some View {
        let isSelected = selectedIndex == index
        return Button {
            Haptics.tap()
            select(index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.orange50)
                tileContent(index: index)
                    .padding(10)
            }
            .frame(height: 92)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? Theme.orange500 : Theme.gray100, lineWidth: isSelected ? 2.5 : 1.5)
            )
        }
    }

    @ViewBuilder
    private func tileContent(index: Int) -> some View {
        switch category {
        case .skin:
            Circle()
                .fill(AvatarStyle.skinTones[index])
                .frame(width: 52, height: 52)
        case .hairColor:
            Circle()
                .fill(AvatarStyle.hairColors[index])
                .frame(width: 52, height: 52)
        case .hair, .eyes, .accessory:
            AvatarHeadView(config: previewConfig(index: index))
        case .outfit:
            AvatarView(config: previewConfig(index: index))
        }
    }

    // MARK: State

    private var selectedIndex: Int {
        switch category {
        case .skin: return config.skinTone
        case .hair: return config.hairstyle
        case .hairColor: return config.hairColor
        case .eyes: return config.eyes
        case .outfit: return config.outfit
        case .accessory: return config.accessory
        }
    }

    private func previewConfig(index: Int) -> AvatarConfig {
        var preview = config
        switch category {
        case .skin: preview.skinTone = index
        case .hair: preview.hairstyle = index
        case .hairColor: preview.hairColor = index
        case .eyes: preview.eyes = index
        case .outfit: preview.outfit = index
        case .accessory: preview.accessory = index
        }
        return preview
    }

    private func select(_ index: Int) {
        history.append(config)
        future.removeAll()
        config = previewConfig(index: index)
    }

    private func undo() {
        guard let previous = history.popLast() else { return }
        future.append(config)
        config = previous
    }

    private func redo() {
        guard let next = future.popLast() else { return }
        history.append(config)
        config = next
    }
}

#Preview {
    AvatarCreatorView()
        .environment(AppState())
}
