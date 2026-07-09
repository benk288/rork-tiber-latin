import SwiftUI

/// Warm Roman palette drawn from the Tiber design system.
enum Theme {
    static let cream = Color(hex: "FFF9EB")
    static let parchment = Color(hex: "FEEEC7")
    static let sand = Color(hex: "FCDC8B")
    static let amber = Color(hex: "FBC24E")
    static let gold = Color(hex: "FFD30F")
    static let goldDeep = Color(hex: "EFBA03")
    static let orange = Color(hex: "F4890C")
    static let orangeDeep = Color(hex: "D86407")
    static let terracotta = Color(hex: "B3430A")
    static let rust = Color(hex: "91340F")
    static let brown = Color(hex: "772C10")
    static let ink = Color(hex: "451403")
    static let crimson = Color(hex: "EB4864")
    static let crimsonDeep = Color(hex: "B51B40")
    static let blush = Color(hex: "FCCFD5")
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
        colors: [Color(hex: "FBC24E"), Color(hex: "F4890C")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let creamGradient = LinearGradient(
        colors: [Color(hex: "FFF9EB"), Color(hex: "FEEEC7")],
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
