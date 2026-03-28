import SwiftUI

struct SlapAnimations {
    // Bounce animation for impacts
    static let bounce = Animation.interpolatingSpring(
        stiffness: 300,
        damping: 10
    )

    // Shake animation
    static let shake = Animation.easeInOut(duration: 0.1)

    // Pulse animation for buttons
    static let pulse = Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)

    // Quick pop
    static let pop = Animation.spring(response: 0.3, dampingFraction: 0.5)

    // Smooth transition
    static let smooth = Animation.easeInOut(duration: 0.3)

    // Impact ring expansion
    static let impactRing = Animation.easeOut(duration: 0.8)
}

// Shake effect modifier
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shakeAmount: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: shakeAmount))
            .onChange(of: trigger) { _, _ in
                withAnimation(SlapAnimations.shake) {
                    shakeAmount = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    shakeAmount = 0
                }
            }
    }
}

// Screen flash effect
struct FlashOverlay: View {
    let isFlashing: Bool
    let color: Color

    var body: some View {
        color
            .opacity(isFlashing ? 0.5 : 0)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.15), value: isFlashing)
    }
}
