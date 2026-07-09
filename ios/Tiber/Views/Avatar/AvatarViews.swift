import SwiftUI

// MARK: - Create Avatar (Figma 110:3467 "Appearance/Hair", 128:497 "Clothes/Top")

private enum AvatarCategory: Int, CaseIterable, Identifiable {
    case appearance
    case clothing
    case interactions

    var id: Int { rawValue }

    var asset: String {
        switch self {
        case .appearance: return "ChipAppearance"
        case .clothing: return "ChipClothing"
        case .interactions: return "ChipInteractions"
        }
    }

    var fallback: String {
        switch self {
        case .appearance: return "person.fill"
        case .clothing: return "tshirt.fill"
        case .interactions: return "hand.wave.fill"
        }
    }

    var tabs: [String] {
        switch self {
        case .appearance: return ["Skin Tone", "Face", "Hairstyles", "Eyes", "Body Shape"]
        case .clothing, .interactions: return ["Full Body", "Top", "Bottoms", "Accessories", "Shoes"]
        }
    }

    /// Grid tile assets available for this category.
    var tiles: [String] {
        switch self {
        case .appearance: return (1...9).map { String(format: "Hair%02d", $0) }
        case .clothing, .interactions: return (1...9).map { String(format: "Top%02d", $0) }
        }
    }

    /// Large preview illustration above the sheet.
    var preview: String {
        switch self {
        case .appearance: return "AvatarPreviewBust"
        case .clothing, .interactions: return "AvatarPreviewBody"
        }
    }
}

/// Hair color swatches from the design's color row (221:10087).
private let hairColors: [Color] = [
    Color(hex: "B0B0B0"),
    Color(hex: "FFC44D"),
    Color(hex: "C06B2D"),
    Color(hex: "8C3B2A"),
    Color(hex: "5D3A4E"),
    Color(hex: "453734"),
    Color(hex: "221818")
]

