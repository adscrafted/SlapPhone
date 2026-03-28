import SwiftUI

struct SlapCounter: View {
    let count: Int
    let label: String
    @State private var displayedCount: Int = 0
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 4) {
            Text("\(displayedCount)")
                .font(SlapFonts.counter)
                .foregroundStyle(SlapColors.primary)
                .contentTransition(.numericText())
                .scaleEffect(isAnimating ? 1.15 : 1.0)

            Text(label.uppercased())
                .font(SlapFonts.caption)
                .foregroundStyle(SlapColors.text.opacity(0.6))
                .tracking(2)
        }
        .onChange(of: count) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                displayedCount = newValue
                isAnimating = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
        }
        .onAppear {
            displayedCount = count
        }
    }
}

// Multi-stat counter row
struct StatCounterRow: View {
    let slaps: Int
    let throwCount: Int
    let shakes: Int

    var body: some View {
        HStack(spacing: 32) {
            StatItem(value: slaps, label: "Slaps", icon: "hand.raised.fill", color: SlapColors.primary)
            StatItem(value: throwCount, label: "Throws", icon: "arrow.up.right", color: SlapColors.accent)
            StatItem(value: shakes, label: "Shakes", icon: "iphone.gen3.radiowaves.left.and.right", color: SlapColors.secondary)
        }
    }
}

struct StatItem: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text("\(value)")
                .font(SlapFonts.statNumber)
                .foregroundStyle(SlapColors.text)

            Text(label)
                .font(SlapFonts.caption)
                .foregroundStyle(SlapColors.text.opacity(0.6))
        }
    }
}

#Preview {
    ZStack {
        SlapColors.background.ignoresSafeArea()

        VStack(spacing: 40) {
            SlapCounter(count: 1234, label: "Total Slaps")

            StatCounterRow(slaps: 100, throwCount: 25, shakes: 50)
        }
    }
}
