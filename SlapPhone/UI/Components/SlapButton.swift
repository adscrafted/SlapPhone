import SwiftUI

struct SlapButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true

    enum ButtonStyle {
        case primary
        case secondary
        case outline

        var background: some View {
            switch self {
            case .primary:
                return AnyView(SlapColors.buttonGradient)
            case .secondary:
                return AnyView(SlapColors.accent)
            case .outline:
                return AnyView(Color.clear)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary:
                return .white
            case .outline:
                return SlapColors.primary
            }
        }

        var borderColor: Color {
            switch self {
            case .primary, .secondary:
                return .clear
            case .outline:
                return SlapColors.primary
            }
        }
    }

    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                action()
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                }

                Text(title.uppercased())
                    .font(SlapFonts.bodyBold(size: 18))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(style.background)
            .foregroundStyle(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style.borderColor, lineWidth: 2)
            )
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
}

// Scale animation on press
struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// Small icon button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var color: Color = SlapColors.primary

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(color.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Toggle button with icon
struct ToggleButton: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isOn ? SlapColors.primary : SlapColors.text.opacity(0.5))
                    .frame(width: 24)

                Text(label)
                    .font(SlapFonts.bodyMedium)
                    .foregroundStyle(SlapColors.text)

                Spacer()

                Circle()
                    .fill(isOn ? SlapColors.success : SlapColors.text.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(SlapColors.text.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ZStack {
        SlapColors.background.ignoresSafeArea()

        VStack(spacing: 20) {
            SlapButton(title: "Unlock Full Version", action: {})
            SlapButton(title: "Secondary", action: {}, style: .secondary)
            SlapButton(title: "Outline", action: {}, style: .outline)
            SlapButton(title: "Loading", action: {}, isLoading: true)

            HStack {
                IconButton(icon: "gearshape.fill", action: {})
                IconButton(icon: "speaker.wave.3.fill", action: {}, color: SlapColors.secondary)
            }

            ToggleButton(icon: "hand.raised.fill", label: "Slap Detection", isOn: .constant(true))
            ToggleButton(icon: "arrow.up.right", label: "Throw Detection", isOn: .constant(false))
        }
        .padding()
    }
}
