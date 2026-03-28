import SwiftUI

struct SensitivitySlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let label: String

    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(SlapFonts.bodyBold(size: 16))
                    .foregroundStyle(SlapColors.text)

                Spacer()

                Text(String(format: "%.0f", value))
                    .font(SlapFonts.display(size: 24))
                    .foregroundStyle(SlapColors.primary)
                    .frame(minWidth: 40)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(SlapColors.text.opacity(0.1))
                        .frame(height: 8)

                    // Filled track
                    Capsule()
                        .fill(SlapColors.impactGradient)
                        .frame(width: filledWidth(in: geometry.size.width), height: 8)

                    // Thumb
                    Circle()
                        .fill(SlapColors.primary)
                        .frame(width: isDragging ? 32 : 28, height: isDragging ? 32 : 28)
                        .shadow(color: SlapColors.primary.opacity(0.5), radius: isDragging ? 8 : 4)
                        .offset(x: thumbOffset(in: geometry.size.width))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isDragging = true
                                    updateValue(at: gesture.location.x, in: geometry.size.width)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                        .animation(.spring(response: 0.2), value: isDragging)
                }
            }
            .frame(height: 32)

            // Scale indicators
            HStack {
                Text("Light")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.4))
                Spacer()
                Text("Hard")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.4))
            }
        }
        .padding(.vertical, 8)
    }

    private func normalizedValue() -> Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    private func filledWidth(in totalWidth: CGFloat) -> CGFloat {
        CGFloat(normalizedValue()) * totalWidth
    }

    private func thumbOffset(in totalWidth: CGFloat) -> CGFloat {
        CGFloat(normalizedValue()) * (totalWidth - 28)
    }

    private func updateValue(at position: CGFloat, in totalWidth: CGFloat) {
        let normalized = min(max(position / totalWidth, 0), 1)
        let newValue = range.lowerBound + (Double(normalized) * (range.upperBound - range.lowerBound))
        let steppedValue = (newValue / step).rounded() * step
        value = min(max(steppedValue, range.lowerBound), range.upperBound)
    }
}

// Cooldown slider with time display
struct CooldownSlider: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cooldown")
                    .font(SlapFonts.bodyBold(size: 16))
                    .foregroundStyle(SlapColors.text)

                Spacer()

                Text(String(format: "%.1fs", value))
                    .font(SlapFonts.display(size: 24))
                    .foregroundStyle(SlapColors.secondary)
            }

            Slider(value: $value, in: 0.5...3.0, step: 0.5)
                .tint(SlapColors.secondary)

            HStack {
                Text("0.5s")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.4))
                Spacer()
                Text("3.0s")
                    .font(SlapFonts.caption)
                    .foregroundStyle(SlapColors.text.opacity(0.4))
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        SlapColors.background.ignoresSafeArea()

        VStack(spacing: 40) {
            SensitivitySlider(
                value: .constant(5),
                range: 1...10,
                step: 1,
                label: "Sensitivity"
            )

            CooldownSlider(value: .constant(1.0))
        }
        .padding()
    }
}
