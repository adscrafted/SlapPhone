import SwiftUI

struct SlapColors {
    // Primary Colors
    static let primary = Color(hex: "FF2D92")      // Electric Pink - "Slap"
    static let secondary = Color(hex: "FFE600")    // Neon Yellow - "Ouch"
    static let accent = Color(hex: "7B2D8E")       // Bruise Purple
    static let background = Color(hex: "0D0D0D")   // Near Black
    static let text = Color.white
    static let success = Color(hex: "00FF88")      // Neon Green

    // Gradient combinations
    static let paywallGradient = LinearGradient(
        colors: [primary, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let impactGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .top,
        endPoint: .bottom
    )

    static let buttonGradient = LinearGradient(
        colors: [primary, primary.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
