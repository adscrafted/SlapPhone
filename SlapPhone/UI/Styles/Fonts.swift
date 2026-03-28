import SwiftUI

struct SlapFonts {
    // Display fonts (titles, headers)
    static func display(size: CGFloat) -> Font {
        .custom("Bangers-Regular", size: size, relativeTo: .largeTitle)
    }

    // Body fonts (readable text)
    static func body(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func bodyBold(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    // Predefined sizes
    static let heroTitle = display(size: 64)
    static let largeTitle = display(size: 48)
    static let title = display(size: 36)
    static let subtitle = display(size: 24)

    static let bodyLarge = body(size: 18)
    static let bodyMedium = body(size: 16)
    static let bodySmall = body(size: 14)
    static let caption = body(size: 12)

    static let counter = display(size: 72)
    static let statNumber = display(size: 32)
}

// Font modifier for easy application
struct SlapFontModifier: ViewModifier {
    let font: Font
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

extension View {
    func slapFont(_ font: Font, color: Color = SlapColors.text) -> some View {
        modifier(SlapFontModifier(font: font, color: color))
    }
}
