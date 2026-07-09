import SwiftUI

/// Tiber design system palette, generated from the Figma color styles
/// (Gray / Orange / Yellow / Pink scales, 50...950).
enum Theme {
    // MARK: - Gray
    static let gray50 = Color(hex: "F6F6F6")
    static let gray100 = Color(hex: "E7E7E7")
    static let gray200 = Color(hex: "D1D1D1")
    static let gray300 = Color(hex: "B0B0B0")
    static let gray400 = Color(hex: "888888")
    static let gray500 = Color(hex: "6D6D6D")
    static let gray600 = Color(hex: "5D5D5D")
    static let gray700 = Color(hex: "4F4F4F")
    static let gray800 = Color(hex: "454545")
    static let gray900 = Color(hex: "3D3D3D")
    static let gray950 = Color(hex: "000000")

    // MARK: - Orange
    static let orange50 = Color(hex: "FFF9EB")
    static let orange100 = Color(hex: "FEEEC7")
    static let orange200 = Color(hex: "FCDC8B")
    static let orange300 = Color(hex: "FBC24E")
    static let orange400 = Color(hex: "FAAF30")
    static let orange500 = Color(hex: "F4890C")
    static let orange600 = Color(hex: "D86407")
    static let orange700 = Color(hex: "B3430A")
    static let orange800 = Color(hex: "91340F")
    static let orange900 = Color(hex: "772C10")
    static let orange950 = Color(hex: "451403")

    // MARK: - Yellow
    static let yellow50 = Color(hex: "FEFCE8")
    static let yellow100 = Color(hex: "FFFBC2")
    static let yellow200 = Color(hex: "FFF487")
    static let yellow300 = Color(hex: "FFE643")
    static let yellow400 = Color(hex: "FFD30F")
    static let yellow500 = Color(hex: "EFBA03")
    static let yellow600 = Color(hex: "CE9000")
    static let yellow700 = Color(hex: "A46604")
    static let yellow800 = Color(hex: "884F0B")
    static let yellow900 = Color(hex: "734110")
    static let yellow950 = Color(hex: "432105")

    // MARK: - Pink
    static let pink50 = Color(hex: "FEF2F3")
    static let pink100 = Color(hex: "FEE5E7")
    static let pink200 = Color(hex: "FCCFD5")
    static let pink300 = Color(hex: "F9A8B2")
    static let pink400 = Color(hex: "F25F74")
    static let pink500 = Color(hex: "EB4864")
    static let pink600 = Color(hex: "D7274E")
    static let pink700 = Color(hex: "B51B40")
    static let pink800 = Color(hex: "98193C")
    static let pink900 = Color(hex: "821939")
    static let pink950 = Color(hex: "48091B")

    // MARK: - Semantic aliases (used across the app)
    static let cream = orange50
    static let parchment = orange100
    static let sand = orange200
    static let amber = orange300
    static let gold = yellow400
    static let goldDeep = yellow500
    static let orange = orange500
    static let orangeDeep = orange600
    static let terracotta = orange700
    static let rust = orange800
    static let brown = orange900
    static let ink = orange950
    static let crimson = pink500
    static let crimsonDeep = pink700
    static let blush = pink200
    static let laurel = Color(hex: "7A8C3F")
    static let laurelDeep = Color(hex: "55632A")

    /// Success color, adjusted for color-blind mode (green -> blue).
    static func success(colorBlind: Bool) -> Color {
        colorBlind ? Color(hex: "2D6FD1") : laurel
    }

    /// Error color, adjusted for color-blind mode (red -> orange-brown kept distinct by shape too).
    static func failure(colorBlind: Bool) -> Color {
        colorBlind ? Color(hex: "8A5A00") : crimsonDeep
    }

    static let skyGradient = LinearGradient(
        colors: [orange300, orange500],
        startPoint: .top,
        endPoint: .bottom
    )

    static let creamGradient = LinearGradient(
        colors: [orange50, orange100],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