struct AvatarCreatorView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var category: AvatarCategory = .appearance
    @State private var tab = 2 // "Hairstyles" is active in the design
    @State private var colorIndex = 2
    @State private var selectedTile = 1
    @State private var history: [(Int, Int)] = []
    @State private var future: [(Int, Int)] = []

    var body: some View {
        VStack(spacing: 0) {
            customizeArea
            bottomSheet
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            selectedTile = category == .appearance
                ? app.progress.avatar.hairstyle
                : app.progress.avatar.outfit
            colorIndex = app.progress.avatar.hairColor
        }
    }

    // MARK: - Customize Avatar Area (213:6423 / 213:7577)

    private var customizeArea: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Theme.avatarCircle, Color(hex: "F3D9B2")],
                startPoint: .top,
                endPoint: .bottom
            )

            // Avatar preview illustration.
            FigmaImage(name: category.preview)
                .frame(
                    width: category == .appearance ? 303 : 140,
                    height: category == .appearance ? 280 : 238
                )
                .frame(maxWidth: .infinity)
                .padding(.top, category == .appearance ? 100 : 96)
                .clipped()

            // Top Bar (110:3468): back, centered title, Save.
            HStack {
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    ZStack {
                        Circle().fill(Color.white)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.gray950)
                    }
                    .frame(width: 40, height: 40)
                }

                Spacer()

                Button {
                    Haptics.tap()
                    save()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.rubik(14, .semibold))
                        .tracking(0.14)
                        .foregroundStyle(Theme.maroon)
                        .padding(.horizontal, 20)
                        .frame(height: 40)
                        .background(Capsule().fill(Theme.primary))
                }
            }
            .overlay(
                Text("Create Avatar")
                    .font(.rubik(17, .semibold))
                    .foregroundStyle(Theme.gray950)
            )
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Category chips + undo/redo (Frame 5139577).
            VStack {
                Spacer()
                HStack {
                    HStack(spacing: 12) {
                        ForEach(AvatarCategory.allCases) { cat in
                            chipButton(cat)
                        }
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        roundControl(asset: "ChipUndo", fallback: "arrow.uturn.backward", enabled: !history.isEmpty) {
                            undo()
                        }
                        roundControl(asset: "ChipRedo", fallback: "arrow.uturn.forward", enabled: !future.isEmpty) {
                            redo()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 399)
        .clipped()
        .ignoresSafeArea(edges: .top)
    }

    private func chipButton(_ cat: AvatarCategory) -> some View {
        Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                category = cat
                tab = cat == .appearance ? 2 : 0
                selectedTile = cat == .appearance ? app.progress.avatar.hairstyle : app.progress.avatar.outfit
            }
        } label: {
            ZStack {
                if category == cat {
                    Circle().fill(
                        LinearGradient(
                            colors: [Theme.orange500, Theme.orange400],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    Circle().strokeBorder(Color.white, lineWidth: 2)
                } else {
                    Circle().fill(Color.white)
                }
                if UIImage(named: cat.asset) != nil {
                    Image(cat.asset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: cat.fallback)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(category == cat ? .white : Theme.gray400)
                }
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }

    private func roundControl(asset: String, fallback: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            ZStack {
                Circle().fill(Color.white)
                if UIImage(named: asset) != nil {
                    Image(asset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(enabled ? 1 : 0.35)
                } else {
                    Image(systemName: fallback)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(enabled ? Theme.gray950 : Theme.gray300)
                }
            }
            .frame(width: 40, height: 40)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Content (110:3598 / 128:509)

    private var bottomSheet: some View {
        VStack(spacing: 0) {
            menuTabs
            if category == .appearance {
                colorRow
            }
            tileGrid
        }
        .background(Color.white)
    }

    /// Menu (232:10136): horizontally scrolling labels, 2pt underline.
    private var menuTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(category.tabs.indices, id: \.self) { index in
                    Button {
                        Haptics.tap()
                        withAnimation { tab = index }
                    } label: {
                        VStack(spacing: 12) {
                            Text(category.tabs[index])
                                .font(.rubik(14, tab == index ? .medium : .regular))
                                .foregroundStyle(tab == index ? Theme.gray950 : Theme.gray600)
                            Rectangle()
                                .fill(tab == index ? Theme.gray950 : .clear)
                                .frame(width: 72, height: 2)
                        }
                        .fixedSize()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .frame(height: 49)
    }

    /// Color row (221:10086): 36pt swatches, selected ringed with a check.
    private var colorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(hairColors.indices, id: \.self) { index in
                    Button {
                        Haptics.tap()
                        pushHistory()
                        colorIndex = index
                    } label: {
                        ZStack {
                            Circle().fill(hairColors[index])
                            if colorIndex == index {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(colorIndex == index ? Theme.orange500 : .clear, lineWidth: 2)
                                .frame(width: 42, height: 42)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(height: 64)
    }

    /// Avatar option grid (128:349 / 213:8189): 3 columns of 101pt tiles.
    private var tileGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                spacing: 16
            ) {
                ForEach(category.tiles.indices, id: \.self) { index in
                    tile(index)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func tile(_ index: Int) -> some View {
        Button {
            Haptics.tap()
            pushHistory()
            selectedTile = index
            save()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTile == index ? Theme.orange50 : Theme.gray50)
                FigmaImage(name: category.tiles[index])
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(selectedTile == index ? Theme.orange400 : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - History & persistence

    private func pushHistory() {
        history.append((selectedTile, colorIndex))
        future.removeAll()
    }

    private func undo() {
        guard let last = history.popLast() else { return }
        future.append((selectedTile, colorIndex))
        (selectedTile, colorIndex) = last
        save()
    }

    private func redo() {
        guard let next = future.popLast() else { return }
        history.append((selectedTile, colorIndex))
        (selectedTile, colorIndex) = next
        save()
    }

    private func save() {
        if category == .appearance {
            app.progress.avatar.hairstyle = selectedTile
            app.progress.avatar.hairColor = colorIndex
        } else {
            app.progress.avatar.outfit = selectedTile
        }
    }
}

// MARK: - Small avatar bust (used by Settings)

struct AvatarBustView: View {
    let config: AvatarConfig
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle().fill(Theme.avatarCircle)
            FigmaImage(name: "HudProfile")
                .clipShape(Circle())
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    AvatarCreatorView()
        .environment(AppState())
}
