import SwiftUI

struct ImpactVisualizer: View {
    let impact: ImpactEvent?
    @State private var rings: [ImpactRing] = []

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(SlapColors.background)
                .overlay(
                    Circle()
                        .stroke(SlapColors.primary.opacity(0.3), lineWidth: 2)
                )

            // Impact rings
            ForEach(rings) { ring in
                Circle()
                    .stroke(
                        ring.color.opacity(ring.opacity),
                        lineWidth: max(1, 4 * ring.opacity)
                    )
                    .scaleEffect(ring.scale)
            }

            // Center icon
            if let impact = impact {
                Image(systemName: impact.type.icon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(SlapColors.primary)
                    .scaleEffect(rings.isEmpty ? 1.0 : 1.2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: rings.count)
            } else {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(SlapColors.primary.opacity(0.5))
            }
        }
        .onChange(of: impact?.id) { _, newValue in
            if newValue != nil, let impact = impact {
                addRing(for: impact)
            }
        }
    }

    private func addRing(for impact: ImpactEvent) {
        let color = Color(hex: impact.type.color)
        let ring = ImpactRing(color: color, magnitude: impact.magnitude)
        rings.append(ring)

        // Animate ring expansion
        withAnimation(.easeOut(duration: 0.8)) {
            if let index = rings.firstIndex(where: { $0.id == ring.id }) {
                rings[index].scale = 2.5
                rings[index].opacity = 0
            }
        }

        // Remove ring after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            rings.removeAll { $0.id == ring.id }
        }
    }
}

struct ImpactRing: Identifiable {
    let id = UUID()
    let color: Color
    let magnitude: Double
    var scale: CGFloat = 0.5
    var opacity: Double = 1.0
}

// Smaller version for list items
struct MiniImpactVisualizer: View {
    let impactType: ImpactType

    var body: some View {
        Circle()
            .fill(Color(hex: impactType.color).opacity(0.2))
            .overlay(
                Image(systemName: impactType.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: impactType.color))
            )
            .frame(width: 40, height: 40)
    }
}

#Preview {
    ZStack {
        SlapColors.background.ignoresSafeArea()

        ImpactVisualizer(impact: ImpactEvent(type: .slap, magnitude: 3.5))
            .frame(width: 250, height: 250)
    }
}
