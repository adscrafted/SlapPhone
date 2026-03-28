import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var handOffset: CGFloat = -100
    @State private var impactBurst = false

    var body: some View {
        ZStack {
            // Background
            SlapColors.background
                .ignoresSafeArea()

            // Impact burst effect
            if impactBurst {
                ImpactBurstView()
                    .transition(.opacity)
            }

            VStack(spacing: 24) {
                Spacer()

                // Animated hand slapping phone
                ZStack {
                    // Phone icon
                    Image(systemName: "iphone")
                        .font(.system(size: 120, weight: .thin))
                        .foregroundStyle(SlapColors.text.opacity(0.8))
                        .shake(trigger: impactBurst)

                    // Hand icon
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(SlapColors.primary)
                        .rotationEffect(.degrees(-30))
                        .offset(x: handOffset, y: -40)
                }
                .frame(height: 160)

                // Title with impact styling
                VStack(spacing: 8) {
                    Text("SLAP")
                        .font(SlapFonts.heroTitle)
                        .foregroundStyle(SlapColors.primary)
                    +
                    Text("PHONE")
                        .font(SlapFonts.heroTitle)
                        .foregroundStyle(SlapColors.text)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Subtitle
                Text("It screams back.")
                    .font(SlapFonts.bodyLarge)
                    .foregroundStyle(SlapColors.text.opacity(0.7))
                    .italic()
                    .opacity(subtitleOpacity)

                Spacer()

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: SlapColors.primary))
                    .scaleEffect(1.2)
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Hand slap animation
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            handOffset = 30
        }

        // Impact and title reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.none) {
                impactBurst = true
            }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }

            // Hide burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    impactBurst = false
                }
            }
        }

        // Subtitle fade in
        withAnimation(.easeIn(duration: 0.4).delay(0.9)) {
            subtitleOpacity = 1.0
        }
    }
}

// Comic-style impact burst
struct ImpactBurstView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            // Multiple starburst layers
            ForEach(0..<3) { index in
                StarburstShape()
                    .fill(index == 0 ? SlapColors.primary : (index == 1 ? SlapColors.secondary : SlapColors.accent))
                    .frame(width: 300 - CGFloat(index * 40), height: 300 - CGFloat(index * 40))
                    .rotationEffect(.degrees(Double(index) * 15))
                    .scaleEffect(scale)
                    .opacity(opacity * (1 - Double(index) * 0.2))
            }

            // POW! text
            Text("SLAP!")
                .font(SlapFonts.display(size: 36))
                .foregroundStyle(.white)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.2
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                opacity = 0
            }
        }
    }
}

// Starburst shape for comic effect
struct StarburstShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 12
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.5

        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(i) / Double(points * 2)) * 2 * .pi - .pi / 2

            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    SplashView()
}
